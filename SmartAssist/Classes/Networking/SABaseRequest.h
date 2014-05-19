//
//  SABaseRequest.h
//  SmartAssist
//
//  Created by Iulian Poenaru on 18/05/14.
//  Copyright (c) 2014 COM.SmartAssist. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RequestCompletionBlock)(id obj);

@interface SABaseRequest : NSObject

+ (void)GETUsersRequestWithCompletionBlock:(RequestCompletionBlock)completionBlock;
+ (void)GETEventsRequestWithCompletionBlock:(RequestCompletionBlock)completionBlock;

+ (void)POSTEventWithID:(NSNumber *)beaconID distance:(NSNumber *)distance completionBlock:(RequestCompletionBlock)completionBlock;

- (void)executeComplitionBlockWithObj:(id)obj;

@end
