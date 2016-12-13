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


NSString* kNSkNSNotificationOnMessageStatusChanged = @"kNSNotificationOnMessageStatusChanged";
NSString* kNSNotificationOnMessageReceived = @"kNSNotificationOnMessageReceived";


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
        NSMutableDictionary* dictionaryToSend = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:msgId.c_str()], @"MessageID", nil];
    
        switch (status) {
            case messenger::message_status::Sending:
                [dictionaryToSend setObject:@"Sending" forKey:@"Status"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNSkNSNotificationOnMessageStatusChanged object: nil userInfo:dictionaryToSend];
                break;
            case messenger::message_status::Sent:
                [dictionaryToSend setObject:@"Sent" forKey:@"Status"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNSkNSNotificationOnMessageStatusChanged object: nil userInfo:dictionaryToSend];
                break;
            case messenger::message_status::FailedToSend:
                [dictionaryToSend setObject:@"FailedToSend" forKey:@"Status"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNSkNSNotificationOnMessageStatusChanged object: nil userInfo:dictionaryToSend];
                break;
            case messenger::message_status::Delivered:
                [dictionaryToSend setObject:@"Delivered" forKey:@"Status"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNSkNSNotificationOnMessageStatusChanged object: nil userInfo:dictionaryToSend];
                break;
            case messenger::message_status::Seen:
                [dictionaryToSend setObject:@"Seen" forKey:@"Status"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNSkNSNotificationOnMessageStatusChanged object: nil userInfo:dictionaryToSend];
                break;
            default:
                break;
        }
    }
    
    virtual void OnMessageReceived(const messenger::UserId& senderId, const messenger::Message& msg) override  {
        Message* tmpMessage = [[Message alloc]init];
        
        tmpMessage.identifier = [NSString stringWithUTF8String: msg.identifier.c_str()];
        tmpMessage.date = [NSDate dateWithTimeIntervalSince1970: msg.time];
        
        MessageContentObjC* tmpContent = [[MessageContentObjC alloc]init];
        tmpContent.encrypted = msg.content.encrypted;
        switch (msg.content.type) {
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
        std::string tmpString;
        for (auto const& value: msg.content.data) {
            tmpString += value;
        }
        tmpContent.data = [NSString stringWithUTF8String:tmpString.c_str()];
        tmpMessage.content = tmpContent;

        NSDictionary* tmpDictionary = [[NSDictionary alloc] initWithObjectsAndKeys: tmpMessage, @"Message", [NSString stringWithUTF8String:senderId.c_str()], @"Sender",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNSNotificationOnMessageReceived object: nil userInfo:tmpDictionary];
    }
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
        //messengerSettingsStruct.serverUrl = "195.123.211.113";
        m_IMessenger = messenger::GetMessengerInstance(messengerSettingsStruct);
    }
    return self;
}

-(Message*)convertCMessageToObj:(messenger::Message&)message {
    Message* tmpMessage = [[Message alloc]init];
    tmpMessage.identifier = [NSString stringWithUTF8String: message.identifier.c_str()];
    tmpMessage.date = [NSDate dateWithTimeIntervalSince1970: message.time];
    
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
    std::string tmpString;
    for (auto const& value: message.content.data) {
        tmpString += value;
    }
    tmpContent.data = [NSString stringWithUTF8String:tmpString.c_str()];
    tmpMessage.content = tmpContent;
    return tmpMessage;
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
                    tmpUser.userId = [NSString stringWithUTF8String:value.identifier.c_str()];
                    SecurityPolicyObjC* tmpSecurity = [[SecurityPolicyObjC alloc]init];
                    std::string tmpPubKey;
                    for (auto const& valueKey: value.securityPolicy.encryptionPubKey) {
                        tmpPubKey += valueKey;
                    }
                    tmpSecurity.encriptionPubKey = [NSString stringWithUTF8String:tmpPubKey.c_str()];
                    switch (value.securityPolicy.encryptionAlgo) {
                        case messenger::encryption_algorithm::None :
                            tmpSecurity.encriptionAlgo = None;
                            break;
                        case messenger::encryption_algorithm::RSA_1024 :
                            tmpSecurity.encriptionAlgo = RSA_1024;
                            break;
                        default:
                            break;
                    }
                    tmpUser.securityPolicy = tmpSecurity;
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
    std::vector<unsigned char> vectorData(dataFormNSString.begin(),dataFormNSString.end()) ;
//    for (std::string::iterator it = std::string([message.data UTF8String]).begin() ; it < std::string([message.data UTF8String]).end(); ++it) {
//        vectorData.push_back(*it);
//
//    }
    switch (message.type) {
        case Text:
            messageContent.type = messenger::message_content_type::Text;
            break;
        case Image:
            messageContent.type = messenger::message_content_type::Image;
            break;
        case Video:
            messageContent.type = messenger::message_content_type::Video;
            break;
        default:
            break;
    }
    messageContent.data = vectorData;
    
    messenger::Message sentMessageC = m_IMessenger->SendMessage(std::string([user UTF8String]).c_str(), messageContent);
    Message* sentMessageObjC = [[Message alloc]init];
    sentMessageObjC = [self convertCMessageToObj: sentMessageC]; 
    return sentMessageObjC;
}

-(void)sentMessageSeenWithId:(NSString*)messageID fromUser:(NSString*)userID {
    
    m_IMessenger->SendMessageSeen(std::string([userID UTF8String]), std::string([messageID UTF8String]));
}

-(void)registerObserver{
    m_IMessenger->RegisterObserver(&m_MessageObserver);
}

-(void)unregisterObserver {
    m_IMessenger->UnregisterObserver(&m_MessageObserver);
}

@end
