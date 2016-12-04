//
//  MessengerObjC.h
//  IMessenger_iOS
//
//  Created by Ivan Pryadchenko on 28.11.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypesObjC.h"



@interface MessengerObjC : NSObject

@property(nonatomic,strong)NSString* userId;
@property(nonatomic,strong)NSString* password;

-(void)loginWithUserId:(UserId)userId password:(NSString*)password complitionBlock:(void(^)(operationResult))complitionBlock;

@end
