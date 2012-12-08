//
//  GameScreenController.m
//  SayonariaGame
//
//  Created by Andrew Mueller on 8/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameScreenViewController.h"

@interface GameScreenViewController ()

@property (nonatomic) ServerState *currentServerState;
@property (nonatomic) IBOutlet UIGestureRecognizer *tapRecognizer;
@property (nonatomic) NSString *GameState1;
@property (nonatomic) NSString *GameState2;
@property (nonatomic) NSString *GameState;

@property (nonatomic) NSInteger boardHeight;
@property (nonatomic) NSInteger boardWidth;
@property (nonatomic) NSString *UserID1;
@property (nonatomic) NSString *UserID2;
@property (nonatomic) NSString *Score1;
@property (nonatomic) NSString *Score2;
@property (nonatomic) NSString *Turn;
@property (nonatomic) NSString *GameOver;
@property (nonatomic) NSString *TeamID1;
@property (nonatomic) NSString *TeamID2;

@property (nonatomic) NSInteger CellSize;

@property (nonatomic) UIImage *InactiveCellTeam1;
@property (nonatomic) UIImage *InactiveCellTeam2;
@property (nonatomic) UIImage *ActiveCellTeam1;
@property (nonatomic) UIImage *ActiveCellTeam2;
@property (nonatomic) UIImage *NeutralTile;
@property (nonatomic) UIImage *TeamBackground;

@property (nonatomic) NSMutableDictionary *FrameDictionary;
@property (nonatomic) NSMutableDictionary *PastMovesDictionary;

@property (nonatomic) NSInteger TouchTolerance;

@property (nonatomic) NSInteger TotalCellsNum;


@end

/* (non-Javadoc)
 * the string looks like this:
 * players=username!userID!score|username!userID!score...,h=height,w=width,board=node|node|node|node...,over=0or1,turn=userID
 *
 * a node looks like this:
 * nodeID!x!y!owner!active!adjList
 *
 * an adjList looks like this:
 * nodeID.nodeID.nodeID.nodeID...
 *
 * example:
 * players=1-100|2-20,h=9,w=7,board=10-1-1-1-0-20.21.32.40|11-1-2-2-1-21.22.33.49....,over=0
 *
 */


@implementation GameScreenViewController
@synthesize BackgroundView;
@synthesize gameBoardView;
@synthesize GameState;
@synthesize GameState1;
@synthesize GameState2;
@synthesize boardHeight;
@synthesize boardWidth;
@synthesize UserID1;
@synthesize UserID2;
@synthesize Score1;
@synthesize Score2;
@synthesize Turn;
@synthesize GameOver;
@synthesize TeamID1;
@synthesize TeamID2;
@synthesize InactiveCellTeam1;
@synthesize InactiveCellTeam2;
@synthesize ActiveCellTeam1;
@synthesize ActiveCellTeam2;
@synthesize NeutralTile;
@synthesize TeamBackground;
@synthesize CellSize;

@synthesize FrameDictionary;
@synthesize PastMovesDictionary;

@synthesize TouchTolerance;
@synthesize TotalCellsNum;

#pragma mark - server Communications and delegate methods

-(void)putLoaderInViewWithSplash:(BOOL)isSplash withFade:(BOOL)isFade{
    self.loader = [[LoadingView alloc] init];
    self.loader = [self.loader loadSpinnerIntoView:self.view withSplash:isSplash withFade:isFade];
<<<<<<< HEAD
}

-(void)loaderIsOnScreen{
    [self removeLoaderFromView];
=======
>>>>>>> IanBranchWorking
}

-(void)removeLoaderFromView{

}


//MESSAGES RECIEVED FROM THE SERVER WILL BE SENT HERE
-(void)messageRecieved:(NSString *)messageFromServer{
    
    if([[messageFromServer substringToIndex:5] isEqualToString:@"state"])
    {
        GameState1=messageFromServer;
        GameState2=@"A";
    }
       
    else{
        GameState2=messageFromServer;
    }
        
  GameState=[GameState1 stringByAppendingString:GameState2];

    [self parseGameState];
   
}


-(void)viewDidLoad
{
   
    
    
    self.thisNetworkController.delegate = self;
    [self.thisNetworkController sendMessageToServer:@"gameState:1"];
    
    [self parseGameState];
    [self SetArtAssets];
    [self RecordCellFrames];
    [self InitialDrawScreen];
    
    
    
}



-(void)RecordCellFrames{
    
    self.FrameDictionary= [[NSMutableDictionary alloc]initWithCapacity:TotalCellsNum];
    self.PastMovesDictionary= [[NSMutableDictionary alloc]initWithCapacity:TotalCellsNum];
    
    for(int i = 0; i < boardWidth; i++) {
        for(int j = 0; j < boardHeight; j++) {
    
            int IncrementalLength=i*(CellSize-10)*1.06;
            int IncrementalWidth=j*(CellSize-2)*1.06;
            int moduloResult = i % 2;
            int WidthModifier;
            if(moduloResult==1){WidthModifier=0;} else {WidthModifier=(CellSize-2)/2;}
            IncrementalWidth=IncrementalWidth+WidthModifier;
            
            CGRect frame = CGRectMake(IncrementalLength,IncrementalWidth,CellSize,CellSize);
            
            NSString *frameString=NSStringFromCGRect(frame);
            [self.FrameDictionary setObject:frameString forKey:frameString];
            
        }
    }
    
    
    
}

-(void)SetArtAssets{
    
    if( TeamID1==@"Coal"){InactiveCellTeam1=[UIImage imageNamed:@"Inactive Coal.png"];}
    if( TeamID1==@"Diamond"){InactiveCellTeam1=[UIImage imageNamed:@"Inactive Diamond.png"];}
    if( TeamID1==@"Gold"){InactiveCellTeam1=[UIImage imageNamed:@"Inactive Gold.png"];}
    if( TeamID1==@"Silica"){InactiveCellTeam1=[UIImage imageNamed:@"Inactive Silica.png"];}
    
    if( TeamID2==@"Coal"){InactiveCellTeam2=[UIImage imageNamed:@"Inactive Coal.png"];}
    if( TeamID2==@"Diamond"){InactiveCellTeam2=[UIImage imageNamed:@"Inactive Diamond.png"];}
    if( TeamID2==@"Gold"){InactiveCellTeam2=[UIImage imageNamed:@"Inactive Gold.png"];}
    if( TeamID2==@"Silica"){InactiveCellTeam2=[UIImage imageNamed:@"Inactive Silica.png"];}
    
    
    
    if( TeamID1==@"Coal"){ActiveCellTeam1=[UIImage imageNamed:@"Active Coal.png"];}
    if( TeamID1==@"Diamond"){ActiveCellTeam1=[UIImage imageNamed:@"Inactive Diamond.png"];}
    if( TeamID1==@"Gold"){ActiveCellTeam1=[UIImage imageNamed:@"Inactive Gold.png"];}
    if( TeamID1==@"Silica"){ActiveCellTeam1=[UIImage imageNamed:@"Inactive Silica.png"];}
    
    if( TeamID2==@"Coal"){ActiveCellTeam2=[UIImage imageNamed:@"Inactive Coal.png"];}
    if( TeamID2==@"Diamond"){ActiveCellTeam2=[UIImage imageNamed:@"Inactive Diamond.png"];}
    if( TeamID2==@"Gold"){ActiveCellTeam2=[UIImage imageNamed:@"Inactive Gold.png"];}
    if( TeamID2==@"Silica"){ActiveCellTeam2=[UIImage imageNamed:@"Inactive Silica.png"];}
    
    if( TeamID2==@"Coal"){InactiveCellTeam2=[UIImage imageNamed:@"Inactive Coal.png"];}
    if( TeamID2==@"Diamond"){InactiveCellTeam2=[UIImage imageNamed:@"Inactive Diamond.png"];}
    if( TeamID2==@"Gold"){InactiveCellTeam2=[UIImage imageNamed:@"Inactive Gold.png"];}
    if( TeamID2==@"Silica"){InactiveCellTeam2=[UIImage imageNamed:@"Inactive Silica.png"];}
    
    NeutralTile=[UIImage imageNamed:@"Inactive Neutral.png"];
    
    if( TeamID1==@"Coal"){TeamBackground=[UIImage imageNamed:@"Coal Background.png"];}
    if( TeamID1==@"Diamond"){TeamBackground=[UIImage imageNamed:@"Diamond Background.png"];}
    if( TeamID1==@"Gold"){TeamBackground=[UIImage imageNamed:@"Gold Background.png"];}
    if( TeamID1==@"Silica"){TeamBackground=[UIImage imageNamed:@"Inactive Silica.png"];}
    
}


-(void)InitialDrawScreen{
    
    BackgroundView.image=TeamBackground;
    

    for(int i = 0; i < boardWidth; i++) {
        for(int j = 0; j < boardHeight; j++) {

            
            int IncrementalLength=i*(CellSize-10)*1.06;
            int IncrementalWidth=j*(CellSize-2)*1.06;
            int moduloResult = i % 2;
            int WidthModifier;
            if(moduloResult==1){WidthModifier=0;} else {WidthModifier=(CellSize-2)/2;}
            IncrementalWidth=IncrementalWidth+WidthModifier;
            
            CGRect frame = CGRectMake(IncrementalLength,IncrementalWidth,CellSize,CellSize);
            
            
            UIImageView *BorderGrid;
            
            BorderGrid=[[UIImageView alloc] initWithFrame:frame];
            BorderGrid.image=NeutralTile;
            [gameBoardView addSubview:BorderGrid];
            
                }
            }
    
    
}


-(void)parseGameState{
    
    
    self.thisNetworkController.delegate = self;
    
    NSLog(@"Value of string is %@", GameState);
    
    //NSInteger boardHeightIndex=[GameState rangeOfString:@"h"].location+2;
    //NSInteger boardWidthIndex=[GameState rangeOfString:@"w"].location+2;
    
    //boardHeight=[GameState substringWithRange: NSMakeRange (boardHeightIndex, 2)];
   // boardWidth=[GameState substringWithRange: NSMakeRange (boardWidthIndex, 1)];
    
    boardHeight=8;
    boardWidth=6;
    
    TotalCellsNum=boardHeight*boardWidth;
    
    
    TeamID1=@"Coal";
    TeamID2=@"Gold";
    
    Turn=@"1";
    
    GameOver=@"0";
    
    Score1=@"0";
    Score2=@"0";
    
    CellSize=42;
    
    TouchTolerance=20;
    
    
}




- (IBAction)LayTile:(UITapGestureRecognizer *)sender {
    

    
    if(Turn==@"1"){
        
    CGPoint location=[sender locationInView:self.gameBoardView];
    
    for(id key in self.FrameDictionary)
    {

    
    CGRect CurrentFrame=CGRectFromString( [self.FrameDictionary objectForKey:key]);
    NSString *frameString=NSStringFromCGRect(CurrentFrame);
    
    double distance = sqrt(pow(( (CurrentFrame.origin.x+self.CellSize/2) - location.x), 2.0) + pow(( (CurrentFrame.origin.y+self.CellSize/2) - location.y), 2.0));
    //NSLog(@"Value of string is %f", distance);
    
        if(distance<TouchTolerance && [self.PastMovesDictionary objectForKey:frameString]==nil){
        
            UIImageView *PlaceView;
            PlaceView = [[UIImageView alloc] initWithFrame:CurrentFrame];
            PlaceView.image = ActiveCellTeam1;
            [PastMovesDictionary setObject:frameString forKey:frameString];
            
            
            
            if(TeamID1==@"Coal"){
                
                PlaceView.animationImages=[NSArray arrayWithObjects:
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v001000.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v001001.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v001002.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v001003.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v001004.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v001005.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v001006.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v001007.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v001008.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v001009.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v001010.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v001011.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v001012.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v001013.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_000.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_001.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_002.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_003.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_004.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_005.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_006.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_007.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_008.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_009.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_010.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_011.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_012.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_013.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_014.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_015.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_016.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_017.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_018.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_019.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_020.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_021.png"],
                                           [UIImage imageNamed:@"simpsoci_coal_tile_apear_anim_v01_022.png"]
                                           , nil];
                
                
                PlaceView.animationDuration = 2.0;
                PlaceView.animationRepeatCount = 1;
                [PlaceView startAnimating];
                [gameBoardView addSubview:PlaceView];
                
    }
    }
    }
    }
    
   // Turn=@"2";

}






- (void)viewDidUnload {
    
    self.Team1=@"Diamond";
    self.Team2=@"Gold";
    
    if(self.Team1==@"Coal"){self.Team1CellType=[UIImage imageNamed:@"epato_new_game_minimal_tiles_coal"];}
    if(self.Team1==@"Diamond"){self.Team1CellType=[UIImage imageNamed:@"epato_new_game_minimal_tiles_diamond.png"];}
    if(self.Team1==@"Gold"){self.Team1CellType=[UIImage imageNamed:@"epato_new_game_minimal_tiles_gold.png"];}
    if(self.Team1==@"Silica"){self.Team1CellType=[UIImage imageNamed:@"epato_new_game_minimal_tiles_silica.png"];}
    
    
    if(self.Team2==@"Coal"){self.Team2CellType=[UIImage imageNamed:@"epato_new_game_minimal_tiles_coal"];}
    if(self.Team2==@"Diamond"){self.Team2CellType=[UIImage imageNamed:@"epato_new_game_minimal_tiles_diamond.png"];}
    if(self.Team2==@"Gold"){self.Team2CellType=[UIImage imageNamed:@"epato_new_game_minimal_tiles_gold.png"];}
    if(self.Team2==@"Silica"){self.Team2CellType=[UIImage imageNamed:@"epato_new_game_minimal_tiles_silica.png"];}
}


-(void)viewWillAppear:(BOOL)animated{
    [self putLoaderInViewWithSplash:NO withFade:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    [self removeLoaderFromView]; //ANDREW, DO THIS AFTER YOU HAVE FULLY INITIALIZED THE VIEW, THE LOADER WILL HIDE EVERYTHING IN THE MEANTIME
}

- (void)viewDidUnload
{
    
    
}



@end
