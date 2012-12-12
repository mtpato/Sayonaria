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
@property (nonatomic) NSArray *GameNodeData;
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



@implementation GameScreenViewController
@synthesize BackgroundView;
@synthesize gameBoardView;
@synthesize GameState;
@synthesize GameState1;
@synthesize GameState2;
@synthesize GameNodeData;
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
    
    if([[messageFromServer substringToIndex:5] isEqualToString:@"state"])
    {
        GameState1=messageFromServer;
        GameState2=@"";
    }
       
    else{
        
        GameState2=messageFromServer;
        
        GameState=[GameState1 stringByAppendingString:GameState2];
        
        [self SetArtAssets];
        
        [self parseGameState];
        
        [self removeLoaderFromView];
        
    }
    


    
}


-(void)viewDidLoad
{
   
    

    
    
}



















-(void)parseGameState{
    
    
    self.thisNetworkController.delegate = self;
    
    NSUInteger index1 = 0;
    NSUInteger index2 = 0;

    BackgroundView.image=TeamBackground;
    
    
    //Check the user ID of the currentplayer
    
    Turn=[GameState substringWithRange:NSMakeRange([GameState rangeOfString:@"turn="].location+5,1)];
    
    
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    
    
    UserID1=@"6";
    UserID2=@"5";
    
    //pulls the gameover number from the game state
    
    GameOver = [GameState substringWithRange:NSMakeRange([GameState rangeOfString:@"over"].location+5,1)];
    
    
    //Get the current score for each player
    
    index1=[self substringOfString:GameState untilNthOccurrence:1 ofString:@"!"];
    index2=[self substringOfString:GameState untilNthOccurrence:1 ofString:@"|"];
    
    Score1=[GameState substringWithRange:NSMakeRange(index1,index2-index1-1)];
    
    index1=[self substringOfString:GameState untilNthOccurrence:2 ofString:@"!"];
    index2=[self substringOfString:GameState untilNthOccurrence:2 ofString:@"|"];
    
    Score2=[GameState substringWithRange:NSMakeRange(index1+1,index2-index1-1)];
    
    
    // Set the size of the cells on the screen
    
    CellSize=40;
    
    // Set the sensitivity for touching the center of the square
    
    TouchTolerance=20;
    
    NSString *BoardState=[GameState substringWithRange:NSMakeRange(index1,GameState.length-index1)];
    
    GameNodeData = [BoardState componentsSeparatedByString: @"|"];
    
    self.FrameDictionary= [[NSMutableDictionary alloc]initWithCapacity:[GameNodeData count]];
    
    
    for(int i = 0; i <[GameNodeData count] ; i++) {
        
    index1=[self substringOfString:GameState untilNthOccurrence:1 ofString:@"board="];
  
    UIImage *CellImage;
        
    NSArray *ThisNodeData = [GameNodeData[i] componentsSeparatedByString: @"!"];
    
       
    if([ThisNodeData[3] isEqualToString:@"-1"]){CellImage=NeutralTile;}
    
        
    if([ThisNodeData[3] isEqualToString:UserID1] && [ThisNodeData[4] isEqualToString:@"1"]){CellImage=ActiveCellTeam1;}
    if([ThisNodeData[3] isEqualToString:UserID1] && [ThisNodeData[4] isEqualToString:@"0"]){CellImage=InactiveCellTeam1;}
    if([ThisNodeData[3] isEqualToString:UserID2] && [ThisNodeData[4] isEqualToString:@"1"]){CellImage=ActiveCellTeam2;}
    if([ThisNodeData[3] isEqualToString:UserID2] && [ThisNodeData[4] isEqualToString:@"0"]){CellImage=InactiveCellTeam2;}
        
    
    [self drawCellwithX:[ThisNodeData[1] intValue] withY:[ThisNodeData[2] intValue] Image:CellImage];
    
    [self AssignFrameToDictionarywithX:[ThisNodeData[1] intValue] withY:[ThisNodeData[2] intValue]];
    

        }
    
    NSLog(@"%@",UserID1);
    
        
    }
    









- (NSUInteger )substringOfString:(NSString *)base untilNthOccurrence:(NSInteger)n ofString:(NSString *)delim
{
    NSScanner *scanner = [NSScanner scannerWithString:base];
    NSInteger i;
    for (i = 0; i < n; i++)
    {
        [scanner scanUpToString:delim intoString:NULL];
        [scanner scanString:delim intoString:NULL];
    }
    return [scanner scanLocation];
}









-(void) drawCellwithX:(NSUInteger)i withY:(NSUInteger)j Image:(UIImage*)ImageToDraw
{
    
    
    float hStep = 20;
    float vStep = 30;
    float topBuffer = 0 ;
    float buffer = 0;
    
    float x1=j*hStep-buffer;
    float x2=j*hStep+hStep+buffer;
    float y1=i*vStep+buffer+topBuffer;
    float y2=i*vStep+vStep-buffer+topBuffer;
    

    CGRect frame = CGRectMake((y1+y2)/2,(x1+x2)/2,CellSize,CellSize);
   
    
    UIImageView *ImageToDrawView;
    
    ImageToDrawView=[[UIImageView alloc] initWithFrame:frame];
    ImageToDrawView.image=ImageToDraw;
    
    [gameBoardView addSubview:ImageToDrawView];
    
}









-(void) AssignFrameToDictionarywithX:(NSUInteger)i withY:(NSUInteger)j
{
    
    
    float hStep = 20;
    float vStep = 30;
    float topBuffer = 0 ;
    float buffer = 0;
    
    float x1=j*hStep-buffer;
    float x2=j*hStep+hStep+buffer;
    float y1=i*vStep+buffer+topBuffer;
    float y2=i*vStep+vStep-buffer+topBuffer;
    
    
    CGRect frame = CGRectMake((y1+y2)/2,(x1+x2)/2,CellSize,CellSize);
    
    NSString *frameString=NSStringFromCGRect(frame);
    [self.FrameDictionary setObject:frameString forKey:frameString];

    
}


















- (IBAction)LayTile:(UITapGestureRecognizer *)sender {
    

if([Turn isEqualToString:UserID2])
{
        
    CGPoint location=[sender locationInView:self.gameBoardView];
    
    int i=0;
    
    for(id key in self.FrameDictionary)
    {
        
    
    CGRect CurrentFrame=CGRectFromString( [self.FrameDictionary objectForKey:key]);
    
    double distance = sqrt(pow(( (CurrentFrame.origin.x+self.CellSize/2) - location.x), 2.0) + pow(( (CurrentFrame.origin.y+self.CellSize/2) - location.y), 2.0));
    //NSLog(@"Value of string is %f", distance);
    
        if(distance<TouchTolerance)
        {
            NSArray *ThisNodeData = [GameNodeData[i] componentsSeparatedByString: @"!"];
            
            [self.thisNetworkController sendMessageToServer:  [NSString stringWithFormat:@"%@%@%@%@", @"makeMove:",self.gameID,@",",ThisNodeData[0]]];
            [self parseGameState];
            NSLog(@"%@",@"move was made");
        }
        
        i=i+1;
        
    }
}
   // NSLog(@"%@",Turn);




    
}













- (void)viewDidUnload {
    

}







-(void)viewWillAppear:(BOOL)animated{
    [self putLoaderInViewWithSplash:NO withFade:NO];
}







#pragma mark - view loading and appearing

-(void)viewDidAppear:(BOOL)animated{
    
    self.thisNetworkController.delegate = self;
    
    [self.thisNetworkController sendMessageToServer:  [NSString stringWithFormat:@"%@%@", @"gameState:",self.gameID]];
    
        
}




-(void)SetArtAssets{
    
    
    TeamID1=@"Coal";
    TeamID2=@"Diamond";
    
    //Set inactive art assets
    
    if( TeamID1==@"Coal"){InactiveCellTeam1=[UIImage imageNamed:@"Inactive Coal.png"];}
    if( TeamID1==@"Diamond"){InactiveCellTeam1=[UIImage imageNamed:@"Inactive Diamond.png"];}
    if( TeamID1==@"Gold"){InactiveCellTeam1=[UIImage imageNamed:@"Inactive Gold.png"];}
    if( TeamID1==@"Silica"){InactiveCellTeam1=[UIImage imageNamed:@"Inactive Silica.png"];}
    
    if( TeamID2==@"Coal"){InactiveCellTeam2=[UIImage imageNamed:@"Inactive Coal.png"];}
    if( TeamID2==@"Diamond"){InactiveCellTeam2=[UIImage imageNamed:@"Inactive Diamond.png"];}
    if( TeamID2==@"Gold"){InactiveCellTeam2=[UIImage imageNamed:@"Inactive Gold.png"];}
    if( TeamID2==@"Silica"){InactiveCellTeam2=[UIImage imageNamed:@"Inactive Silica.png"];}
    
    
    //Set active art assets
    
    if( TeamID1==@"Coal"){ActiveCellTeam1=[UIImage imageNamed:@"Active Coal.png"];}
    if( TeamID1==@"Diamond"){ActiveCellTeam1=[UIImage imageNamed:@"Active Diamond.png"];}
    if( TeamID1==@"Gold"){ActiveCellTeam1=[UIImage imageNamed:@"Active Gold.png"];}
    if( TeamID1==@"Silica"){ActiveCellTeam1=[UIImage imageNamed:@"Active Silica.png"];}
    
    if( TeamID2==@"Coal"){ActiveCellTeam2=[UIImage imageNamed:@"Active Coal.png"];}
    if( TeamID2==@"Diamond"){ActiveCellTeam2=[UIImage imageNamed:@"Active Diamond.png"];}
    if( TeamID2==@"Gold"){ActiveCellTeam2=[UIImage imageNamed:@"Active Gold.png"];}
    if( TeamID2==@"Silica"){ActiveCellTeam2=[UIImage imageNamed:@"Active Silica.png"];}
    
    
    //Set neutral tile assets
    
    NeutralTile=[UIImage imageNamed:@"Inactive Neutral.png"];
    
    
    //Set background type
    
    if( TeamID1==@"Coal"){TeamBackground=[UIImage imageNamed:@"Coal Background.png"];}
    if( TeamID1==@"Diamond"){TeamBackground=[UIImage imageNamed:@"Diamond Background.png"];}
    if( TeamID1==@"Gold"){TeamBackground=[UIImage imageNamed:@"Gold Background.png"];}
    if( TeamID1==@"Silica"){TeamBackground=[UIImage imageNamed:@"Inactive Silica.png"];}
    
}






@end
