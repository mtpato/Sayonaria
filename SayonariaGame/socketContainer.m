//
//  socketContainer.m
//  SayonariaGame
//
//  Created by Ian Pytlarz on 9/1/12.
//
//

#import "socketContainer.h"

@implementation socketContainer
@synthesize someProperty;

#pragma mark Singleton Methods

+ (id)sharedSockets {
    static socketContainer *sharedSocketContainer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSocketContainer = [[self alloc] init];
    });
    return sharedSocketContainer;
}

- (id)init {
    if (self = [super init]) {
        someProperty = @"Default Property Value";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
@end
