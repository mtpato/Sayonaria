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

@property (nonatomic) NSInteger TotalCellsNum;
@property (nonatomic) NSInteger CellHeight;
@property (nonatomic) NSInteger CellWidth;
@property (nonatomic) NSInteger LengthCellsNum;
@property (nonatomic) NSInteger WidthCellsNum;
@property (nonatomic) NSMutableDictionary *FrameDictionary;
@property (nonatomic) NSMutableDictionary *PastMovesDictionary;
@property (nonatomic) CGFloat TouchTolerance;
@property (nonatomic) NSString *Team1;
@property (nonatomic) NSString *Team2;
@property (nonatomic) UIImage *Team1CellType;
@property (nonatomic) UIImage *Team2CellType;
@property (nonatomic) NSInteger TeamTurn;
@property (nonatomic) UIImageView *BorderGrid;
@property (nonatomic) UIImageView *NeutralTile;
@property (nonatomic) UIImageView *NeutralGlow;
@property (nonatomic) IBOutlet UIGestureRecognizer *tapRecognizer;

@end




@implementation GameScreenViewController
/*@synthesize GameBoardView;
 @synthesize TotalCellsNum;
 @synthesize CellHeight;
 @synthesize CellWidth;
 @synthesize LengthCellsNum;
 @synthesize WidthCellsNum;
 @synthesize FrameDictionary;
 @synthesize PastMovesDictionary;
 @synthesize TouchTolerance;
 @synthesize Team1;
 @synthesize Team2;
 @synthesize Team1CellType;
 @synthesize Team2CellType;
 @synthesize TeamTurn;
 @synthesize BorderGrid;
 @synthesize NeutralTile;
 @synthesize NeutralGlow;*/



#pragma mark - server Communications and delegate methods

-(void)putLoaderInViewWithSplash:(BOOL)isSplash withFade:(BOOL)isFade{
    self.loader = [[LoadingView alloc] init];
    self.loader = [self.loader loadSpinnerIntoView:self.view withSplash:isSplash withFade:isFade];
}

-(void)loaderIsOnScreen{
    [self removeLoaderFromView];
}

-(void)removeLoaderFromView{
    [self.loader removeLoader:self.view];
    self.loader = nil;
}

//MESSAGES RECIEVED FROM THE SERVER WILL BE SENT HERE
-(void)messageRecieved:(NSString *)messageFromServer{
    NSLog(@"server said: %@", messageFromServer);
}




-(void)ProcessTurn{
    
    //  GetGameState
    //  DrawGameState
    //  PlaceTile
    //  GetGameState
    //  DrawGameState
    //  EndTurn
    
}




-(void)ClearGameScreen{
    [[self.GameBoardView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}


-(void)DrawGameScreen{
    
    self.FrameDictionary= [[NSMutableDictionary alloc]initWithCapacity:self.TotalCellsNum];
    
    for(int i = 0; i < self.WidthCellsNum-1; i++) {
        for(int j = 0; j < self.LengthCellsNum-1; j++) {
            
            int IncrementalLength=i*(self.CellWidth-10)*1.06;
            int IncrementalWidth=j*(self.CellWidth-2)*1.06;
            int moduloResult = i % 2;
            int WidthModifier;
            if(moduloResult==1){WidthModifier=0;} else {WidthModifier=(self.CellWidth-2)/2;}
            IncrementalWidth=IncrementalWidth+WidthModifier;
            
            CGRect frame = CGRectMake(IncrementalLength,IncrementalWidth,self.CellHeight,self.CellWidth);
            NSString *frameString=NSStringFromCGRect(frame);
            [self.FrameDictionary setObject:frameString forKey:frameString];
            
            self.BorderGrid=[[UIImageView alloc] initWithFrame:frame];
            self.BorderGrid.image=[UIImage imageNamed:@"epato_game_concepts_board_modules_cell_f_border.png"];
            [self.GameBoardView addSubview:self.BorderGrid];
            
            self.NeutralTile=[[UIImageView alloc] initWithFrame:frame];
            self.NeutralTile.image=[UIImage imageNamed:@"epato_game_concepts_board_modules_cell_f_border_transparency_neutral_gray.png"];
            [self.GameBoardView addSubview:self.NeutralTile];
            
            self.NeutralGlow=[[UIImageView alloc] initWithFrame:frame];
            
            
            self.NeutralGlow.animationImages = [NSArray arrayWithObjects:
                                                [UIImage imageNamed:@"neutral_to_inactive_glow_frames_01.png"],
                                                [UIImage imageNamed:@"neutral_to_inactive_glow_frames_02.png"],
                                                [UIImage imageNamed:@"neutral_to_inactive_glow_frames_03.png"],
                                                [UIImage imageNamed:@"neutral_to_inactive_glow_frames_04.png"],
                                                [UIImage imageNamed:@"neutral_to_inactive_glow_frames_05.png"],
                                                [UIImage imageNamed:@"neutral_to_inactive_glow_frames_06.png"]
                                                , nil];
            
            
            self.NeutralGlow.animationDuration = 1.0;
            self.NeutralGlow.animationRepeatCount = 0;
            [self.NeutralGlow startAnimating];
            [self.GameBoardView addSubview:self.NeutralGlow];
        }
    }
    
}




-(void)viewDidLoad
{
    NSLog(@"Game Screen Loaded");
    //NSLog(@"%@",self.opponentName);
    //NSLog(@"%@",self.gameID);
    
    //set up network communications
    self.thisNetworkController.delegate = self;
    NSLog(@"Networking Set Up");
    
    //[self.thisNetworkController sendMessageToServer:@"getGames"];
    
    //do other initialization
    [self InitializeTurn];
    NSLog(@"Turn Initialized");
    [self GetGamePropertiesFromTheServer];
    NSLog(@"GamePropertiesRecieved");
    [self DrawGameScreen];
    NSLog(@"Game Screen Drawn");
}




-(void)InitializeTurn
{
    self.TeamTurn=1;
}



-(void)UpdateGameState
{
    if(self.TeamTurn==1){self.TeamTurn=2;} else if (self.TeamTurn==2){self.TeamTurn=1;}
    
}


- (IBAction)LayTile:(UITapGestureRecognizer *)sender {
    
    CGPoint location=[sender locationInView:self.GameBoardView];
    
    
    for(id key in self.FrameDictionary)
    {
        
        
        CGRect CurrentFrame=CGRectFromString( [self.FrameDictionary objectForKey:key]);
        NSString *frameString=NSStringFromCGRect(CurrentFrame);
        double distance = sqrt(pow(( (CurrentFrame.origin.x+self.CellHeight/2) - location.x), 2.0) + pow(( (CurrentFrame.origin.y+self.CellWidth/2) - location.y), 2.0));
        
        
        
        
        
        if(distance<self.TouchTolerance && [self.PastMovesDictionary objectForKey:frameString]==nil){
            UIImageView *PlaceView;
            PlaceView = [[UIImageView alloc] initWithFrame:CurrentFrame];
            
            if(self.TeamTurn==1){PlaceView.image = self.Team1CellType;}
            else if(self.TeamTurn==2){PlaceView.image = self.Team2CellType;}
            
            [self.GameBoardView addSubview:PlaceView];
            [self.PastMovesDictionary setObject:frameString forKey:frameString];
            
        }
        
        
    }
    
    
    [self UpdateGameState];
}






-(void)GetGamePropertiesFromTheServer
{
    self.CellHeight=42;
    self.CellWidth=42;
    self.LengthCellsNum=9;
    self.WidthCellsNum=7;
    self.TotalCellsNum=self.LengthCellsNum * self.WidthCellsNum;
    self.TouchTolerance=10;
    
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
