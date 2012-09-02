//
//  NetworkController.m
//  SayonariaGame
//
//  Created by Ian Pytlarz on 9/2/12.
//
//

#import "NetworkController.h"

@implementation NetworkController
@synthesize currentServerState = _currentServerState;
@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;
@synthesize alert = _alert;

#pragma mark - assign default values for alert

-(UIAlertView *)alert {
    if(_alert == nil) {
        _alert = [[UIAlertView alloc]
                  initWithTitle: @"Alert"
                  message: @"Alert!"
                  delegate: self
                  cancelButtonTitle:@"OK"
                  otherButtonTitles:nil];
    }
    return _alert;
}

#pragma mark - Network Initialization and Handling

//Initialize the socket
- (void)initNetworkCommunication {
    //bring up a loader and set the server connection state
    [self.delegate putLoaderInView];
    self.currentServerState = (ServerState *)Connecting;
    //create input and output stream core foundation objects
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    //create the socket: PUT THE SERVER IP HERE!!!
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"localhost", 4356, &readStream, &writeStream);
    //cast the CFStreams as NSStreams
    self.inputStream = (__bridge NSInputStream *)readStream;
    self.outputStream = (__bridge NSOutputStream *)writeStream;
    //set the delegates for the streams to be the login controller
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    //constantly check for new data on the stream
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    //open the socket
    [self.inputStream open];
    [self.outputStream open];
}


- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	
	switch (streamEvent) {
			
		case NSStreamEventOpenCompleted:
			//NSLog(@"Stream opened");
			break;
        case NSStreamEventHasSpaceAvailable:
            
            break;
		case NSStreamEventHasBytesAvailable:
            //this will read in input bytes, convert to a string and pass it to the handler
			if (theStream == self.inputStream) {
				uint8_t buffer[1024];
				int len;
				while ([(NSInputStream *) theStream hasBytesAvailable]) {
					len = [(NSInputStream *) theStream read:buffer maxLength:sizeof(buffer)];
					if (len > 0) {
						NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
						if (nil != output) {
                            output = [output substringToIndex:([output length]-1)];
   							[self messageReceived:output withState:self.currentServerState];
						}
					}
				}
			}
			break;
            
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
            self.currentServerState = nil;
            [self.delegate removeLoaderFromView];
            self.alert = [[UIAlertView alloc]
                          initWithTitle: @"Cannot Access Server"
                          message: @"Error 37: There was a problem accessing the server"
                          delegate: self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
            [self.alert show];
			break;
			
		case NSStreamEventEndEncountered:
            //close the socket
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
            self.currentServerState = nil;
			break;
            
		default:
			NSLog(@"Unknown event");
	}
    
}

//figures out what to do with the message received from the server
- (void) messageReceived:(NSString *)messageFromServer withState:(ServerState *)state{
    NSLog(@"server said: %@", messageFromServer);
    
    //grab the defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //if the server says 'done' it can be connecting, confirming the game type, etc
    if([[messageFromServer substringToIndex:4] isEqualToString:@"done"]){
        
        //if we have JUST connected, send the game type to the server
        if(state == (ServerState *)Connecting){
            self.currentServerState = (ServerState *)SendingGameType;
            [self sendMessageToServer:@"tileGame"];
            //if we have sent in the game type, try logging in with a pre existing auth key
        } else if(state == (ServerState *)SendingGameType){
            self.currentServerState = (ServerState *)ConnectedAwaitingLogon;
            [self loginToServerWithAuthkey];
            //remove the initial loading screen
            [self.delegate removeLoaderFromView];
            //if the recieved message has an auth key, set the auth key and login
            //Otherwise a new user was created woohoo
        } else if (state == (ServerState *)ConnectedAwaitingLogon){
            if([messageFromServer length] > 4){
                [defaults setObject:[messageFromServer substringFromIndex:5] forKey:AUTH_KEY];
                [defaults synchronize];
                [self performSegueWithIdentifier:@"showTabView" sender:self];
            } else {
                NSLog(@"New User Created Successfully");
            }
        } else if(state == (ServerState *)TryingAuthKeyLogin) {
            NSLog(@"Logged in!");
            self.currentServerState = (ServerState *)InTabView;
            [self performSegueWithIdentifier:@"showTabView" sender:self];
        } else{
            NSLog(@"Server 'done' message not interpreted");
        }
        
        //DO MORE STUFF HERE!
    } else if([messageFromServer isEqualToString:@"ANOTHER OUTPUT FROM THE SERVER"]) {
    } else if([messageFromServer isEqualToString:@"error"]){
        if(state == (ServerState *)ConnectedAwaitingLogon) {
            self.alert.title = @"Cannot Log In";
            self.alert.message = @"Invalid username/password";
            [self.alert show];
            [self.delegate removeLoaderFromView];
        } else if(state == (ServerState *)TryingAuthKeyLogin) {
            NSLog(@"Bad AuthKey");
            self.currentServerState = (ServerState *)ConnectedAwaitingLogon;
        }
    } else {
        NSLog(@"Unknown Server Message");
    }
}

#pragma mark - Network Communication

/****
 POSSIBLE COMMANDS TO SEND TO THE SERVER:
 keyLogin (logs in with auth key)
 login (logs in with user/pass)
 newUser (creates new user)
 getGames
 newGame
 gameState (returns game state of certain game)
 makeMove
 deleteGame
 signOut
 ****/

//public class method to send a message to the server
-(void)sendMessageToServer: (NSString *)message{
    NSData *dataToSend = [[NSData alloc] initWithData:[[message stringByAppendingString:@"\n"] dataUsingEncoding:NSASCIIStringEncoding]];
	[self.outputStream write:[dataToSend bytes] maxLength:[dataToSend length]];
}

-(void)sendUserToServer:(NSString *)newUserCommand{
    [self sendMessageToServer:newUserCommand];
}

//creates a string with the proper syntax to log in using a password. will get an authkey back
- (void)loginToServerWithPassword:(NSString *)userNamePassword {
	NSString *loginString  = [NSString stringWithFormat:@"login:%@", userNamePassword];
    [self sendMessageToServer:loginString];
}

//check if the user has a stored username and authkey. if they do, login
- (void)loginToServerWithAuthkey {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(([defaults objectForKey:USER_NAME] != nil) && ([defaults objectForKey:AUTH_KEY] != nil)) {
        self.currentServerState = (ServerState *)TryingAuthKeyLogin;
        NSString *loginString = [NSString stringWithFormat:@"%@%@%@%@", @"keyLogin:",[defaults objectForKey:USER_NAME], @",", [defaults objectForKey:AUTH_KEY]];
        [self sendMessageToServer:loginString];
    }
}


@end
