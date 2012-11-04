//
//  NewUserViewController.h
//  SayonariaGame
//
//  Created by Ian Pytlarz on 8/27/12.
//
//

#import <UIKit/UIKit.h>
//#import "LoginViewController.h"

@class NewUserViewController;

@protocol NewUserViewControllerDelegate
-(void)removeNewUserViewController;
-(void)sendUserToServer:(NSString *)newUserCommand;
@end

@interface NewUserViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UIButton *registerUserButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (nonatomic, weak) id<NewUserViewControllerDelegate> delegate;
@end
