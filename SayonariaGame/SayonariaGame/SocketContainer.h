//
//  SocketContainer.h
//  SayonariaGame
//
//  Created by Ian Pytlarz on 9/1/12.
//
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LoginViewController.h"

@interface SocketContainer : NSObject {
    LoginViewController *currentLoginController;
}

@property (nonatomic, strong) LoginViewController *currentLoginController;

+ (id)sharedSockets;

@end