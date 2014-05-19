//
//  SABeaconManager.m
//  SmartAssist
//
//  Created by Iulian Poenaru on 18/05/14.
//  Copyright (c) 2014 COM.SmartAssist. All rights reserved.
//

#import "SABeaconManager.h"
#import "SADefines.h"

#import "ESTBeaconManager.h"
#import "SABaseRequest.h"

#import "SACoreDataManager.h"
#import "SAEvent.h"

#define ESTIMOTE_PROXIMITY_UUID             [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]
#define ESTIMOTE_MACBEACON_PROXIMITY_UUID   [[NSUUID alloc] initWithUUIDString:@"08D4A950-80F0-4D42-A14B-D53E063516E6"]
#define ESTIMOTE_IOSBEACON_PROXIMITY_UUID   [[NSUUID alloc] initWithUUIDString:@"8492E75F-4FD6-469D-B132-043FE94921D8"]

#define BLUE_BEACON_MAJOR_ID                (45024)
#define BLUE_BEACON_MINOR_ID                (26058)

#define GREEN_BEACON_MAJOR_ID               (62205)
#define GREEN_BEACON_MINOR_ID               (10847)

#define PURPLE_BEACON_MAJOR_ID              (63302)
#define PURPLE_BEACON_MINOR_ID              (42158)

#define IPHONE_CIPRIAN_BEACON_MAJOR_ID      (40668)
#define IPHONE_CIPRIAN_BEACON_MINOR_ID      (49668)

#define IPAD_MINI_BEACON_MAJOR_ID           (51073)
#define IPAD_MINI_BEACON_MINOR_ID           (51973)

typedef enum {
    SABeaconBlue = BLUE_BEACON_MINOR_ID,
    SABeaconGreen = GREEN_BEACON_MINOR_ID,
    SABeaconPurple = PURPLE_BEACON_MINOR_ID,
    SABeaconIphoneCipri = IPHONE_CIPRIAN_BEACON_MINOR_ID,
    SABeaconIpadMini = IPAD_MINI_BEACON_MINOR_ID,
}SABeaconColor;

@interface SABeaconManager ()

// beacon
@property (strong, nonatomic) ESTBeaconManager      * beaconManager;

@property (strong, nonatomic) ESTBeacon             * lastKnownBeacon;

@property (strong, nonatomic) NSMutableArray        * availableBeacons;

@end


@interface SABeaconManager (ESTBeaconManagerDelegateImplementation) <ESTBeaconManagerDelegate>
@end


@implementation SABeaconManager

static SABeaconManager *_beaconManager = nil;

+ (SABeaconManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _beaconManager = [[self alloc] init];
    });
    
    return _beaconManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.availableBeacons = [NSMutableArray array];
        
        /////////////////////////////////////////////////////////////
        // setup Estimote beacon manager
        
        // create manager instance
        self.beaconManager = [[ESTBeaconManager alloc] init];
        self.beaconManager.delegate = self;
        self.beaconManager.avoidUnknownStateBeacons = YES;
        
        // create sample region object (you can additionaly pass major / minor values)
        ESTBeaconRegion *beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                            identifier:@"EstimoteSampleRegion"];
        
        // start looking for estimtoe beacons in region
        // when beacon ranged beaconManager:didRangeBeacons:inRegion: invoked
        [self.beaconManager startRangingBeaconsInRegion:beaconRegion];
    }
    
    return self;
}

#pragma mark -
#pragma mark Public Methods

- (ESTBeacon *)currentBeaconInNearProximity
{
    return self.lastKnownBeacon;
}

- (void)stopManager
{
    [self.beaconManager stopAdvertising];
    [self.beaconManager stopEstimoteBeaconDiscovery];
}

#pragma mark -
#pragma mark Private Methods

- (NSString *)beaconNameForID:(NSNumber *)beaconID
{
    NSString *beaconName = nil;
    switch ([beaconID integerValue]) {
        case SABeaconBlue:
            beaconName = @"BLUE";
            break;
        case SABeaconGreen:
            beaconName = @"GREEN";
            break;
        case SABeaconPurple:
            beaconName = @"PURPLE";
            break;
        case SABeaconIphoneCipri:
            beaconName = @"iP Cipri";
            break;
        case SABeaconIpadMini:
            beaconName = @"IPad Mini";
            break;
        default:
            beaconName = [beaconID stringValue];
            break;
    }
    
    return beaconName;
}

- (NSNumber *)serverIDForBeaconID:(NSNumber *)beaconID
{
    NSNumber *beaconSErverID = nil;
    switch ([beaconID integerValue]) {
        case SABeaconBlue:
            beaconSErverID = @(4);
            break;
        case SABeaconGreen:
            beaconSErverID = @(3);
            break;
        case SABeaconPurple:
            beaconSErverID = @(2);
            break;
        case SABeaconIphoneCipri:
            beaconSErverID = @(5);
            break;
        case SABeaconIpadMini:
            beaconSErverID = @(1);
            break;
        default:
            beaconSErverID = beaconID;
            break;
    }
    
    return beaconSErverID;
}

- (NSInteger)indexForBeacon:(ESTBeacon *)beacon
{
    for (ESTBeacon *currentBeacon in self.availableBeacons) {
        if ([currentBeacon.minor isEqualToNumber:beacon.minor]) {
            return [self.availableBeacons indexOfObject:currentBeacon];
        }
    }
    
    return NSIntegerMax;
}

@end

@implementation SABeaconManager (ESTBeaconManagerDelegateImplementation)

#pragma mark -
#pragma mark ESTBeaconManagerDelegate Methods

- (void)beaconManager:(ESTBeaconManager *)manager
      didRangeBeacons:(NSArray *)beacons
             inRegion:(ESTBeaconRegion *)region
{
    
    if([beacons count] > 0) {
        // beacon array is sorted based on distance
        // closest beacon is the first one
        
        NSMutableString *string = [NSMutableString new];
        for (ESTBeacon *beacon in beacons) {
            
            // beacons found
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"minor == %@", beacon.minor];
            
            NSArray *foundBeacons = [self.availableBeacons filteredArrayUsingPredicate:predicate];
            
            if (!foundBeacons.count) {
                // add new beacon
                [self.availableBeacons addObject:beacon];
            } else {
                // update beacon
                
                // take the first beacon, there showed be only one
                NSInteger index = [self indexForBeacon:[foundBeacons firstObject]];
                
                if (index != NSIntegerMax) {
                    [self.availableBeacons replaceObjectAtIndex:index withObject:beacon];
                }
            }
//            if ([beacon.distance integerValue] == -1) {
//                beacon.distance = @(NSIntegerMax);
//            }
            
            NSString *beaconName = [self beaconNameForID:beacon.minor];
            [string appendString:[ NSString stringWithFormat:@"%@: %.2f meters\n", beaconName, [beacon.distance floatValue]]];
        }
        
        //        self.labelDistance.text = string;
        
        // sort beacons by distance
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
        self.availableBeacons = [NSMutableArray arrayWithArray: [self.availableBeacons sortedArrayUsingDescriptors:@[sortDescriptor]]];
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"distance != %@", @(-1)];
        self.availableBeacons = [NSMutableArray arrayWithArray: [self.availableBeacons filteredArrayUsingPredicate:predicate]];
        
        // maybe do some custom functionality where you are at the same distance between 2 beacons
        
        ESTBeacon *closestBeacon = [self.availableBeacons firstObject];
        
        // don't sent beacon if distance is -1, out of range, or faill shit, don't know
        if (closestBeacon && self.lastKnownBeacon && [self.lastKnownBeacon.minor isEqualToNumber:closestBeacon.minor] &&
            [self.lastKnownBeacon.distance integerValue] == -1 && [self.lastKnownBeacon.distance isEqualToNumber:closestBeacon.distance]) {
            self.lastKnownBeacon = nil;
            return;
        }
        
        NSNumber *beaconServerID = [self serverIDForBeaconID:closestBeacon.minor];
        
        if (!beaconServerID) {
            SALog(@"WTF");
        }
        
        if (![self.lastKnownBeacon isEqual:closestBeacon]) {
        
            if (self.beaconNotifyBlock) {
                
                // send only our beacon
                if (closestBeacon) {
                    self.beaconNotifyBlock(closestBeacon, [beaconServerID integerValue]);
                }
            }
            
            self.lastKnownBeacon = closestBeacon;
        } else {
            return;
        }
    
        
        SALog(@"POST EVENT");
        [SABaseRequest POSTEventWithID:beaconServerID distance:closestBeacon.distance completionBlock:NULL];
        
        return;
    }
    
    //    self.labelClosestBeacon.text    = @"No beacon in range";
    //    self.labelDistance.text         = @"0.00 meters";
}

- (NSNumberFormatter *)twoDecimalFormat
{
    NSNumberFormatter *doubleValueWithMaxTwoDecimalPlaces = [[NSNumberFormatter alloc] init];
    [doubleValueWithMaxTwoDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
    [doubleValueWithMaxTwoDecimalPlaces setPaddingPosition:NSNumberFormatterPadAfterSuffix];
    [doubleValueWithMaxTwoDecimalPlaces setFormatWidth:2];
    
    return doubleValueWithMaxTwoDecimalPlaces;
}

- (void)beaconManager:(ESTBeaconManager *)manager
    didDetermineState:(CLRegionState)state
            forRegion:(ESTBeaconRegion *)region
{
    //    if(state == CLRegionStateInside)
    //    {
    //        [self setProductImage];
    //    }
    //    else
    //    {
    //        [self setDiscountImage];
    //    }
}

- (void)beaconManager:(ESTBeaconManager *)manager
       didEnterRegion:(ESTBeaconRegion *)region
{
    // iPhone/iPad entered beacon zone
    //    [self setProductImage];
}

- (void)beaconManager:(ESTBeaconManager *)manager
        didExitRegion:(ESTBeaconRegion *)region
{
    // iPhone/iPad left beacon zone
    //    [self setDiscountImage];
    
    // present local notification
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = [NSString stringWithFormat:@"You exit beacon %@ range!", [self beaconNameForID:region.minor]];
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

@end
