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

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.data = [decoder decodeObjectForKey:@"data"];
        self.encrypted = [decoder decodeBoolForKey:@"encrypted"];
        self.type = messageContentType([decoder decodeIntegerForKey:@"type"]);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject: self.data forKey: @"data"];
    [encoder encodeBool: self.encrypted forKey: @"encrypted"];
    [encoder encodeInteger: self.type forKey: @"type"];
}

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

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.identifier = [decoder decodeObjectForKey:@"identifier"];
        self.date = [decoder decodeObjectForKey:@"date"];
        self.content = [decoder decodeObjectForKey:@"content"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.identifier forKey:@"identifier"];
    [encoder encodeObject:self.date forKey:@"date"];
    [encoder encodeObject:self.content forKey:@"content"];
}

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

@implementation UserObjC

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

@end
