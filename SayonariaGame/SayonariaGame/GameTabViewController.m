//
//  GameTabViewController.m
//  SayonariaGame
//
//  Created by Ian Pytlarz on 9/1/12.
//
//

#import "GameTabViewController.h"

@interface GameTabViewController ()

@end

@implementation GameTabViewController



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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.networkController = (NetworkController *) [defaults objectForKey:NETWORK_CONTROLLER_KEY];
    [self.networkController sendMessageToServer:@"getGames"];
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
