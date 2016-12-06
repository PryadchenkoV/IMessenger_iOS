//
//  MessengerObjC.m
//  IMessenger_iOS
//
//  Created by Ivan Pryadchenko on 28.11.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

#import "MessengerObjC.h"
#import "SettingsObjC.h"
#include "messenger.h"
#include "callbacks.h"


class LoginCallbackObjC : public messenger::ILoginCallback
{
public:
    
    virtual void OnOperationResult(messenger::operation_result::Type result) override
    {
        if (m_handler) {
            m_handler(result);
        }
        
    }
    void (^m_handler)(messenger::operation_result::Type) = 0;
};


class RequestUsersCallbackObjC : public messenger::IRequestUsersCallback
{
public:
    virtual void OnOperationResult(messenger::operation_result::Type result, const messenger::UserList& users) override {
        if (m_handler) {
            m_handler(result,users);
        }

    }
    void (^m_handler)(messenger::operation_result::Type,const messenger::UserList&) = 0;
};


@interface MessengerObjC()
{
    std::shared_ptr<messenger::IMessenger>   m_IMessenger;
    LoginCallbackObjC                        m_LoginCallback;
    RequestUsersCallbackObjC                 m_RequestLoginCallback;
}
@property(assign) BOOL isConnecting;
@property(assign) operationResult connectionStatus;

@end

@implementation MessengerObjC
- (instancetype)init
{
    self = [super init];
    if (self) {
        messenger::MessengerSettings messengerSettingsStruct;
        //messengerSettingsStruct.serverUrl = "192.168.0.105";
        m_IMessenger = messenger::GetMessengerInstance(messengerSettingsStruct);
    }
    return self;
}

-(void)loginWithUserId:(UserId)userId password:(NSString*)password completionBlock:(void(^)(operationResult))complitionBlock {
    
    m_LoginCallback.m_handler = ^(messenger::operation_result::Type result){
        self.isConnecting = NO;
        switch (result) {
            case messenger::operation_result::Type::Ok:
                complitionBlock(Ok);
                break;
            case messenger::operation_result::Type::AuthError:
                complitionBlock(AuthError);
                break;
            case messenger::operation_result::Type::InternalError:
                complitionBlock(InternalError);
                break;
            case messenger::operation_result::Type::NetworkError:
                complitionBlock(NetworkError);
                break;
            default:
                break;
        }
    };

    messenger::SecurityPolicy securityPolicyStruct;

    std::string userID = std::string([userId UTF8String]);
    std::string userPassWord =std::string([password UTF8String]);
    
    
    m_IMessenger->Login(std::string([userId UTF8String]), std::string([password UTF8String]), securityPolicyStruct, &m_LoginCallback);

}

-(void)disconnectFromServer{
    m_IMessenger->Disconnect();
}

-(void)requestActiveUsersWithEndBlock:(void(^)(operationResult,NSMutableArray*))completionBlock{
    m_RequestLoginCallback.m_handler = ^(messenger::operation_result::Type result, const messenger::UserList& user){
        NSMutableArray* usersOnline = [[NSMutableArray alloc]init];
        switch (result) {
            case messenger::operation_result::Type::Ok:
                for(messenger::User const& value: user) {
                    UserObjC* tmpUser = [[UserObjC alloc]init];
                    tmpUser.userId = [NSString stringWithCString:value.identifier.c_str()
                                                        encoding:[NSString defaultCStringEncoding]];
                    [usersOnline addObject: tmpUser];
                }
                completionBlock(Ok,usersOnline);
                break;
            case messenger::operation_result::Type::AuthError:
                completionBlock(AuthError,nil);
                break;
            case messenger::operation_result::Type::InternalError:
                completionBlock(InternalError,nil);
                break;
            case messenger::operation_result::Type::NetworkError:
                completionBlock(NetworkError,nil);
                break;
            default:
                break;
        }
    };
    m_IMessenger->RequestActiveUsers(&m_RequestLoginCallback);
}

@end
