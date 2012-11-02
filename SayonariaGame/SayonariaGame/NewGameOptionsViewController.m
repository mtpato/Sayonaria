//
//  NewGameOptionsViewController.m
//  SayonariaGame
//
//  Created by Ian Pytlarz on 11/1/12.
//
//

#import "NewGameOptionsViewController.h"

@interface NewGameOptionsViewController ()
@property (nonatomic, strong) UIImageView *fadeImage;
@end

@implementation NewGameOptionsViewController

@synthesize thisNetworkController;

#pragma mark - loader methods

-(void)putLoaderInViewWithSplash:(BOOL)isSplash withFade:(BOOL)isFade{
    self.loader = [[LoadingView alloc] init];
    self.loader.delegate = self;
    self.loader = [self.loader loadSpinnerIntoView:self.view withSplash:isSplash withFade:isFade];
}

-(void)loaderIsOnScreen {
    [self showGameScreen];
}

-(void)removeLoaderFromView{
    [self.loader removeLoader:self.view];
    self.loader = nil;
}

#pragma mark - buttons

- (IBAction)backgroundPressed {
    [self.opponentNameBox resignFirstResponder];
}

- (IBAction)opponentPressed {
     NSString *messageForServer = @"newGame:";
     messageForServer = [messageForServer stringByAppendingString:self.opponentNameBox.text];
     [self.thisNetworkController sendMessageToServer:messageForServer];
}

-(void)messageRecieved:(NSString *)messageFromServer{
    if([messageFromServer isEqualToString:@"done:gameCreated"]){
        [self putLoaderInViewWithSplash:NO withFade:YES];
    }
}

-(void)showGameScreen{
    
    //create the game screen from the storyboard
    GameScreenViewController *newGameScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"gameScreen"];
    
    //transfer the networking controls
    newGameScreen.thisNetworkController = self.thisNetworkController;
    
    //pass appropriate game information
/*
    newGameScreen.opponentName = cell.textLabel.text;
    newGameScreen.gameID = cell.detailTextLabel.text;
*/
    //segue!
    [self.navigationController pushViewController:newGameScreen animated:NO];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidLoad {
    self.orLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.orLabel.layer.shadowRadius = 6.0f;
    self.orLabel.layer.shadowOpacity = .9;
    self.orLabel.layer.shadowOffset = CGSizeZero;
    self.orLabel.layer.masksToBounds = NO;
    [self.orLabel setFont:[UIFont fontWithName:@"Bauhaus 93" size:17]];
    
    self.opponentTypeLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.opponentTypeLabel.layer.shadowRadius = 6.0f;
    self.opponentTypeLabel.layer.shadowOpacity = .9;
    self.opponentTypeLabel.layer.shadowOffset = CGSizeZero;
    self.opponentTypeLabel.layer.masksToBounds = NO;
    [self.opponentTypeLabel setFont:[UIFont fontWithName:@"Bauhaus 93" size:17]];
    
    [self.opponentNameBox setFont:[UIFont fontWithName:@"Bauhaus 93" size:17]];
    self.opponentNameBox.delegate = self;
    [self.opponentButton.titleLabel setFont:[UIFont fontWithName:@"Bauhaus 93" size:20]];
    [self.randomButton.titleLabel setFont:[UIFont fontWithName:@"Bauhaus 93" size:20]];
}

-(void)viewWillAppear
{
    CGRect screenBounds =[[UIScreen mainScreen] bounds];
    CGSize screenDimensions = screenBounds.size;
    
    UIImage *backgroundImage = [UIImage imageNamed:@"BlankFancyBackIphone@2x.png"];
    self.fadeImage = [[UIImageView alloc] initWithImage:backgroundImage];
    
    [self.fadeImage setFrame:CGRectMake(0, 0, screenDimensions.width,screenDimensions.height)];
    [self.view addSubview:self.fadeImage];
    [UIImageView animateWithDuration:0.35
                          animations:^{self.fadeImage.alpha = 0.0;}
                          completion:^(BOOL finished){}];

    self.thisNetworkController.delegate = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

@end
