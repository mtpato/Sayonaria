//
//  LoginViewController.h
//  SayonariaGame
//
//  Created by Ian Pytlarz on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"
#import "NewUserViewController.h"
#import "NetworkController.h"

@interface LoginViewController : UIViewController <NSStreamDelegate,UIAlertViewDelegate,UITextFieldDelegate,NewUserViewControllerDelegate,NetworkControllerDelegate>
@property (nonatomic, weak) IBOutlet UITextField *UserName;
@property (nonatomic, weak) IBOutlet UITextField *Password;
@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic,weak) NetworkController *thisNetworkController;
@property (nonatomic) ServerState *currentServerState;

#pragma mark - definitions of default keys

#define NETWORK_CONTROLLER_KEY @"currentNetworkController"
#define USER_NAME @"UserName"
#define AUTH_KEY @"AuthKey"

@end