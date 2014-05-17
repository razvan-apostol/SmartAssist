//
//  SARequestManager.m
//  SmartAssist
//
//  Created by Iulian Poenaru on 17/05/14.
//  Copyright (c) 2014 COM.SmartAssist. All rights reserved.
//

#import "SARequestManager.h"
#import "AFNetworking.h"

@interface SARequestManager ()

@property (copy, nonatomic) RequestCompletionBlock completionBlock;

@property (strong, nonatomic) AFHTTPRequestOperationManager * operationManager;

@end

@implementation SARequestManager

+ (SARequestManager *)sharedManager
{
    static SARequestManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        self.operationManager = [AFHTTPRequestOperationManager manager];
    }
    
    return self;
}

#pragma mark -
#pragma mark Public Methods

- (void)getUserRequestWithCompletionBlock:(RequestCompletionBlock)completionBlock;
{
    self.completionBlock = completionBlock;
    
    [self.operationManager GET:@"http://10.2.1.193/api/User" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Users: %@", responseObject);
        
        [self executeComplitionBlockWithObj:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Users Error: %@", error);
        
        [self executeComplitionBlockWithObj:nil];
    }];
}

- (void)getEventsRequestWithCompletionBlock:(RequestCompletionBlock)completionBlock
{
    self.completionBlock = completionBlock;
    
    [self.operationManager GET:@"http://10.2.1.193/api/Beacon" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Events: %@", responseObject);
        
        [self executeComplitionBlockWithObj:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Events Error: %@", error);
        
        [self executeComplitionBlockWithObj:nil];
    }];
}

#pragma mark -
#pragma mark Private Methods

- (void)executeComplitionBlockWithObj:(id)obj
{
    if (self.completionBlock) {
        self.completionBlock(obj);
    }
}


@end
