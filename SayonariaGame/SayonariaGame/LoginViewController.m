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

#pragma mark - loader methods
-(void)putLoaderInViewWithSplash:(BOOL)isSplash withFade:(BOOL)withFade{
    self.loader = [[LoadingView alloc] init];
    self.loader.delegate = self;
    self.loader = [self.loader loadSpinnerIntoView:self.view withSplash:isSplash withFade:withFade];
}

-(void)removeLoaderFromView{
    [self.loader removeLoader:self.view];
    self.loader = nil;
}

//figures out what to do with the message received from the server
-(void)messageRecieved:(NSString *)messageFromServer {
    //NSLog(@"server said: %@", messageFromServer);
    
    //grab the defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //if the server says 'done' it can be connecting, confirming the game type, etc
    if([[messageFromServer substringToIndex:4] isEqualToString:@"done"]){

        if (self.thisNetworkController.currentServerState == (ServerState *)ConnectedAwaitingLogon){
            //if we get an auth key back (done, >4 chars), the save it and log in
            //this means we have logged in with a user/pass
            if([messageFromServer length] > 4){
                NSLog(@"Logged in with Password!");
                [defaults setObject:[messageFromServer substringFromIndex:5] forKey:AUTH_KEY];
                [defaults synchronize];
                [self putLoaderInViewWithSplash:NO withFade:YES];
            } else {
                NSLog(@"New User Created Successfully");
            }
        } else if(self.thisNetworkController.currentServerState == (ServerState *)TryingAuthKeyLogin) {
            NSLog(@"Logged in with Auth Key!");
            [self showTabViewNotAnimated];
        } else{
            NSLog(@"Server 'done' message not interpreted");
        }
        
        //DO MORE STUFF HERE!
    } else if([messageFromServer isEqualToString:@"ANOTHER OUTPUT FROM THE SERVER"]) {
    } else if([messageFromServer isEqualToString:@"error"]){
        if(self.thisNetworkController.currentServerState == (ServerState *)ConnectedAwaitingLogon) {
            [self cannotLoginError];
            if(self.loader)[self removeLoaderFromView];
        } else if(self.thisNetworkController.currentServerState == (ServerState *)TryingAuthKeyLogin) {
            NSLog(@"Bad AuthKey");
            //remove splash screen or loader from view
            [self removeLoaderFromView];
            self.thisNetworkController.currentServerState = (ServerState *)ConnectedAwaitingLogon;
        }
    } else if([messageFromServer isEqualToString:@"CANNOT CONNECT"]){
        if (self.thisNetworkController.currentServerState == (ServerState *)FirstSocketFailed) {
            self.thisNetworkController.currentServerState = nil;
            if(self.loader)[self removeLoaderFromView];
            [self cannotConnectError];
        } else {
            self.thisNetworkController.currentServerState = (ServerState *)FirstSocketFailed;
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

#pragma mark - Initial loadup and other misc

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(self.thisNetworkController.currentServerState == nil) {
        [self.thisNetworkController initNetworkCommunication];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //set the delegates for the input boxes
    self.UserName.delegate = self;
    self.Password.delegate = self;
    
    //set up the buttons, texts, etc
    
    self.loginText.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.loginText.layer.shadowRadius = 4.0f;
    self.loginText.layer.shadowOpacity = .9;
    self.loginText.layer.shadowOffset = CGSizeZero;
    self.loginText.layer.masksToBounds = NO;

    self.registerText.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.registerText.layer.shadowRadius = 6.0f;
    self.registerText.layer.shadowOpacity = .9;
    self.registerText.layer.shadowOffset = CGSizeZero;
    self.registerText.layer.masksToBounds = NO;
    
    //UIImage *fieldBGImage = [[UIImage imageNamed:@"Text_Box_Back.png"]stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    //[self.Password setBackground:fieldBGImage];
    
    [self.loginText setFont:[UIFont fontWithName:@"Bauhaus 93" size:30]];
    [self.registerText setFont:[UIFont fontWithName:@"Bauhaus 93" size:17]];
    [self.usernameText setFont:[UIFont fontWithName:@"Bauhaus 93" size:17]];
    [self.passwordText setFont:[UIFont fontWithName:@"Bauhaus 93" size:17]];
    [self.loginButton.titleLabel setFont:[UIFont fontWithName:@"Bauhaus 93" size:20]];
    //self.UserName.background = [UIImage imageNamed:@"Text_Box_Back.png"];
    //self.Password.background = [[UIImage imageNamed:@"Text_Box_Back.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    [self.UserName setFont:[UIFont fontWithName:@"Bauhaus 93" size:17]];
    [self.Password setFont:[UIFont fontWithName:@"Bauhaus 93" size:17]];
    
    //create the network controller
    NetworkController *tempController = [[NetworkController alloc] init];
    self.thisNetworkController = tempController;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkConn:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
}

-(void)checkConn:(NSNotification *)notification {
    [self.thisNetworkController checkConnection];
}

-(void)viewWillAppear:(BOOL)animated{
    self.UserName.text = @"";
    self.Password.text = @"";
    self.thisNetworkController.delegate = self;
    if(self.loader)[self removeLoaderFromView];
    if(self.thisNetworkController.currentServerState == nil){
        //put the splash image on the screen
        [self putLoaderInViewWithSplash:YES withFade:NO];
        //initialize network communications
        [self.thisNetworkController initNetworkCommunication];
    } else if(self.thisNetworkController.currentServerState == (ServerState *)SigningOut){
        //put the loader on the screen
        [self putLoaderInViewWithSplash:NO withFade:NO];
        //initialize network communications
        [self.thisNetworkController initNetworkCommunication];
    }
}

-(void)loaderIsOnScreen{
    [self showTabViewNotAnimated];
    NSLog(@"Delegate Called");
}


-(void)showTabViewNotAnimated{
    //create the tabBarView from the storyboard
    NetworkStorageTabBarController *newController = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBarView"];
    
    //transfer the networking controls
    newController.thisNetworkController = self.thisNetworkController;
    
    //segue!
    [self.navigationController pushViewController:newController animated:NO];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString: @"showNewUserScreen"]){
        NewUserViewController *newUserController = (NewUserViewController *)segue.destinationViewController;
        newUserController.delegate = self;
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    if(self.loader)[self removeLoaderFromView];
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
