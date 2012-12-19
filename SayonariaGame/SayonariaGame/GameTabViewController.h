//
//  GameTabViewController.h
//  SayonariaGame
//
//  Created by Ian Pytlarz on 9/1/12.
//
//

#import <UIKit/UIKit.h>
#import "NetworkController.h"
#import "NetworkStorageTabBarController.h"
#import "GameScreenViewController.h"
#import "NewGameOptionsViewController.h"

@interface GameTabViewController : UIViewController <NetworkControllerDelegate,UITableViewDataSource,UITableViewDelegate,LoadingViewDelegate,UINavigationControllerDelegate>
@property (nonatomic,strong) UINavigationController *thisNavigationController;
@property (nonatomic,strong) NetworkController *thisNetworkController;
@property (nonatomic,strong) LoadingView * loader;
@property (nonatomic,weak) IBOutlet UIButton *gameNewButton;
@property (nonatomic,weak) IBOutlet UIButton *shopButton;
@property (nonatomic,weak) IBOutlet UIButton *optionsButton;
@property (nonatomic,weak) IBOutlet UIImageView *gamesBackground;
@end

