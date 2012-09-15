//
//  ShopTabViewController.m
//  SayonariaGame
//
//  Created by Ian Pytlarz on 9/15/12.
//
//

#import "ShopTabViewController.h"

@interface ShopTabViewController ()

@end

@implementation ShopTabViewController

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
    self.tabBarController.tabBar.hidden = YES;
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

#pragma mark - Tab Bar Navigation

- (IBAction)gamesPressed {
    self.tabBarController.selectedIndex = 0;
}

- (IBAction)optionsPressed {
    self.tabBarController.selectedIndex = 2;
}


@end
