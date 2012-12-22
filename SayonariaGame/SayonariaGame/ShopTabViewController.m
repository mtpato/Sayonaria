//
//  ShopTabViewController.m
//  SayonariaGame
//
//  Created by Ian Pytlarz on 9/15/12.
//
//

#import "ShopTabViewController.h"

@interface ShopTabViewController ()
@property (nonatomic, strong) UIImageView *fadeImage;
@end

@implementation ShopTabViewController

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
}
-(void)putLoaderInView{
    
}
-(void)removeLoaderFromView{
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    //set up networking
    NetworkStorageTabBarController *thisTabBar = (NetworkStorageTabBarController *) self.tabBarController;
    self.thisNetworkController = thisTabBar.thisNetworkController;
    self.thisNetworkController.delegate = self;

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
    [self addSmallFade:0];
}

- (IBAction)optionsPressed {
    [self addSmallFade:2];
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


@end
