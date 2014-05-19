//
//  SABaseRequest.m
//  SmartAssist
//
//  Created by Iulian Poenaru on 18/05/14.
//  Copyright (c) 2014 COM.SmartAssist. All rights reserved.
//

#import "SABaseRequest.h"
#import "SADefines.h"

#import "AFNetworking.h"
#import "SAEvent.h"
#import "SACoreDataManager.h"

NSString *const kIlieHalipHomeServerURL     = @"http://79.118.91.212:2500";
NSString *const kStartupServerURL           = @"http://10.2.1.193:2500";

@interface SABaseRequest ()

@property (strong, nonatomic) NSString              * serverBaseURL;
@property (nonatomic, copy) RequestCompletionBlock  completionBlock;

@end

@implementation SABaseRequest

- (id)init
{
    self = [super init];
    if (self) {
        BOOL isWorkServer = YES;
        self.serverBaseURL = (isWorkServer) ? kStartupServerURL : kIlieHalipHomeServerURL;
    }
    
    return self;
}

+ (void)GETUsersRequestWithCompletionBlock:(RequestCompletionBlock)completionBlock
{
    SABaseRequest *request = [[SABaseRequest alloc] init];
    request.completionBlock = completionBlock;
    
    NSString *url = [NSString stringWithFormat:@"%@/api/User", request.serverBaseURL];
    
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    operationManager.responseSerializer = [AFJSONResponseSerializer serializer];
    [operationManager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        SALog(@"Users: %@", responseObject);
        
        [request executeComplitionBlockWithObj:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        SALog(@"Users Error: %@", error);
        
        [request executeComplitionBlockWithObj:nil];
    }];
}
+ (void)GETEventsRequestWithCompletionBlock:(RequestCompletionBlock)completionBlock
{
    SABaseRequest *request = [[SABaseRequest alloc] init];
    request.completionBlock = completionBlock;
    
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/Beacon", request.serverBaseURL];
    [operationManager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        SALog(@"Events: %@", responseObject);
        
        [request executeComplitionBlockWithObj:responseObject];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        SALog(@"Events Error: %@", error);
        
        [request executeComplitionBlockWithObj:nil];
    }];
}

+ (void)POSTEventWithID:(NSNumber *)beaconID distance:(NSNumber *)distance completionBlock:(RequestCompletionBlock)completionBlock {
    SABaseRequest *request = [[SABaseRequest alloc] init];
    request.completionBlock = completionBlock;
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"Beacon"]       = beaconID;
    parameters[@"Timestamp"]    = @([[NSDate date] timeIntervalSince1970]);
    parameters[@"Distance"]     = distance;
    
    
    SAEvent *event = [[[SACoreDataManager sharedManager] fetchDataWithParameterBlock:^(NSFetchRequest *requestToBeParametered) {
        [requestToBeParametered setPredicate:[NSPredicate predicateWithFormat:@"beaconID == %@", beaconID]];
    } andTableName:@"SAEvent"] firstObject];
    
    parameters[@"Type"]     = (event) ? event.type : @(0);
    
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/Event", request.serverBaseURL];
    operationManager.responseSerializer = [AFJSONResponseSerializer serializer];
    [operationManager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        SALog(@"Event response: %@", responseObject);
        
        [request executeComplitionBlockWithObj:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        SALog(@"Event response Error: %@", error);
        
        [request executeComplitionBlockWithObj:nil];
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
