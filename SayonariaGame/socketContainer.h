//
//  socketContainer.h
//  SayonariaGame
//
//  Created by Ian Pytlarz on 9/1/12.
//
//

#import <Foundation/Foundation.h>

@interface socketContainer : NSObject {
NSString *someProperty;
}

@property (nonatomic, strong) NSString *someProperty;

+ (id)sharedSockets;

@end
