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
#import "GameTabViewController.h"
#import "NetworkStorageTabBarController.h"

@interface LoginViewController : UIViewController <NSStreamDelegate,UIAlertViewDelegate,UITextFieldDelegate,NewUserViewControllerDelegate,NetworkControllerDelegate>
@property (nonatomic,weak) IBOutlet UITextField *UserName;
@property (nonatomic,weak) IBOutlet UITextField *Password;
@property (nonatomic,weak) UIAlertView *alert;
@property (nonatomic,strong) NetworkController *thisNetworkController;
@property (nonatomic) ServerState *currentServerState;

@end