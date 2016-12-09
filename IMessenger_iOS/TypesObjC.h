//
//  TypesObjC.h
//  IMessenger_iOS
//
//  Created by Ivan Pryadchenko on 29.11.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - enum init

typedef enum {
    Ok,
    AuthError,
    NetworkError,
    InternalError
}operationResult;

typedef enum messageStatus{
    Sending,
    Sent,
    FailedToSend,
    Delivered,
    Seen
}messageStatus;


typedef enum {
    None,
    RSA_1024
}encryptionAlgorithmType;



typedef enum {
    Text,
    Image,
    Video
}messageContentType;

typedef NSMutableArray* Data;
typedef NSMutableArray* SecPublicKey;
typedef NSString* MessageId;
typedef NSString* UserId;


#pragma mark - MessageContent

@interface MessageContentObjC : NSObject <NSCoding>

@property(nonatomic) messageContentType type;
@property(assign,nonatomic) BOOL encrypted;
@property(nonatomic) NSString* data;

-(instancetype)init;

@end

#pragma mark - Message


@interface Message : NSObject <NSCoding>

@property MessageId identifier;
@property(assign,nonatomic) NSDate* date;
@property(nonatomic) MessageContentObjC* content;

-(instancetype)init;

@end


#pragma mark - SecurityPolicy

@interface SecurityPolicyObjC : NSObject

@property (nonatomic,strong) SecPublicKey encriptionPubKey;
@property (nonatomic) encryptionAlgorithmType encriptionAlgo;

-(instancetype)init;

@end

#pragma mark - User

@interface UserObjC : NSObject

@property UserId userId;
@property SecurityPolicyObjC* securityPolicy;

- (instancetype)init;

@end

typedef NSMutableArray* UserListObjC;

