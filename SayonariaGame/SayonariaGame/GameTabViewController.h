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

@interface GameTabViewController : UIViewController <NetworkControllerDelegate>
@property (nonatomic,strong) NetworkController *thisNetworkController;
@end