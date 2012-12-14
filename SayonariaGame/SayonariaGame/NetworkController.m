//
//  NetworkController.m
//  SayonariaGame
//
//  Created by Ian Pytlarz on 9/2/12.
//
//

#import "NetworkController.h"

@implementation NetworkController
@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;

#pragma mark - Network Initialization and Handling

//Initialize the socket
- (void)initNetworkCommunication {
    //set up a notification when the app enters the background to close the sockets
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeNetworkCommunication)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    //bring up a loader and set the server connection state
    self.currentServerState = (ServerState *)Connecting;
    //create input and output stream core foundation objects
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    //create the socket: 98.204.95.21 is real IP
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
    self.dataQueue = nil;
}


- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	
	switch (streamEvent) {
			
		case NSStreamEventOpenCompleted:
			//NSLog(@"Stream opened");
			break;
        case NSStreamEventHasSpaceAvailable:
            //NSLog(@"Space available on the output stream");
            if (self.dataQueue != nil) {
                NSString *stringToSend = [[NSString alloc] initWithData:self.dataQueue encoding:NSASCIIStringEncoding];
                self.dataQueue = nil;
                [self sendMessageToServer:stringToSend];
            }
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
                        NSLog(@"%@%@",@"Server said:",output);
						if (nil != output) {
                            output = [output substringToIndex:([output length]-1)];
                           // NSLog(@"Server Said in NC:%@",output);
                            
                            //if the message is "done"
                            if([[output substringToIndex:4] isEqualToString:@"done"]){
                                //NSLog(@"Connected to the Server");
                                //if we have JUST connected, send the game type to the server
                                if(self.currentServerState == (ServerState *)Connecting){
                                    self.currentServerState = (ServerState *)SendingGameType;
                                    [self sendMessageToServer:@"tileGame"];
                                    //if we have sent in the game type, try logging in with a pre existing auth key
                                } else if(self.currentServerState == (ServerState *)SendingGameType){
                                    self.currentServerState = (ServerState *)ConnectedAwaitingLogon;
                                   // NSLog(@"blah");
                                    [self loginToServerWithAuthkey];
                                } else {
                                    [self.delegate messageRecieved:output];
                                }
                            }
                            //if the message isn't "done"
                            else {
                                [self.delegate messageRecieved:output];
                            }
						}
					}
				}
			}
			break;
            
		case NSStreamEventErrorOccurred:
			//NSLog(@"Can not connect to the host!");
            [self.delegate messageRecieved:@"CANNOT CONNECT"];
			break;
			
		case NSStreamEventEndEncountered:
            //close the socket
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
            [self.delegate messageRecieved:@"SOCKETS CLOSED"];
            self.currentServerState = nil;
			break;
            
		default:
			NSLog(@"Unknown event");
	}
    
}

-(void)closeNetworkCommunication{
    [self sendMessageToServer:@"quit"];
    [self.inputStream close];
    [self.outputStream close];
    [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                      forMode:NSDefaultRunLoopMode];
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                      forMode:NSDefaultRunLoopMode];
    self.inputStream = nil;
    self.outputStream = nil;
    //NSLog(@"Closing Communications");
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

    if (self.outputStream.hasSpaceAvailable == TRUE) {
        NSLog(@"Saying To Server:%@",message);
        [self.outputStream write:[dataToSend bytes] maxLength:[dataToSend length]];
        self.dataQueue = nil;
    } else {
        self.dataQueue = dataToSend;
    }
}

//check if the user has a stored username and authkey. if they do, login
- (void)loginToServerWithAuthkey {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(([defaults objectForKey:USER_NAME] != nil) && ([defaults objectForKey:AUTH_KEY] != nil)) {
        self.currentServerState = (ServerState *)TryingAuthKeyLogin;
        NSString *loginString = [NSString stringWithFormat:@"%@%@%@%@", @"keyLogin:",[defaults objectForKey:USER_NAME], @",", [defaults objectForKey:AUTH_KEY]];
        [self sendMessageToServer:loginString];
    } else{
        [self sendMessageToServer:@"keyLogin:Blahhhhh,xxxxxxxxx"];
    }
}

-(void)checkConnection{
    if(self.inputStream == nil || self.outputStream == nil){
        [self initNetworkCommunication];
    }
}

@end
