//
//  MessengerObjC.h
//  IMessenger_iOS
//
//  Created by Ivan Pryadchenko on 28.11.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypesObjC.h"


extern NSString* kNSkNSNotificationOnMessageStatusChanged;
extern NSString* kNSNotificationOnMessageReceived;

@interface MessengerObjC : NSObject

@property(nonatomic,strong)NSString* userId;
@property(nonatomic,strong)NSString* password;

+(id)sharedManager;


-(void)loginWithUserId:(UserId)userId password:(NSString*)password completionBlock:(void(^)(operationResult))completionBlock;
-(void)disconnectFromServer;
-(void)requestActiveUsersWithEndBlock:(void(^)(operationResult,NSMutableArray*))completionBlock;
-(Message*)sendMessageToUser:(NSString*)user messageContent:(MessageContentObjC*)message;
-(void)sentMessageSeenWithId:(NSString*)messageID fromUser:(NSString*)userID;
-(void)registerObserver;
-(void)unregisterObserver;

@end
