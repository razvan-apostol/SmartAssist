//
//  SABeaconManager.h
//  SmartAssist
//
//  Created by Iulian Poenaru on 18/05/14.
//  Copyright (c) 2014 COM.SmartAssist. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^BeaconNotifyBlock)(id obj, NSInteger beaconServerID);

typedef enum {
    SABeaconStart           = 1,
    SABeaconIntermediate    = 2,
    SABeaconStop            = 3,
    SABeaconError           = 4,
}SABeaconType;

@class ESTBeacon;

@interface SABeaconManager : NSObject

@property (nonatomic, copy) BeaconNotifyBlock  beaconNotifyBlock;

+ (SABeaconManager *)sharedManager;

- (ESTBeacon *)currentBeaconInNearProximity;

- (NSNumber *)serverIDForBeaconID:(NSNumber *)beaconID;

- (void)stopManager;

@end
