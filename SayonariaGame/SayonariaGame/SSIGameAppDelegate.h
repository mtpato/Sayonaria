//
//  SSIGameAppDelegate.h
//  SayonariaGame
//
//  Created by Ian Pytlarz on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkController.h"

@interface SSIGameAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NetworkController *currentNetworkController;
@property (strong, nonatomic) NSNumber *didQuitAlready;

@end
