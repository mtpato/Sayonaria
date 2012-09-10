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
    //bring up a loader and set the server connection state
    [self.delegate putLoaderInView];
    [self.delegate setCurrentServerStateConnecting];
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
                            //NSLog(@"%@",output);
                            [self.delegate messageRecieved:output];
						}
					}
				}
			}
			break;
            
		case NSStreamEventErrorOccurred:
			//NSLog(@"Can not connect to the host!");
            [self.delegate removeLoaderFromView];
            [self.delegate messageRecieved:@"CANNOT CONNECT"];
			break;
			
		case NSStreamEventEndEncountered:
            //close the socket
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
            [self.delegate messageRecieved:@"SOCKETS CLOSED"];
			break;
            
		default:
			NSLog(@"Unknown event");
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
    NSLog(@"Saying To Server:%@",message);
    NSData *dataToSend = [[NSData alloc] initWithData:[[message stringByAppendingString:@"\n"] dataUsingEncoding:NSASCIIStringEncoding]];
	[self.outputStream write:[dataToSend bytes] maxLength:[dataToSend length]];
}

@end
