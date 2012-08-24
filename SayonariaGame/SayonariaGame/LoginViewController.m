//
//  LoginViewController.m
//  SayonariaGame
//
//  Created by Ian Pytlarz on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController()

@end

@implementation LoginViewController
@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;

- (IBAction)BackgroundClicked:(id)sender {
    NSLog(@"You resigned first responder");
    [self.UserName resignFirstResponder];
    [self.Password resignFirstResponder];
}

- (void)initNetworkCommunication {
    NSLog(@"Initializing Socket...");
    //create input and output stream core foundation objects
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    //create the socket
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"98.204.99.45", 4356, &readStream, &writeStream);
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

- (void)loginToServerWithPassword:(NSString *)userNamePassword {
    
	NSString *loginString  = [NSString stringWithFormat:@"checkLogin:%@", userNamePassword];
    NSLog(loginString);
	NSData *data = [[NSData alloc] initWithData:[loginString dataUsingEncoding:NSASCIIStringEncoding]];
	[self.outputStream write:[data bytes] maxLength:[data length]];
}

- (void)loginToServerWithAuthkey:(NSString *)userNameAuthkey {
	NSString *loginString  = [NSString stringWithFormat:@"keyLogin:%@", userNameAuthkey];
	NSData *data = [[NSData alloc] initWithData:[loginString dataUsingEncoding:NSASCIIStringEncoding]];
	[self.outputStream write:[data bytes] maxLength:[data length]];
}
- (IBAction)didPressLogin:(id)sender {
    NSString *userNamePassword = [NSString stringWithFormat:@"%@%@%@", self.UserName.text, @",", self.Password.text];
    LoadingView * loader = [LoadingView loadSpinnerIntoView:self.view];
    [self loginToServerWithPassword:userNamePassword];
    [loader removeLoader];
}

- (IBAction)didPressNewUser:(id)sender {
    NSLog(@"You Pressed New User");
}


- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
	NSLog(@"stream event %i", streamEvent);
	
	switch (streamEvent) {
			
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"Space Available");
            break;
		case NSStreamEventHasBytesAvailable:
            
			if (theStream == self.inputStream) {
				
				uint8_t buffer[1024];
				int len;
				
				while ([self.inputStream hasBytesAvailable]) {
					len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
					if (len > 0) {
						
						NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
						
						if (nil != output) {
                            
							NSLog(@"server said: %@", output);
							[self messageReceived:output];
							
						}
					}
				}
			}
			break;
            
			
		case NSStreamEventErrorOccurred:
			
			NSLog(@"Can not connect to the host!");
			break;
			
		case NSStreamEventEndEncountered:
            
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
			
			break;
		default:
			NSLog(@"Unknown event");
	}
    
}

- (void) messageReceived:(NSString *)message {

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"WTF");
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"VIEW DID LOAD");
    [self initNetworkCommunication];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //check if the user has a stored username and authkey first
    //if they do, login immediately
    if(([defaults objectForKey:@"UserName"] != nil) && ([defaults objectForKey:@"AuthKey"] != nil)) {
        NSString *userNameAuthKey = [NSString stringWithFormat:@"%@%@%@", [defaults objectForKey:@"UserName"], @",", [defaults objectForKey:@"AuthKey"]];
        LoadingView * loader = [LoadingView loadSpinnerIntoView:self.view];
        [self loginToServerWithAuthkey:userNameAuthKey];
        [loader removeLoader];
        
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
