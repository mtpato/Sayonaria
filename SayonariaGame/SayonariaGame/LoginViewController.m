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

#pragma mark - delegate methods
-(void)putLoaderInView{
    self.loader = [LoadingView loadSpinnerIntoView:self.view];
}
-(void)removeLoaderFromView{
    [self.loader removeLoader:self.view];
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
            
            /*****PAY ATTENTION HERE*****/
            /*****PAY ATTENTION HERE*****/
            /*****PAY ATTENTION HERE*****/
            
            [self loginToServerWithAuthkey];
                /***** COMMENT THE BELOW LINE IN
                AND THE ABOVE LINE OUT
                 WHEN NEEDING THE LOGIN SCREEN*****/
            //[self removeLoaderFromView];

            /*****STOP PAYING ATTENTION HERE*****/
            /*****STOP PAYING ATTENTION HERE*****/
            /*****STOP PAYING ATTENTION HERE*****/
            
            //if the recieved message has an auth key, set the auth key and login
            //Otherwise a new user was created woohoo
        } else if (self.currentServerState == (ServerState *)ConnectedAwaitingLogon){
            if([messageFromServer length] > 4){
                NSLog(@"Logged in!");
                [defaults setObject:[messageFromServer substringFromIndex:5] forKey:AUTH_KEY];
                [defaults synchronize];
                [self showTabViewNotAnimated];
            } else {
                NSLog(@"New User Created Successfully");
            }
        } else if(self.currentServerState == (ServerState *)TryingAuthKeyLogin) {
            NSLog(@"Logged in!");
            [self showTabViewNotAnimated];
        } else{
            NSLog(@"Server 'done' message not interpreted");
        }
        
        //DO MORE STUFF HERE!
    } else if([messageFromServer isEqualToString:@"ANOTHER OUTPUT FROM THE SERVER"]) {
    } else if([messageFromServer isEqualToString:@"error"]){
        if(self.currentServerState == (ServerState *)ConnectedAwaitingLogon) {
            [self cannotLoginError];
            [self removeLoaderFromView];
        } else if(self.currentServerState == (ServerState *)TryingAuthKeyLogin) {
            NSLog(@"Bad AuthKey");
            [self removeLoaderFromView];
            self.currentServerState = (ServerState *)ConnectedAwaitingLogon;
        }
    } else if([messageFromServer isEqualToString:@"CANNOT CONNECT"]){
        if (self.currentServerState == (ServerState *)FirstSocketFailed) {
            self.currentServerState = nil;
            [self cannotConnectError];
        } else {
            self.currentServerState = (ServerState *)FirstSocketFailed;
        }
    }else if ([messageFromServer isEqualToString:@"SOCKETS CLOSED"]){
        [self cannotConnectError];
    } else {
        NSLog(@"Unknown Server Message");
    }
}

-(void) cannotConnectError {
    UIAlertView *cannotConnectAlert = [[UIAlertView alloc]
                  initWithTitle: @"Cannot Access Server"
                  message: @"Error 37: There was a problem accessing the server"
                  delegate: self
                  cancelButtonTitle:@"OK"
                  otherButtonTitles:nil];
    [cannotConnectAlert show];
}

-(void) cannotLoginError {
    UIAlertView *cannotConnectAlert = [[UIAlertView alloc]
                                       initWithTitle: @"Cannot Log In"
                                       message: @"Invalid Username or Password"
                                       delegate: self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [cannotConnectAlert show];
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
        [self cannotLoginError];
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
    [self.registerButton.titleLabel setFont:[UIFont fontWithName:@"Bauhaus 93" size:20]];
    [self.loginButton.titleLabel setFont:[UIFont fontWithName:@"Bauhaus 93" size:20]];
    
    if(self.currentServerState == nil){
        //initialize network communications
        NetworkController *tempController = [[NetworkController alloc] init];
        self.thisNetworkController = tempController;
        self.thisNetworkController.delegate = self;
        [self.thisNetworkController initNetworkCommunication];
    }
}

-(void)showTabViewNotAnimated{
    //put the Loader into the view
    if (self.currentServerState != (ServerState *)TryingAuthKeyLogin){
        [self putLoaderInView];}
    
    //create the tabBarView from the storyboard
    NetworkStorageTabBarController *newController = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBarView"];
    
    //transfer the networking controls
    newController.thisNetworkController = self.thisNetworkController;
    
    //segue!
    [self.navigationController pushViewController:newController animated:NO];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.currentServerState = (ServerState *)InTabView;
    if([segue.identifier isEqualToString: @"showNewUserScreen"]){
        NewUserViewController *newUserController = (NewUserViewController *)segue.destinationViewController;
        newUserController.delegate = self;
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
