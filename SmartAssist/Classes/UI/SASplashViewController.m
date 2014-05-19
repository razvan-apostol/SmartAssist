//
//  SASplashViewController.m
//  SmartAssist
//
//  Created by Iulian Poenaru on 17/05/14.
//  Copyright (c) 2014 COM.SmartAssist. All rights reserved.
//

#import "SASplashViewController.h"
#import "SAEventTableViewCell.h"
#import "SAMainViewController.h"
#import "SADefines.h"

#import "SABaseRequest.h"
#import "SACoreDataManager.h"
#import "SAUser.h"
#import "SAEvent.h"

#import "ESTBeaconManager.h"
#import "SABeaconManager.h"

@interface SASplashViewController ()

@property (weak, nonatomic) IBOutlet UIImageView    * imageViewLogo;
@property (weak, nonatomic) IBOutlet UILabel        * labelHello;
@property (weak, nonatomic) IBOutlet UITableView    * tableViewDestination;

@property (assign, nonatomic) BOOL                  isReadyToStartJourney;
@property (strong, nonatomic) UIAlertView           * welcomeAlertView;

// data source
@property (strong, nonatomic) NSMutableArray               * locationsArray;

@end


@interface SASplashViewController (UIAlertViewDelegateImplementation) <UIAlertViewDelegate>
@end

@interface SASplashViewController (UITableViewDelegateAndDataSourceImplementation) <UITableViewDataSource, UITableViewDelegate>
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
    
    self.navigationController.navigationBarHidden = YES;
    
    [SABeaconManager sharedManager];
    
    self.locationsArray = [NSMutableArray array];
    
    // TODO: GET USER and Event Request Request
    
    self.welcomeAlertView = [[UIAlertView alloc] initWithTitle:@"Hello John! Welcome to Startup weekend! Please wait while we identify your location!" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [self.welcomeAlertView show];
    
    [self displaySpinner];
    [SABaseRequest GETUsersRequestWithCompletionBlock:^(id obj) {
        
        NSArray *users = (NSArray *)obj;
        
        if (users.count) {
            NSDictionary *firstUserDict = [users firstObject];
            
            NSNumber *userID = firstUserDict[@"Id"];
            
            SAUser *user = [[[SACoreDataManager sharedManager] fetchDataWithParameterBlock:^(NSFetchRequest *requestToBeParametered) {
                [requestToBeParametered setPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", userID]];
            } andTableName:@"SAUser"] firstObject];
            
            if (!user) {
                user = [[SACoreDataManager sharedManager] insertDataforTableName:@"SAUser"];
            }
            
            user.identifier     = userID;
            user.name           = firstUserDict[@"Name"];
            
            NSString *url       = firstUserDict[@"Avatar"];
            user.url            = ([url isKindOfClass:[NSNull class]] || !url) ? nil : url;
            
            NSNumber *deviceID  = firstUserDict[@"DeviceId"];
            user.deviceID       = ([deviceID isKindOfClass:[NSNull class]] || !deviceID) ? nil : deviceID;
            
            [[SACoreDataManager sharedManager] save];
        }
    }];
    
    [SABaseRequest GETEventsRequestWithCompletionBlock:^(id obj) {
        NSArray *beacons = (NSArray *)obj;
        
        SAUser *currentUser = [[[SACoreDataManager sharedManager] fetchDataWithParameterBlock:^(NSFetchRequest *requestToBeParametered) {
        } andTableName:@"SAUser"] firstObject];
        
        for (NSDictionary *beaconDict in beacons) {
            NSNumber *beaconID = beaconDict[@"Id"];
            
            SAEvent *beacon = [[[SACoreDataManager sharedManager] fetchDataWithParameterBlock:^(NSFetchRequest *requestToBeParametered) {
                [requestToBeParametered setPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", beaconID]];
            } andTableName:@"SAEvent"] firstObject];
            
            if (!beacon) {
                beacon = [[SACoreDataManager sharedManager] insertDataforTableName:@"SAEvent"];
                [currentUser addEventsObject:beacon];
            }
            
            beacon.identifier   = beaconID;
            beacon.type         = @(0);
            beacon.name         = beaconDict[@"Name"];
            beacon.color        = beaconDict[@"Color"];
            beacon.beaconID     = beaconDict[@"BeaconId"];
            beacon.message      = beaconDict[@"Text"];
        }
        
        [[SACoreDataManager sharedManager] save];
        
        [self removeSpinner];
        
        self.isReadyToStartJourney = YES;
    }];
    
    [self performSelector:@selector(dismissWelcomeAlert) withObject:nil afterDelay:8.0];
}

- (void)fetchLocationsOrdered
{
    self.locationsArray = [NSMutableArray arrayWithArray:[[SACoreDataManager sharedManager] fetchDataWithParameterBlock:^(NSFetchRequest *requestToBeParametered) {
        [requestToBeParametered setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"beaconID" ascending:YES]]];
    } andTableName:@"SAEvent"]];
    
    ESTBeacon *currentBeacon = [[SABeaconManager sharedManager] currentBeaconInNearProximity];
    if (currentBeacon) {
        
        NSNumber *currentBeaconID = currentBeacon.minor;
        NSNumber *currentBeaconIDFromCD = [[SABeaconManager sharedManager] serverIDForBeaconID:currentBeaconID];
        
        SAEvent *currentEvent = [[[SACoreDataManager sharedManager] fetchDataWithParameterBlock:^(NSFetchRequest *requestToBeParametered) {
            [requestToBeParametered setPredicate:[NSPredicate predicateWithFormat:@"beaconID == %@", currentBeaconIDFromCD]];
        } andTableName:@"SAEvent"] firstObject];
        
        if (currentEvent) {
            currentEvent.type = @(SABeaconStart);
            [[SACoreDataManager sharedManager] save];
            
            [self.locationsArray removeObject:currentEvent];
        }
        
        NSString *currentLocation = [NSString stringWithFormat:@"John your current location is %@", currentEvent.name];
        self.welcomeAlertView = [[UIAlertView alloc] initWithTitle:currentLocation message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [self.welcomeAlertView show];
        
        [self performSelector:@selector(dismissCurrentLocationAlert) withObject:nil afterDelay:4.0];
    } else {
        
    }
}

- (void)dismissCurrentLocationAlert
{
    [self.welcomeAlertView dismissWithClickedButtonIndex:0 animated:YES];
    
    self.tableViewDestination.hidden = NO;
    [self.tableViewDestination reloadData];
}

- (void)dismissWelcomeAlert
{
    if (self.isReadyToStartJourney) {
        [self.welcomeAlertView dismissWithClickedButtonIndex:0 animated:YES];
        self.welcomeAlertView = nil;
        
        [self performSelector:@selector(showStartJourneyAlert) withObject:nil afterDelay:2.0];
        
        return;
    }
    
    [self performSelector:@selector(dismissWelcomeAlert) withObject:nil afterDelay:1.0];
}

- (void)showStartJourneyAlert
{
    // make Start Journey Alert
    self.welcomeAlertView = [[UIAlertView alloc] initWithTitle:@"We are ready to guide you! Please press start journey when ready and choose a destination from the list! " message:nil delegate:self cancelButtonTitle:@"Start Journey" otherButtonTitles:nil];
    self.welcomeAlertView.tag = 10;
    [self.welcomeAlertView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
	if ([identifier isEqualToString:@"mainScreenSegueIdentifier"]) {
		return YES;
	}
	return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    SAMainViewController *mainVC = segue.destinationViewController;
    
    NSMutableArray *beacons = [NSMutableArray array];
    
    for (SAEvent *event in self.locationsArray) {
        [beacons addObject:event];
        
        if ([event.type integerValue] == SABeaconStop) {
            break;
        }
    }
    
    mainVC.nextBeaconsArray = beacons;
}

#pragma mark -
#pragma mark Actions

- (void)goToMainScreen
{
    [self performSegueWithIdentifier:@"mainScreenSegueIdentifier" sender:nil];
}

@end


@implementation SASplashViewController (UIAlertViewDelegateImplementation)

#pragma mark -
#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10) {
//        self.tableViewDestination.hidden = NO;
        [self fetchLocationsOrdered];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
}

@end

@implementation SASplashViewController (UITableViewDelegateAndDataSourceImplementation)

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.locationsArray.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SAEventTableViewCell"];
    
    SAEvent *event = self.locationsArray[indexPath.row];
    cell.labelTitle.text = event.name;
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (SAEvent *event in self.locationsArray) {
        if ([event.type integerValue] == 0) {
            event.type = @(SABeaconStart);
        } else {
            event.type = @(SABeaconIntermediate);
        }
    }
    
    SAEvent *event  = self.locationsArray[indexPath.row];
    event.type      = @(SABeaconStop);
    
    [[SACoreDataManager sharedManager] save];
    
    [self goToMainScreen];
}

@end
