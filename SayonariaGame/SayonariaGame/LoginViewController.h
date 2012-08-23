//
//  LoginViewController.h
//  SayonariaGame
//
//  Created by Ian Pytlarz on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"

@interface LoginViewController : UIViewController <NSStreamDelegate>
@property (nonatomic,strong) NSInputStream *inputStream;
@property (nonatomic,strong) NSOutputStream *outputStream;
@property (nonatomic, weak) IBOutlet UITextField *UserName;
@property (nonatomic, weak) IBOutlet UITextField *Password;
@end