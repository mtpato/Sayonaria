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

@interface LoginViewController : UIViewController <NSStreamDelegate,UIAlertViewDelegate,UITextFieldDelegate,NewUserViewControllerDelegate>
@property (nonatomic,strong) NSInputStream *inputStream;
@property (nonatomic,strong) NSOutputStream *outputStream;
@property (nonatomic, weak) IBOutlet UITextField *UserName;
@property (nonatomic, weak) IBOutlet UITextField *Password;
@property (nonatomic, strong) UIAlertView *alert;

-(void)sendMessageToServer: (NSString *)message;

typedef enum {
    Connecting = 0,
    SendingGameType = 1,
    ConnectedAwaitingLogon = 2,
    InTabView = 3,
    TryingAuthKeyLogin = 4,
    InGameView = 5
} ServerState;

@property (nonatomic) ServerState *currentServerState;
@end