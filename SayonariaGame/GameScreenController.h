//
//  GameScreenController.h
//  SayonariaGame
//
//  Created by Andrew Mueller on 8/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameScreenController : UIViewController


@property (weak, nonatomic) IBOutlet UIScrollView *GameBoardView;

@property (weak, nonatomic) IBOutlet UILabel *Team1Score;

@property (weak, nonatomic) IBOutlet UILabel *Team2Score;

@end
