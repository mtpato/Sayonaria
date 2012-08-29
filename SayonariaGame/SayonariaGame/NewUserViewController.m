//
//  NewUserViewController.m
//  SayonariaGame
//
//  Created by Ian Pytlarz on 8/27/12.
//
//

#import "NewUserViewController.h"
#import "LoginViewController.h"

@interface NewUserViewController ()

@end

@implementation NewUserViewController
@synthesize userName = _userName;
@synthesize password = _password;
@synthesize confirmPassword = _confirmPassword;
@synthesize email = _email;
@synthesize delegate = _delegate;

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([textField.text length]){
        [textField resignFirstResponder];
        return YES;
    } else {
        return NO;
    }
}

- (IBAction)cancelPressed:(id)sender {
    [self.delegate removeNewUserViewController];
}
- (IBAction)createPressed:(id)sender {
    NSString *newUserCommand = [NSString stringWithFormat:@"%@%@%@%@%@%@",@"newUser:",self.userName.text,@",",self.password.text,@",",self.email.text];
    [self.delegate sendUserToServer:newUserCommand];
    [self.delegate removeNewUserViewController];
}
- (IBAction)backgroundPressed:(id)sender {
    [self.userName resignFirstResponder];
    [self.password resignFirstResponder];
    [self.confirmPassword resignFirstResponder];
    [self.email resignFirstResponder];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userName.delegate = self;
    self.password.delegate = self;
    self.confirmPassword.delegate = self;
    self.email.delegate = self;
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setUserName:nil];
    [self setPassword:nil];
    [self setConfirmPassword:nil];
    [self setEmail:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
