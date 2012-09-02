//
//  NetworkStorageTabBarController.h
//  SayonariaGame
//
//  Created by Ian Pytlarz on 9/2/12.
//
//

#import <Foundation/Foundation.h>
#import "NetworkController.h"

@interface NetworkStorageTabBarController : UITabBarController
@property (nonatomic, strong) NetworkController *thisNetworkController;
@end
