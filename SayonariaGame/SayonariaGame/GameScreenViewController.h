//
//  GameScreenViewController.h
//  SayonariaGame
//
//  Created by Andrew Mueller on 9/3/12.
//
//

#import <UIKit/UIKit.h>
#import "NetworkController.h"
#import "NetworkStorageTabBarController.h"

@interface GameScreenViewController : UIViewController <NetworkControllerDelegate,LoadingViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *BackgroundView;

@property (weak, nonatomic) IBOutlet UIScrollView *gameBoardView;
@property (nonatomic,strong) LoadingView * loader;
@property (nonatomic, strong) NetworkController *thisNetworkController;
@property (nonatomic, strong) NSString *opponentName;
@property (nonatomic, strong) NSString *gameID;

@end
