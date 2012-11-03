//
//  NewGameOptionsViewController.h
//  SayonariaGame
//
//  Created by Ian Pytlarz on 11/1/12.
//
//

#import <UIKit/UIKit.h>
#import "NetworkController.h"
#import "NetworkStorageTabBarController.h"
#import "GameScreenViewController.h"

@interface NewGameOptionsViewController : UIViewController<NetworkControllerDelegate,LoadingViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) NetworkController *thisNetworkController;
@property (nonatomic,strong) LoadingView * loader;
@property (nonatomic,weak) IBOutlet UIButton *background;
@property (nonatomic,weak) IBOutlet UITextField *opponentNameBox;
@property (nonatomic,weak) IBOutlet UIButton *opponentButton;
@property (nonatomic,weak) IBOutlet UIButton *randomButton;
@property (nonatomic, weak) IBOutlet UILabel *orLabel;
@property (nonatomic, weak) IBOutlet UILabel *opponentTypeLabel;

@end
