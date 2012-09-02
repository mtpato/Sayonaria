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

@interface LoginViewController : UIViewController <NSStreamDelegate,UIAlertViewDelegate,UITextFieldDelegate,NewUserViewControllerDelegate>
@property (nonatomic,strong) NSInputStream *inputStream;
@property (nonatomic,strong) NSOutputStream *outputStream;
@property (nonatomic, weak) IBOutlet UITextField *UserName;
@property (nonatomic, weak) IBOutlet UITextField *Password;
@property (nonatomic, strong) UIAlertView *alert;

#pragma mark - definitions of default keys

#define NETWORK_CONTROLLER_KEY @"currentNetworkController"
#define USER_NAME @"UserName"
#define AUTH_KEY @"AuthKey"

#pragma mark - public API

-(void)sendMessageToServer: (NSString *)message;

#pragma mark - Typedef and property of server state

@property (nonatomic) ServerState *currentServerState;

@end