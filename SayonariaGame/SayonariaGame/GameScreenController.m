//
//  GameScreenController.m
//  SayonariaGame
//
//  Created by Andrew Mueller on 8/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameScreenController.h"

@interface GameScreenController ()

@property NSInteger TotalCellsNum;
@property NSInteger CellHeight;
@property NSInteger CellWidth;
@property NSInteger LengthCellsNum;
@property NSInteger WidthCellsNum;
@property NSMutableDictionary *FrameDictionary;
@property NSMutableDictionary *PastMovesDictionary;
@property CGFloat TouchTolerance;
@property NSString *Team1;
@property NSString *Team2;
@property UIImage *Team1CellType;
@property UIImage *Team2CellType;
@property NSInteger TeamTurn;
@property UIImageView *BorderGrid;
@property UIImageView *NeutralTile;
@property UIImageView *NeutralGlow;

@end




@implementation GameScreenController
@synthesize GameBoardView;
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
@synthesize NeutralGlow;



-(void)ProcessTurn{
    
    
    
  //  GetGameState
  //  DrawGameState
  //  PlaceTile
  //  GetGameState
  //  DrawGameState
  //  EndTurn
    
    
    
}




-(void)ClearGameScreen{
        [[GameBoardView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}


-(void)DrawGameScreen{
    
    FrameDictionary= [[NSMutableDictionary alloc]initWithCapacity:TotalCellsNum];
    
    for(int i = 0; i < WidthCellsNum-1; i++) {
        for(int j = 0; j < LengthCellsNum-1; j++) {
    
            int IncrementalLength=i*(CellWidth-10)*1.06;
            int IncrementalWidth=j*(CellWidth-2)*1.06;
            int moduloResult = i % 2;
            int WidthModifier;
            if(moduloResult==1){WidthModifier=0;} else {WidthModifier=(CellWidth-2)/2;}
            IncrementalWidth=IncrementalWidth+WidthModifier;
            
            CGRect frame = CGRectMake(IncrementalLength,IncrementalWidth,CellHeight,CellWidth);
            NSString *frameString=NSStringFromCGRect(frame);
            [FrameDictionary setObject:frameString forKey:frameString];
            
            BorderGrid=[[UIImageView alloc] initWithFrame:frame];
            BorderGrid.image=[UIImage imageNamed:@"epato_game_concepts_board_modules_cell_f_border.png"];
            [GameBoardView addSubview:BorderGrid];
            
            NeutralTile=[[UIImageView alloc] initWithFrame:frame];
            NeutralTile.image=[UIImage imageNamed:@"epato_game_concepts_board_modules_cell_f_border_transparency_neutral_gray.png"];
            [GameBoardView addSubview:NeutralTile];
            
            NeutralGlow=[[UIImageView alloc] initWithFrame:frame];
            
    
            NeutralGlow.animationImages = [NSArray arrayWithObjects:	 
                                            [UIImage imageNamed:@"neutral_to_inactive_glow_frames_01.png"], 
                                            [UIImage imageNamed:@"neutral_to_inactive_glow_frames_02.png"],
                                            [UIImage imageNamed:@"neutral_to_inactive_glow_frames_03.png"],
                                           [UIImage imageNamed:@"neutral_to_inactive_glow_frames_04.png"],
                                           [UIImage imageNamed:@"neutral_to_inactive_glow_frames_05.png"],
                                            [UIImage imageNamed:@"neutral_to_inactive_glow_frames_06.png"]
                                            , nil]; 
            
            
            NeutralGlow.animationDuration = 1.0;
            NeutralGlow.animationRepeatCount = 0; 
            [NeutralGlow startAnimating]; 
            [GameBoardView addSubview:NeutralGlow]; 
        }
    }
    
}




-(void)viewDidLoad
{
    [self InitializeTurn];
    [self GetGamePropertiesFromTheServer];
    [self DrawGameScreen];
}




-(void)InitializeTurn
{
      TeamTurn=1;
}



-(void)UpdateGameState
{
    if(TeamTurn==1){TeamTurn=2;} else if (TeamTurn==2){TeamTurn=1;}
    
}


- (IBAction)LayTile:(UITapGestureRecognizer *)sender {
        
    CGPoint location=[sender locationInView:GameBoardView];
    
    
    for(id key in FrameDictionary)
    {
        
        
        CGRect CurrentFrame=CGRectFromString( [FrameDictionary objectForKey:key]);
        NSString *frameString=NSStringFromCGRect(CurrentFrame);
        double distance = sqrt(pow(( (CurrentFrame.origin.x+CellHeight/2) - location.x), 2.0) + pow(( (CurrentFrame.origin.y+CellWidth/2) - location.y), 2.0));
        
        
        
        
        
        if(distance<TouchTolerance && [PastMovesDictionary objectForKey:frameString]==nil){
            UIImageView *PlaceView;
            PlaceView = [[UIImageView alloc] initWithFrame:CurrentFrame];
            
            if(TeamTurn==1){PlaceView.image = Team1CellType;} 
            else if(TeamTurn==2){PlaceView.image = Team2CellType;}
        
            [GameBoardView addSubview:PlaceView];
            [PastMovesDictionary setObject:frameString forKey:frameString];

        }
        
        
    }
  
   
    [self UpdateGameState];
}






-(void)GetGamePropertiesFromTheServer
{
    CellHeight=42;
    CellWidth=42;
    LengthCellsNum=9;
    WidthCellsNum=7;
    TotalCellsNum=LengthCellsNum*WidthCellsNum;
    TouchTolerance=10;
    
    Team1=@"Diamond";
    Team2=@"Gold";
    
    if(Team1==@"Coal"){Team1CellType=[UIImage imageNamed:@"epato_new_game_minimal_tiles_coal"];}
    if(Team1==@"Diamond"){Team1CellType=[UIImage imageNamed:@"epato_new_game_minimal_tiles_diamond.png"];}
    if(Team1==@"Gold"){Team1CellType=[UIImage imageNamed:@"epato_new_game_minimal_tiles_gold.png"];}
    if(Team1==@"Silica"){Team1CellType=[UIImage imageNamed:@"epato_new_game_minimal_tiles_silica.png"];}
    
    
    if(Team2==@"Coal"){Team2CellType=[UIImage imageNamed:@"epato_new_game_minimal_tiles_coal"];}
    if(Team2==@"Diamond"){Team2CellType=[UIImage imageNamed:@"epato_new_game_minimal_tiles_diamond.png"];}
    if(Team2==@"Gold"){Team2CellType=[UIImage imageNamed:@"epato_new_game_minimal_tiles_gold.png"];}
    if(Team2==@"Silica"){Team2CellType=[UIImage imageNamed:@"epato_new_game_minimal_tiles_silica.png"];}
}





- (void)viewDidUnload
{
 

}



@end































