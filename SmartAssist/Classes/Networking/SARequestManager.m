//
//  SARequestManager.m
//  SmartAssist
//
//  Created by Iulian Poenaru on 17/05/14.
//  Copyright (c) 2014 COM.SmartAssist. All rights reserved.
//

#import "SARequestManager.h"
#import "AFNetworking.h"
#import "SADefines.h"

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
        SALog(@"Users: %@", responseObject);
        
        [self executeComplitionBlockWithObj:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        SALog(@"Users Error: %@", error);
        
        [self executeComplitionBlockWithObj:nil];
    }];
}

- (void)getEventsRequestWithCompletionBlock:(RequestCompletionBlock)completionBlock
{
    self.completionBlock = completionBlock;
    
    [self.operationManager GET:@"http://10.2.1.193/api/Beacon" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        SALog(@"Events: %@", responseObject);
        
        [self executeComplitionBlockWithObj:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        SALog(@"Events Error: %@", error);
        
        [self executeComplitionBlockWithObj:nil];
    }];
}

- (void)postEventRequestWithID:(NSNumber *)beaconID distance:(NSNumber *)distance CompletionBlock:(RequestCompletionBlock)completionBlock
{
    self.completionBlock = completionBlock;
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"Beacon"]       = beaconID;
    parameters[@"Timestamp"]    = @([[NSDate date] timeIntervalSince1970]);
    parameters[@"Distance"]     = distance;
    
    [self.operationManager POST:@"http://10.2.1.193:80/api/Event" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        SALog(@"Event response: %@", responseObject);
        
        [self executeComplitionBlockWithObj:nil];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        SALog(@"Event response Error: %@", error);
        
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
