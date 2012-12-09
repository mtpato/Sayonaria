//
//  NetworkController.h
//  SayonariaGame
//
//  Created by Ian Pytlarz on 9/2/12.
//
//

#import <Foundation/Foundation.h>
#import "LoadingView.h"

@class NetworkController;

#pragma mark - Typedef and property of server state

typedef enum {
    Connecting = 0,
    SendingGameType = 1,
    ConnectedAwaitingLogon = 2,
    InTabView = 3,
    TryingAuthKeyLogin = 4,
    InGameView = 5,
    FirstSocketFailed = 6,
    SigningOut = 7
} ServerState;

@protocol NetworkControllerDelegate
-(void)messageRecieved:(NSString *)messageFromServer;
@end

@interface NetworkController : NSObject <NSStreamDelegate>
@property (nonatomic,strong) NSInputStream *inputStream;
@property (nonatomic,strong) NSOutputStream *outputStream;
@property (nonatomic,weak) id<NetworkControllerDelegate> delegate;
@property (nonatomic) ServerState *currentServerState;
@property (nonatomic, strong) NSData *dataQueue;

#pragma mark - definitions of default keys

#define NETWORK_CONTROLLER_KEY @"currentNetworkController"
#define USER_NAME @"UserName"
#define AUTH_KEY @"AuthKey"

#pragma mark - public API

-(void)sendMessageToServer: (NSString *)message;
-(void)initNetworkCommunication;
-(void)closeNetworkCommunication;
-(void)setCurrentServerState:(ServerState *)currentServerState;
-(void)checkConnection;

@end
