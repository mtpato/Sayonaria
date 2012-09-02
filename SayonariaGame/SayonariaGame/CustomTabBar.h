//
//  CustomTabBar.h
//  SayonariaGame
//
//  Created by Ian Pytlarz on 9/1/12.
//
//

#import <Foundation/Foundation.h>
#import "LoginViewController.h"

@interface CustomTabBar : UITabBarController
@property (nonatomic,strong) LoginViewController *socketContainer;
@end
