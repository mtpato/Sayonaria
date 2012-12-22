//
//  OptionsTabViewController.m
//  SayonariaGame
//
//  Created by Ian Pytlarz on 9/15/12.
//
//

#import "OptionsTabViewController.h"

@interface OptionsTabViewController ()
@property (nonatomic, strong) UIImageView *fadeImage;
@end

@implementation OptionsTabViewController

#pragma mark - Network Communication

-(void)messageRecieved:(NSString *)messageFromServer{
    //HANDLE COMING BACK FROM BEING AWAY
    //if the server says 'done' it can be connecting, confirming the game type, etc
    if([[messageFromServer substringToIndex:4] isEqualToString:@"done"]){
        if(self.thisNetworkController.currentServerState == (ServerState *)TryingAuthKeyLogin){
            self.thisNetworkController.currentServerState = (ServerState *)InTabView;
            //request...store stuff!
        }
    } else if([messageFromServer isEqualToString:@"SOCKETS CLOSED"] || [messageFromServer isEqualToString:@"error"] || [messageFromServer isEqualToString:@"CANNOT CONNECT"]){
        self.thisNetworkController.currentServerState = (ServerState *)Connecting;
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    //DO NORMAL SCREEN MESSAGE HANDLING

    if(self.thisNetworkController.currentServerState = (ServerState *)SigningOut){
        [self.thisNetworkController closeNetworkCommunication];
        LoginViewController *ourRootView = [self.navigationController.viewControllers objectAtIndex:0];
        ourRootView.thisNetworkController = self.thisNetworkController;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *blankKey = @"BLANK";
        [defaults setObject:blankKey forKey:AUTH_KEY];
        [defaults synchronize];
    }
}

#pragma mark - Loader

-(void)putLoaderInViewWithSplash:(BOOL)isSplash{
    self.loader = [[LoadingView alloc] init];
    self.loader.delegate = self;
    self.loader = [self.loader loadSpinnerIntoView:self.view withSplash:isSplash withFade:YES];
}

-(void)removeLoaderFromView{
    [self.loader removeLoader:self.view];
    self.loader = nil;
}


#pragma mark - Loading the View

-(void)loaderIsOnScreen{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

-(void)viewDidAppear:(BOOL)animated {
    
    //set up networking
    NetworkStorageTabBarController *thisTabBar = (NetworkStorageTabBarController *) self.tabBarController;
    self.thisNetworkController = thisTabBar.thisNetworkController;
    self.thisNetworkController.delegate = self;
    
}

-(void)viewWillAppear:(BOOL)animated{
    CGRect screenBounds =[[UIScreen mainScreen] bounds];
    CGSize screenDimensions = screenBounds.size;
    
    UIImage *backgroundImage = [UIImage imageNamed:@"BlankFancyBackIphone@2x.png"];
    self.fadeImage = [[UIImageView alloc] initWithImage:backgroundImage];
    
    [self.fadeImage setFrame:CGRectMake(0, 0, screenDimensions.width,screenDimensions.height)];
    [self.view addSubview:self.fadeImage];
    [UIImageView animateWithDuration:0.35
                          animations:^{self.fadeImage.alpha = 0.0;}
                          completion:^(BOOL finished){}];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tabBarController.tabBar.hidden = YES;
   [self.signOutButton.titleLabel setFont:[UIFont fontWithName:@"Bauhaus 93" size:20]];
}


#pragma mark - User Interaction

- (IBAction)signOutPressed {
    [self.thisNetworkController setCurrentServerState:(ServerState *)SigningOut];
    [self.thisNetworkController sendMessageToServer:@"signOut"];
    [self putLoaderInViewWithSplash:NO];
}

#pragma mark - Tab Bar Navigation

- (IBAction)gamesPressed {
    [self addSmallFade:0];
}

- (IBAction)shopPressed {
    [self addSmallFade:1];
}

-(void)addSmallFade:(NSUInteger)viewIndex {
    CGRect screenBounds =[[UIScreen mainScreen] bounds];
    CGSize screenDimensions = screenBounds.size;
    
    UIImage *backgroundImage = [UIImage imageNamed:@"BlankFancyBackIphone@2x.png"];
    self.fadeImage = [[UIImageView alloc] initWithImage:backgroundImage];
    self.fadeImage.alpha = 0.0;
    
    [self.fadeImage setFrame:CGRectMake(0, 0, screenDimensions.width,screenDimensions.height)];
    
    [self.view addSubview:self.fadeImage];
    
    [UIImageView animateWithDuration:0.35
                          animations:^{self.fadeImage.alpha = 1.0;}
                          completion:^(BOOL finished){
                              [self removeFade:viewIndex];
                          }];
}

-(void)removeFade:(NSUInteger)viewIndex{
    self.tabBarController.selectedIndex = viewIndex;
    [self.fadeImage removeFromSuperview];
    self.fadeImage = nil;
}

#pragma mark - Crap I Don't Use!

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

@end
