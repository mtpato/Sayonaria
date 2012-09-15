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
@end

@implementation GameTabViewController

#pragma mark - server Communications and delegate methods

-(void)putLoaderInView{
    self.loader = [LoadingView loadSpinnerIntoView:self.view];
}

-(void) removeLoaderFromView{
    [self.loader removeLoader:self.view];
}

-(void)messageRecieved:(NSString *)messageFromServer{
    NSLog(@"server said: %@", messageFromServer);
    //if the server says 'done' it can be connecting, confirming the game type, etc
    if([[messageFromServer substringToIndex:4] isEqualToString:@"done"]){
        if([messageFromServer isEqualToString:@"done:gameCreated"]){
            [self showGameScreenNotAnimated:@"New Game"];
            //[self performSegueWithIdentifier:@"showGameScreen" sender:@"New Game"];
        }
    }
    if([[messageFromServer substringToIndex:5] isEqualToString:@"games"]){
        [self parseGames:[messageFromServer substringFromIndex:6]];
        [self.gameTableView reloadData];
        [self removeLoaderFromView];
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
    self.tabBarController.selectedIndex = 1;
}

- (IBAction)optionsPressed:(id)sender {
    self.tabBarController.selectedIndex = 2;
}

#pragma mark - table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows for the given the section
    NSUInteger total = [self.thisUsersGames count];
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
//    UIView *backgroundView = [[UIView alloc] initWithFrame: cell.frame];
//    backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Game_Table_Cell.png"]];
    cell.backgroundView = cellBackground;
    
    //set up the thumbnail image of the cell
    //cell.imageView.image = [UIImage imageNamed:@"THUMBNAILIMAGEHERE.png"];
    
	// Extract the game informaton
    if(indexPath.row <=[self.thisUsersGames count]) {
        NSDictionary *gameDictionary = [self.thisUsersGames objectAtIndex:(indexPath.row)];
        //NSString *gameID = [gameDictionary objectForKey:GAME_ID];
        NSString *opponentName = [gameDictionary objectForKey:OPPONENT_NAME];
    
        opponentNameLabel.font = [UIFont fontWithName:@"Bauhaus 93" size:30];
        opponentNameLabel.text = opponentName;
        gameIDLabel.font = [UIFont fontWithName:@"Bauhaus 93" size:15];
        gameIDLabel.text = @"Some stuff about the game";
    }
    return cell;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [tableView cellForRowAtIndexPath:indexPath];
    [self showGameScreenNotAnimated:cell];
    //[self performSegueWithIdentifier:@"showGameScreen" sender:cell];
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
        CGRect fullScreen = [[UIScreen mainScreen] bounds];
    ((UITabBarController *)self.parentViewController).tabBar.hidden = YES;
    [[((UITabBarController *)self.parentViewController).view.subviews objectAtIndex:0] setFrame:fullScreen];
    
    [self putLoaderInView];
}

-(void)viewDidAppear:(BOOL)animated{

    //set up networking
    NetworkStorageTabBarController *thisTabBar = (NetworkStorageTabBarController *) self.tabBarController;
    self.thisNetworkController = thisTabBar.thisNetworkController;
    self.thisNetworkController.delegate = self;
    
    
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
    
    /*
    UIImageView *gamesBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GamesBackIphone.png"]];
    CGRect screenBounds =[[UIScreen mainScreen] bounds];
    CGSize screenDimensions = screenBounds.size;
    [gamesBackground setFrame:CGRectMake(0, 0, screenDimensions.width,screenDimensions.height)];
    
    [self.gamesBackground setFrame:CGRectMake(0, 0, screenDimensions.width,screenDimensions.height)];*/
    
    
    [self.gameNewButton.titleLabel setFont:[UIFont fontWithName:@"Bauhaus 93" size:20]];
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


#pragma mark - segue

-(void)showGameScreenNotAnimated:(id)cellOrString{
    //put the Loader into the view
    [self putLoaderInView];
    
    //create the tabBarView from the storyboard
    GameScreenViewController *newGameScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"gameScreen"];
    
    //transfer the networking controls
    newGameScreen.thisNetworkController = self.thisNetworkController;
    
    //pass appropriate game information
    if([cellOrString isKindOfClass: [NSString class]]){
        newGameScreen.opponentName = self.createdGameOpponent;
    } else {
        static NSString *CellIdentifier = @"GameCell";
        UITableViewCell *cell = [self.gameTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = cellOrString;
        newGameScreen.opponentName = cell.textLabel.text;
        newGameScreen.gameID = cell.detailTextLabel.text;
    }
    
    //segue!
    [self.navigationController pushViewController:newGameScreen animated:NO];
    NSLog(@"WE SEGUED!");
}

@end
