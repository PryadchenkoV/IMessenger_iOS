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
#include "observers.h"


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




class MessagesObserverObjC : public messenger::IMessagesObserver
{
public:
    
    virtual void OnMessageStatusChanged(const messenger::MessageId& msgId, messenger::message_status::Type status) override {
        if(m_handlerMessageStatusChanged){
            m_handlerMessageStatusChanged(msgId,status);
        }
    }
    virtual void OnMessageReceived(const messenger::UserId& senderId, const messenger::Message& msg) override  {
        if(m_handlerMessageReceived){
            m_handlerMessageReceived(senderId,msg);
        }
    }
    
    void (^m_handlerMessageStatusChanged)(const messenger::MessageId&, messenger::message_status::Type) = 0;
    void (^m_handlerMessageReceived)(const messenger::UserId&, const messenger::Message&) = 0;
};



@interface MessengerObjC()
{
    std::shared_ptr<messenger::IMessenger>   m_IMessenger;
    LoginCallbackObjC                        m_LoginCallback;
    RequestUsersCallbackObjC                 m_RequestLoginCallback;
    MessagesObserverObjC                     m_MessageObserver;
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
    std::string userPassWord = std::string([password UTF8String]);
    
    
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

-(Message*)sendMessageToUser:(NSString*)user messageContent:(MessageContentObjC*)message {
    messenger::MessageContent messageContent = *new messenger::MessageContent;
    
    
    std::string dataFormNSString = std::string([message.data UTF8String]);
    std::vector<unsigned char> vectorData;
    for (std::string::iterator it = dataFormNSString.begin() ; it < dataFormNSString.end(); ++it) {
        vectorData.push_back(*it);

    }
    messageContent.data = vectorData;
    
    messenger::Message sentMessageC = m_IMessenger->SendMessage(std::string([user UTF8String]).c_str(), messageContent);
    
    Message* sentMessageObjC = [[Message alloc]init];
    sentMessageObjC.identifier = [NSString stringWithCString:sentMessageC.identifier.c_str()
                                                    encoding:[NSString defaultCStringEncoding]];
    sentMessageObjC.date = [NSDate dateWithTimeIntervalSince1970:sentMessageC.time];
    
    MessageContentObjC* tmpContent = [[MessageContentObjC alloc]init];
    tmpContent.encrypted = sentMessageC.content.encrypted;
    switch (sentMessageC.content.type) {
        case messenger::message_content_type::Text:
            tmpContent.type = Text;
            break;
        case messenger::message_content_type::Image:
            tmpContent.type = Image;
            break;
        case messenger::message_content_type::Video:
            tmpContent.type = Video;
            break;
        default:
            break;
    }
    tmpContent.data = message.data;
    sentMessageObjC.content = tmpContent;
    
    return sentMessageObjC;
}

-(void)sentMessageSeenWithId:(NSString*)messageID fromUser:(NSString*)userID {
    m_IMessenger->SendMessageSeen(std::string([userID UTF8String]), std::string([messageID UTF8String]));
}

-(void)registerObserverWithCompletionBlock:(void(^)(UserId,Message*, messageStatus))completionBlock  {
    m_MessageObserver.m_handlerMessageReceived = ^(const messenger::UserId& userID, const messenger::Message& message){
        
        Message* tmpMessage = [[Message alloc]init];
        tmpMessage.identifier = [NSString stringWithCString:message.identifier.c_str()
                                                        encoding:[NSString defaultCStringEncoding]];
        tmpMessage.date = [NSDate dateWithTimeIntervalSince1970:message.time];
        
        MessageContentObjC* tmpContent = [[MessageContentObjC alloc]init];
        tmpContent.encrypted = message.content.encrypted;
        switch (message.content.type) {
            case messenger::message_content_type::Text:
                tmpContent.type = Text;
                break;
            case messenger::message_content_type::Image:
                tmpContent.type = Image;
                break;
            case messenger::message_content_type::Video:
                tmpContent.type = Video;
                break;
            default:
                break;
        }
        NSMutableString* tmpString = [[NSMutableString alloc]init];
        for(char const& value: message.content.data) {
            [tmpString appendFormat:@"%c", value];
        }
        tmpContent.data = tmpString;
        tmpMessage.content = tmpContent;

        completionBlock([NSString stringWithCString:userID.c_str()
                                           encoding:[NSString defaultCStringEncoding]],tmpMessage,FailedToSend);
    };
    
    m_MessageObserver.m_handlerMessageStatusChanged = ^(const messenger::MessageId& messageID, messenger::message_status::Type messageStatus){
        enum messageStatus tmpStatus;
        switch (messageStatus) {
            case messenger::message_status::Type::Sending:
                tmpStatus = Sending;
                break;
            case messenger::message_status::Type::Sent:
                tmpStatus = Sent;
                break;
            case messenger::message_status::Type::FailedToSend:
                tmpStatus = FailedToSend;
                break;
            case messenger::message_status::Type::Delivered:
                tmpStatus = Delivered;
                break;
            case messenger::message_status::Type::Seen:
                tmpStatus = Seen;
                break;
            default:
                break;
        }
        Message* tmpMessage = [[Message alloc]init];
        tmpMessage.identifier = [NSString stringWithCString:messageID.c_str()
                                                   encoding:[NSString defaultCStringEncoding]];
        completionBlock(nil,tmpMessage,tmpStatus);
    };
    m_IMessenger->RegisterObserver(&m_MessageObserver);
}

@end
