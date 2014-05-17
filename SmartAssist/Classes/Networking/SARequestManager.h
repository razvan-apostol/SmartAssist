//
//  SARequestManager.h
//  SmartAssist
//
//  Created by Iulian Poenaru on 17/05/14.
//  Copyright (c) 2014 COM.SmartAssist. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

typedef void (^RequestCompletionBlock)(id obj);

@interface SARequestManager : NSObject

+ (SARequestManager *)sharedManager;

// GET Requests
- (void)getUserRequestWithCompletionBlock:(RequestCompletionBlock)completionBlock;

- (void)getEventsRequestWithCompletionBlock:(RequestCompletionBlock)completionBlock;

@end
