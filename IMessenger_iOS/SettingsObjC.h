//
//  SettingsObjC.h
//  IMessenger_iOS
//
//  Created by Ivan Pryadchenko on 29.11.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessengerSettings : NSObject

@property(nonatomic,strong)NSString* serverUrl;
@property(nonatomic,assign)unsigned short serverPort;

-(instancetype)init;

@end
