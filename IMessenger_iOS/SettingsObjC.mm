//
//  SettingsObjC.m
//  IMessenger_iOS
//
//  Created by Ivan Pryadchenko on 29.11.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

#import "SettingsObjC.h"
#include "settings.h"

@implementation MessengerSettings

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.serverPort = 0;
    }
    return self;
}

@end
