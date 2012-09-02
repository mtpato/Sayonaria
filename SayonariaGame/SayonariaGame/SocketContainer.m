//
//  SocketContainer.m
//  SayonariaGame
//
//  Created by Ian Pytlarz on 9/1/12.
//
//

#import "SocketContainer.h"

@implementation SocketContainer
@synthesize currentLoginController;

#pragma mark Singleton Methods

+ (id)sharedSockets {
    static SocketContainer *sharedSocketContainer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSocketContainer = [[self alloc] init];
    });
    return sharedSocketContainer;
}

- (id)init {
    if (self = [super init]) {
        currentLoginController = [[LoginViewController alloc] init];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
@end

