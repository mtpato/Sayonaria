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

@interface GameScreenViewController : UIViewController <NetworkControllerDelegate>


@property (weak, nonatomic) IBOutlet UIScrollView *GameBoardView;
@property (nonatomic, strong) NetworkController *thisNetworkController;
@property (nonatomic, strong) NSString *opponentName;
@property (nonatomic, strong) NSString *gameID;

@end
