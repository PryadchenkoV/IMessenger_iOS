//
//  TypesObjC.m
//  IMessenger_iOS
//
//  Created by Ivan Pryadchenko on 29.11.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

#import "TypesObjC.h"
#include "types.h"

#pragma mark - MessageContent

@implementation MessageContentObjC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.encrypted = NO;
        self.type = Text;
    }
    return self;
}

@end

#pragma mark - Message

@implementation Message

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.date = 0;
    }
    return self;
}

@end

#pragma mark - SecurityPolicy

@implementation SecurityPolicyObjC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.encriptionAlgo = None;
    }
    return self;
}

@end
