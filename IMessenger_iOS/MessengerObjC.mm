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


@interface MessengerObjC()
{
    std::shared_ptr<messenger::IMessenger>   m_IMessenger;
    LoginCallbackObjC        m_LoginCallback;
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
        messengerSettingsStruct.serverUrl = "192.168.0.105";
        m_IMessenger = messenger::GetMessengerInstance(messengerSettingsStruct);
    }
    return self;
}

-(void)loginWithUserId:(UserId)userId password:(NSString*)password complitionBlock:(void(^)(operationResult))complitionBlock {
    self.isConnecting = YES;
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
        //self.connectionStatus = result;
    };

    messenger::SecurityPolicy securityPolicyStruct;

    self.isConnecting = YES;
    std::string userID = std::string([userId UTF8String]);
    std::string userPassWord =std::string([password UTF8String]);
    
    
    m_IMessenger->Login(userID, userPassWord, securityPolicyStruct, &m_LoginCallback);

}



@end
