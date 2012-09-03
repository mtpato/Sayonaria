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
@property (nonatomic,weak) LoadingView * loader;
@property (nonatomic) ServerState *currentServerState;
@property (nonatomic,weak) IBOutlet UITextField *OpponentName;
@property (nonatomic) IBOutlet UITableView *gameTableView;
@property (nonatomic, strong) NSArray *thisUsersGames;
@end

@implementation GameTabViewController

#pragma mark - server Communications and delegate methods

-(void)putLoaderInView{
    self.loader = [LoadingView loadSpinnerIntoView:self.view];
}

-(void) removeLoaderFromView{
    [self.loader removeLoader];
}

-(void)messageRecieved:(NSString *)messageFromServer{
    NSLog(@"server said: %@", messageFromServer);
    //if the server says 'done' it can be connecting, confirming the game type, etc
    if([[messageFromServer substringToIndex:4] isEqualToString:@"done"]){
        if([messageFromServer isEqualToString:@"done:gameCreated"]){
            [self performSegueWithIdentifier:@"showGameScreen" sender:@"New Game"];
        }
    }
    if([[messageFromServer substringToIndex:5] isEqualToString:@"games"]){
        [self parseGames:[messageFromServer substringFromIndex:6]];
        [self.gameTableView reloadData];
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

#pragma mark - actions

- (IBAction)newGamePressed:(id)sender {
    NSString *messageForServer = @"newGame:";
    messageForServer = [messageForServer stringByAppendingString:self.OpponentName.text];
    [self.thisNetworkController sendMessageToServer:messageForServer];
}

#pragma mark - table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
	// Return the number of sections
	return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	// Return the header at the given index
	return @"Games";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows for the given the section
    NSUInteger total = [self.thisUsersGames count];
    return total;    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"LOADING CELLS");
    
	static NSString *CellIdentifier = @"GameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	// Extract the game informaton
    if(indexPath.row <=[self.thisUsersGames count]) {
        NSDictionary *gameDictionary = [self.thisUsersGames objectAtIndex:(indexPath.row - 1)];
        NSString *gameID = [gameDictionary objectForKey:GAME_ID];
        NSString *opponentName = [gameDictionary objectForKey:OPPONENT_NAME];
    
        cell.textLabel.text = opponentName;
        cell.detailTextLabel.text = gameID;
    }
    return cell;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    NetworkStorageTabBarController *thisTabBar = (NetworkStorageTabBarController *) self.tabBarController;
    self.thisNetworkController = thisTabBar.thisNetworkController;
    self.thisNetworkController.delegate = self;
    
    [self putLoaderInView];
    [self.gameTableView reloadData];
    [self removeLoaderFromView];
    [self.thisNetworkController sendMessageToServer:@"getGames"];
    
    /*
    // Initialise the queue used to download from flickr
	dispatch_queue_t dispatchQueue = dispatch_queue_create("q_loadTopPlaces", NULL);
	
	// Use the download queue to asynchronously get the list of Top Places
	dispatch_async(dispatchQueue, ^{
		
        [self.thisNetworkController sendMessageToServer:@"getGames"];
		
		// Use the main queue to refresh update the view
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.gameTableView reloadData];
			[self removeLoaderFromView];
		});
		
	});
	// Release the queue
	dispatch_release(dispatchQueue);
     */
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([sender isEqualToString:@"New Game"]){
        
    }
}

@end
