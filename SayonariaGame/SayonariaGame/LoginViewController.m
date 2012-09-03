//
//  LoginViewController.m
//  SayonariaGame
//
//  Created by Ian Pytlarz on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController()
@property (nonatomic, weak) LoadingView * loader;
@end

@implementation LoginViewController
@synthesize alert = _alert;

#pragma mark - delegate methods
-(void)putLoaderInView{
    self.loader = [LoadingView loadSpinnerIntoView:self.view];
}
-(void)removeLoaderFromView{
    [self.loader removeLoader];
}
-(void)segueLoginToTabBar{
    [self performSegueWithIdentifier:@"showTabView" sender:self];
}
-(void)setCurrentServerStateConnecting{
    self.currentServerState = (ServerState *)Connecting;
}

//figures out what to do with the message received from the server
-(void)messageRecieved:(NSString *)messageFromServer {
    NSLog(@"server said: %@", messageFromServer);
    
    //grab the defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //if the server says 'done' it can be connecting, confirming the game type, etc
    if([[messageFromServer substringToIndex:4] isEqualToString:@"done"]){
        
        //if we have JUST connected, send the game type to the server
        if(self.currentServerState == (ServerState *)Connecting){
            self.currentServerState = (ServerState *)SendingGameType;
            [self.thisNetworkController sendMessageToServer:@"tileGame"];
            //if we have sent in the game type, try logging in with a pre existing auth key
        } else if(self.currentServerState == (ServerState *)SendingGameType){
            self.currentServerState = (ServerState *)ConnectedAwaitingLogon;
            [self loginToServerWithAuthkey];
            //remove the initial loading screen
            [self.loader removeLoader];
            //if the recieved message has an auth key, set the auth key and login
            //Otherwise a new user was created woohoo
        } else if (self.currentServerState == (ServerState *)ConnectedAwaitingLogon){
            if([messageFromServer length] > 4){
                [defaults setObject:[messageFromServer substringFromIndex:5] forKey:AUTH_KEY];
                [defaults synchronize];
                [self performSegueWithIdentifier:@"showTabView" sender:self];
            } else {
                NSLog(@"New User Created Successfully");
            }
        } else if(self.currentServerState == (ServerState *)TryingAuthKeyLogin) {
            NSLog(@"Logged in!");
            self.currentServerState = (ServerState *)InTabView;
            [self performSegueWithIdentifier:@"showTabView" sender:self];
        } else{
            NSLog(@"Server 'done' message not interpreted");
        }
        
        //DO MORE STUFF HERE!
    } else if([messageFromServer isEqualToString:@"ANOTHER OUTPUT FROM THE SERVER"]) {
    } else if([messageFromServer isEqualToString:@"error"]){
        if(self.currentServerState == (ServerState *)ConnectedAwaitingLogon) {
            self.alert.title = @"Cannot Log In";
            self.alert.message = @"Invalid username/password";
            [self.alert show];
            [self.loader removeLoader];
        } else if(self.currentServerState == (ServerState *)TryingAuthKeyLogin) {
            NSLog(@"Bad AuthKey");
            self.currentServerState = (ServerState *)ConnectedAwaitingLogon;
        }
    } else if([messageFromServer isEqualToString:@"SOCKETS CLOSED"] || [messageFromServer isEqualToString:@"CANNOT CONNECT"]){
        self.currentServerState = nil;
        self.alert = [[UIAlertView alloc]
                      initWithTitle: @"Cannot Access Server"
                      message: @"Error 37: There was a problem accessing the server"
                      delegate: self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil];
        [self.alert show];
    }else {
        NSLog(@"Unknown Server Message");
    }
}

#pragma mark - user interface for logon screen

//if a user is on a keyboard, this will make the keyboard go away if they click off the keyboard
- (IBAction)BackgroundClicked:(id)sender {
    [self.UserName resignFirstResponder];
    [self.Password resignFirstResponder];
}

//Passes the user name and password typed on screen to the server for a login
- (IBAction)didPressLogin:(id)sender {
    if([self.UserName.text length] == 0 || [self.Password.text length] == 0){
        self.alert.title = @"Cannot Log In";
        self.alert.message = @"You must enter a username and password";
        [self.alert show];
    } else {
        //set the user name as the default user name
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.UserName.text forKey:USER_NAME];
        [defaults synchronize];
        
        NSString *userNamePassword = [NSString stringWithFormat:@"%@%@%@", self.UserName.text, @",", self.Password.text];
        self.loader = [LoadingView loadSpinnerIntoView:self.view];
        [self loginToServerWithPassword:userNamePassword];
    }
}

//brings up the new user screen
- (IBAction)didPressNewUser:(id)sender {
}

//remove the new user screen
-(void)removeNewUserViewController{
    [self dismissModalViewControllerAnimated:YES];
}

//make the return key resign first responder
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([textField.text length]){
        [textField resignFirstResponder];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Network Communication



-(void)sendUserToServer:(NSString *)newUserCommand{
    [self.thisNetworkController sendMessageToServer:newUserCommand];
}

//creates a string with the proper syntax to log in using a password. will get an authkey back
- (void)loginToServerWithPassword:(NSString *)userNamePassword {
	NSString *loginString  = [NSString stringWithFormat:@"login:%@", userNamePassword];
    [self.thisNetworkController sendMessageToServer:loginString];
}

//check if the user has a stored username and authkey. if they do, login
- (void)loginToServerWithAuthkey {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(([defaults objectForKey:USER_NAME] != nil) && ([defaults objectForKey:AUTH_KEY] != nil)) {
        self.currentServerState = (ServerState *)TryingAuthKeyLogin;
        NSString *loginString = [NSString stringWithFormat:@"%@%@%@%@", @"keyLogin:",[defaults objectForKey:USER_NAME], @",", [defaults objectForKey:AUTH_KEY]];
        [self.thisNetworkController sendMessageToServer:loginString];
    }
}

#pragma mark - Initial loadup and other misc

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(self.currentServerState == nil) {
        [self.thisNetworkController initNetworkCommunication];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.UserName.text = @"";
    self.Password.text = @"";
    self.UserName.delegate = self;
    self.Password.delegate = self;
    
    [self performSegueWithIdentifier:@"showTabView" sender:self];
    
    if(self.currentServerState == nil){
        //initialize network communications
        NetworkController *tempController = [[NetworkController alloc] init];
        self.thisNetworkController = tempController;
        self.thisNetworkController.delegate = self;
        [self.thisNetworkController initNetworkCommunication];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString: @"showNewUserScreen"]){
        NewUserViewController *newUserController = (NewUserViewController *)segue.destinationViewController;
        newUserController.delegate = self;
    }
    if([segue.identifier isEqualToString: @"showTabView"]){
        NetworkStorageTabBarController *newController = (NetworkStorageTabBarController *) segue.destinationViewController;
        newController.thisNetworkController = self.thisNetworkController;
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
