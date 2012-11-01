//
//  GameTabViewController.m
//  SayonariaGame
//
//  Created by Ian Pytlarz on 9/1/12.
//
//

#import "GameTabViewController.h"

#define GAME_ID @"GameID"
#define OPPONENT_NAME @"OpponentName"


@interface GameTabViewController ()
@property (nonatomic) ServerState *currentServerState;
@property (nonatomic,weak) IBOutlet UITextField *OpponentName;
@property (nonatomic) IBOutlet UITableView *gameTableView;
@property (nonatomic, strong) NSArray *thisUsersGames;
@property (nonatomic, strong) NSString *createdGameOpponent;
@property (nonatomic, strong) UIImageView *fadeImage;
@property (nonatomic, strong) UITableViewCell *selectedCell;
@end

@implementation GameTabViewController

#pragma mark - loader methods

-(void)putLoaderInViewWithSplash:(BOOL)isSplash withFade:(BOOL)isFade{
    self.loader = [[LoadingView alloc] init];
    self.loader.delegate = self;
    self.loader = [self.loader loadSpinnerIntoView:self.view withSplash:isSplash withFade:isFade];
}

-(void)loaderIsOnScreen {
    [self showGameScreenNotAnimated:self.selectedCell];
}

-(void)removeLoaderFromView{
    [self.loader removeLoader:self.view];
    self.loader = nil;
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

#pragma mark - network communications

-(void)messageRecieved:(NSString *)messageFromServer{
    NSLog(@"server said: %@", messageFromServer);
    //if the server says 'done' it can be connecting, confirming the game type, etc
    if([[messageFromServer substringToIndex:4] isEqualToString:@"done"]){
        if(self.thisNetworkController.currentServerState == (ServerState *)TryingAuthKeyLogin){
            self.thisNetworkController.currentServerState = (ServerState *)InTabView;
            //request the games list for the table
            [self.thisNetworkController sendMessageToServer:@"getGames"];
        }
        if([messageFromServer isEqualToString:@"done:gameCreated"]){
            [self showGameScreenNotAnimated:@"New Game"];
            //[self performSegueWithIdentifier:@"showGameScreen" sender:@"New Game"];
        }
    }
    if([messageFromServer length] > 4){
        if([[messageFromServer substringToIndex:5] isEqualToString:@"games"]){
            if([messageFromServer isEqualToString:@"games"]){}else{
                [self parseGames:[messageFromServer substringFromIndex:6]];
                [self.gameTableView reloadData];
            }
        }
    }
}

-(void)parseGames:(NSString *)gamesString{
    //figure out who the current user is
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentUser = [defaults objectForKey:USER_NAME];
    //get an array of the individual game strings
    NSArray *individualGames = [gamesString componentsSeparatedByString:@","];
    NSMutableArray *gameDictionaries = [[NSMutableArray alloc] initWithCapacity:[individualGames count]];
    
    int x;
    for (x = 0;x < [individualGames count]; x++)
    {
        //declare and make pieces we'll need
        NSMutableDictionary *tempGameDict = [[NSMutableDictionary alloc] init];
        NSArray *partsOfGameString = [[individualGames objectAtIndex:x] componentsSeparatedByString:@"|"];
        NSArray *partsOfUserName1 = [[partsOfGameString objectAtIndex:1] componentsSeparatedByString:@"-"];
        NSArray *partsOfUserName2 = [[partsOfGameString objectAtIndex:2] componentsSeparatedByString:@"-"];
        NSString *userName1 = [partsOfUserName1 objectAtIndex:0];
        NSString *userName2 = [partsOfUserName2 objectAtIndex:0];
        
        //set up the dictionary object for the game
        [tempGameDict setObject:[partsOfGameString objectAtIndex:0] forKey:GAME_ID];
        if([currentUser isEqualToString:userName1]){
            [tempGameDict setObject:userName2 forKey:OPPONENT_NAME];
        } else {
            [tempGameDict setObject:userName1 forKey:OPPONENT_NAME];
        }
        
        //add the dictionary to the games array
        [gameDictionaries addObject:tempGameDict];
    }
    
    //set the games array equal to the array we've made
    self.thisUsersGames = [gameDictionaries copy];
    
}

#pragma mark - actions and tab bar navigation

- (IBAction)newGamePressed:(id)sender {
    NSString *messageForServer = @"newGame:";
    messageForServer = [messageForServer stringByAppendingString:self.OpponentName.text];
    self.createdGameOpponent = self.OpponentName.text;
    [self.thisNetworkController sendMessageToServer:messageForServer];
}

- (IBAction)shopPressed {
    [self addSmallFade:1];
}

- (IBAction)optionsPressed:(id)sender {
    [self addSmallFade:2];
}

#pragma mark - table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows for the given the section
    NSUInteger total = [self.thisUsersGames count];
    if(self.thisUsersGames == nil) {
        total = 1;
    }
    return total;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"GameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *opponentNameLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *gameIDLabel = (UILabel *)[cell viewWithTag:2];
    
    //set up the background of the cell
    UIImageView *cellBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Game_Table_Cell.png"]];
    cell.backgroundView = cellBackground;
    
    //set up the thumbnail image of the cell
    //cell.imageView.image = [UIImage imageNamed:@"THUMBNAILIMAGEHERE.png"];
    
    opponentNameLabel.font = [UIFont fontWithName:@"Bauhaus 93" size:20];
    gameIDLabel.font = [UIFont fontWithName:@"Bauhaus 93" size:15];
	// Extract the game informaton
    
    if(self.thisUsersGames == nil){
        opponentNameLabel.text = @"No Games!";
        gameIDLabel.text = @"Some stuff about the game";
    } else
        if(indexPath.row <=[self.thisUsersGames count]) {
            NSDictionary *gameDictionary = [self.thisUsersGames objectAtIndex:(indexPath.row)];
            //NSString *gameID = [gameDictionary objectForKey:GAME_ID];
            NSString *opponentName = [gameDictionary objectForKey:OPPONENT_NAME];
            
            opponentNameLabel.text = opponentName;
            gameIDLabel.text = @"Some stuff about the game";
        }
    return cell;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [tableView cellForRowAtIndexPath:indexPath];
    self.selectedCell = cell;
    //put the Loader into the view
    [self putLoaderInViewWithSplash:NO withFade:YES];
}

#pragma mark - loading and other

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    //get rid of the blank tab bar
    CGRect fullScreen = [[UIScreen mainScreen] bounds];
    ((UITabBarController *)self.parentViewController).tabBar.hidden = YES;
    [[((UITabBarController *)self.parentViewController).view.subviews objectAtIndex:0] setFrame:fullScreen];
    
    //set up networking
    NetworkStorageTabBarController *thisTabBar = (NetworkStorageTabBarController *) self.tabBarController;
    self.thisNetworkController = thisTabBar.thisNetworkController;
    self.thisNetworkController.delegate = self;
    
    if(self.thisNetworkController.currentServerState == (ServerState *)TryingAuthKeyLogin){
        //put in splash screen
        [self putLoaderInViewWithSplash:YES withFade:NO];
        //tell the network we are going to be in the main views
        self.thisNetworkController.currentServerState = (ServerState *)InTabView;
    } else if(self.thisNetworkController.currentServerState == (ServerState *)ConnectedAwaitingLogon){
        //put in spinner
        [self putLoaderInViewWithSplash:NO withFade:NO];
        //tell the network we are going to be in the main views
        self.thisNetworkController.currentServerState = (ServerState *)InTabView;
    } else if(self.thisNetworkController.currentServerState == (ServerState *)InTabView) {
        //Do the fade from another menu screen
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
    
}

-(void)viewDidAppear:(BOOL)animated{
    //get rid of the loader if one is up
    if(self.loader) [self removeLoaderFromView];
    
    //set up the table itself
    self.gameTableView.dataSource = self;
    self.gameTableView.delegate = self;
    [self.gameTableView reloadData];
    
    //request the games list for the table
    [self.thisNetworkController sendMessageToServer:@"getGames"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //the first time the view is loaded, we are probably coming from the login screen, so hide the tabbar for a smoother transition
    self.tabBarController.tabBar.hidden = YES;
    
    [self.gameNewButton.titleLabel setFont:[UIFont fontWithName:@"Bauhaus 93" size:20]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkConn:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
}

-(void)checkConn:(NSNotification *)notification {
    [self.thisNetworkController checkConnection];
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

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - segue

-(void)showGameScreenNotAnimated:(id)cellOrString{
    
    //create the tabBarView from the storyboard
    GameScreenViewController *newGameScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"gameScreen"];
    
    //transfer the networking controls
    newGameScreen.thisNetworkController = self.thisNetworkController;
    
    //pass appropriate game information
    static NSString *CellIdentifier = @"GameCell";
    UITableViewCell *cell = [self.gameTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = cellOrString;
    newGameScreen.opponentName = cell.textLabel.text;
    newGameScreen.gameID = cell.detailTextLabel.text;
    
    //segue!
    [self.navigationController pushViewController:newGameScreen animated:NO];
}

@end
