//
//  LoginViewController.m
//  SayonariaGame
//
//  Created by Ian Pytlarz on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

-(IBAction)didPressLogin:(id)sender{
    LoadingView * loader = [LoadingView loadSpinnerIntoView:self.view];
    [NSTimer scheduledTimerWithTimeInterval:2.0 
                                     target:loader
                                   selector:@selector(removeLoader)
                                   userInfo:nil repeats:NO];
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
	// Do any additional setup after loading the view.
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
