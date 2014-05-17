//
//  SASplashViewController.m
//  SmartAssist
//
//  Created by Iulian Poenaru on 17/05/14.
//  Copyright (c) 2014 COM.SmartAssist. All rights reserved.
//

#import "SASplashViewController.h"
#import "SADefines.h"

#import "SARequestManager.h"
#import "SACoreDataManager.h"
#import "SAUser.h"

#import "ESTBeaconManager.h"

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

@interface SASplashViewController () <ESTBeaconManagerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView    * imageViewLogo;
@property (weak, nonatomic) IBOutlet UILabel        * labelHello;

@property (strong, nonatomic) ESTBeaconManager      * beaconManager;

@property (strong, nonatomic) UIImageView           * positionDot;

@property (assign, nonatomic) CGFloat               dotMinPos;
@property (assign, nonatomic) CGFloat               dotRange;

@property (weak, nonatomic) IBOutlet UILabel        * labelDistance;
@property (weak, nonatomic) IBOutlet UILabel *labelClosestBeacon;

@property (strong, nonatomic) NSMutableArray        * availableBeacons;

@end


@implementation SASplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.availableBeacons = [NSMutableArray array];
    
    // TODO: GET USER and Event Request Request
    
    [[SARequestManager sharedManager] getUserRequestWithCompletionBlock:^(id obj) {
        SALog(@"Received user: %@", obj);
    }];
    
    [[SARequestManager sharedManager] getEventsRequestWithCompletionBlock:^(id obj) {
        SALog(@"Received user: %@", obj);
    }];
    
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
    
    
    /////////////////////////////////////////////////////////////
    // setup Estimote beacon manager
    
    [self setupView];
    
    [self.view bringSubviewToFront:self.labelDistance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Private Methods

- (void)setupView
{
    self.dotMinPos = 150;
    self.dotRange = 300.0;
    
    UIView *rangeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.dotRange, self.dotRange)];
    rangeView.backgroundColor = [UIColor greenColor];
    [rangeView setCenter:self.view.center];
    
    [self.view addSubview:rangeView];
    
    self.positionDot = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 20.0)];
    self.positionDot.backgroundColor = [UIColor redColor];
    [self.positionDot setCenter:self.view.center];
    [self.positionDot setAlpha:1.];
    
    [self.view addSubview:self.positionDot];
    
    
}

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
            beaconSErverID = @(1);
            break;
        case SABeaconGreen:
            beaconSErverID = @(2);
            break;
        case SABeaconPurple:
            beaconSErverID = @(3);
            break;
        case SABeaconIphoneCipri:
            beaconSErverID = @(4);
            break;
        case SABeaconIpadMini:
            beaconSErverID = @(5);
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

#pragma mark -
#pragma mark Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
	if ([identifier isEqualToString:@"mainSegueIdentifier"]) {
		return YES;
	}
	return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

#pragma mark -
#pragma mark Actions

- (void)goToMainScreen
{
    [self performSegueWithIdentifier:@"mainSegueIdentifier" sender:nil];
}

#pragma mark -
#pragma mark ESTMANAGER delegate

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
            
            // other measuring functionality
            float newYPos = ((float)beacon.rssi / -100.) * self.dotRange;
            self.positionDot.center = CGPointMake(self.view.bounds.size.width / 2, newYPos);
            
            NSString *beaconName = [self beaconNameForID:beacon.minor];
            [string appendString:[ NSString stringWithFormat:@"%@: %.2f meters\n", beaconName, [beacon.distance floatValue]]];
        }
        
        self.labelDistance.text = string;
        
        // sort beacons by distance
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
        self.availableBeacons = [NSMutableArray arrayWithArray: [self.availableBeacons sortedArrayUsingDescriptors:@[sortDescriptor]]];
        
        // maybe do some custom functionality where you are at the same distance between 2 beacons
        
        ESTBeacon *closestBeacon = [self.availableBeacons firstObject];
        
        self.labelClosestBeacon.text = [self beaconNameForID:closestBeacon.minor];
        
        [[SARequestManager sharedManager] postEventRequestWithID:[self serverIDForBeaconID:closestBeacon.minor] distance:closestBeacon.distance CompletionBlock:NULL];
        
        return;
    }
    
    self.labelClosestBeacon.text    = @"No beacon in range";
    self.labelDistance.text         = @"0.00 meters";
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
