//
//  OptionsTabViewController.h
//  SayonariaGame
//
//  Created by Ian Pytlarz on 9/15/12.
//
//

#import <UIKit/UIKit.h>
#import "NetworkController.h"
#import "NetworkStorageTabBarController.h"
#import "LoginViewController.h"

@interface OptionsTabViewController : UIViewController <NetworkControllerDelegate,LoadingViewDelegate>

@property (nonatomic,strong) NetworkController *thisNetworkController;
@property (nonatomic, weak) IBOutlet UIButton *signOutButton;
@property (nonatomic, strong) LoadingView *loader;

@end
