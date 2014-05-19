//
//  SAMainViewController.m
//  SmartAssist
//
//  Created by Iulian Poenaru on 17/05/14.
//  Copyright (c) 2014 COM.SmartAssist. All rights reserved.
//

#import "SAMainViewController.h"
#import "SADefines.h"

#import "SAEventTableViewCell.h"

#import "SABeaconManager.h"
#import "ESTBeaconManager.h"
#import "SABaseRequest.h"

#import "SACoreDataManager.h"
#import "SAUser.h"
#import "SAEvent.h"


@interface SAMainViewController ()

// UI
@property (weak, nonatomic) IBOutlet UIView         * viewPlace;
@property (weak, nonatomic) IBOutlet UILabel        * labelPlaceName;

@property (weak, nonatomic) IBOutlet UITableView    * tableView;

@property (strong, nonatomic) UIAlertView           * currentAlertView;

@property (strong, nonatomic) SAEvent               * lastCheckpointBeacon;

@end

@interface SAMainViewController (UITableViewDelegateAndDataSourceImplementation) <UITableViewDataSource, UITableViewDelegate>
@end

@implementation SAMainViewController

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
    
    __weak SAMainViewController *wSelf = self;
    [SABeaconManager sharedManager].beaconNotifyBlock = ^(id object, NSInteger beaconServerID) {
        
        NSInteger nextIndex = [self.nextBeaconsArray indexOfObject:self.lastCheckpointBeacon];
        
        if (nextIndex == NSNotFound) {
            nextIndex = -1;
        }
        
        nextIndex++;
        
		if (wSelf && object && self.lastCheckpointBeacon && nextIndex < self.nextBeaconsArray.count) {
            
            ESTBeacon *realBeacon = (ESTBeacon *)object;
            
            SAEvent *event = [[[SACoreDataManager sharedManager] fetchDataWithParameterBlock:^(NSFetchRequest *requestToBeParametered) {
                [requestToBeParametered setPredicate:[NSPredicate predicateWithFormat:@"beaconID == %@", @(beaconServerID)]];
            } andTableName:@"SAEvent"] firstObject];
            
            if (event && realBeacon && [realBeacon.distance floatValue] < 2.5) {
                
                NSInteger eventIndex = [self.nextBeaconsArray indexOfObject:event];
                NSInteger lastEventIndex = [self.nextBeaconsArray indexOfObject:self.lastCheckpointBeacon];
                
                if (lastEventIndex == NSNotFound && eventIndex > 0) {
                    return;
                }
                
                if (lastEventIndex == NSNotFound || lastEventIndex < eventIndex) {
                    [self showAlertWithArrivedBeacon:event];
                    self.lastCheckpointBeacon =  event;
                }
            }
		}
    };

    
    SAEvent *currentEvent = [[[SACoreDataManager sharedManager] fetchDataWithParameterBlock:^(NSFetchRequest *requestToBeParametered) {
        [requestToBeParametered setPredicate:[NSPredicate predicateWithFormat:@"beaconID == %@", @(1)]];
    } andTableName:@"SAEvent"] firstObject];
    
    self.lastCheckpointBeacon = currentEvent;
    
    if (!self.nextBeaconsArray.count) {
        return;
    }
    
    [self showAlertWithNextBeacon:self.nextBeaconsArray[0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Private Methods

- (void)showAlertWithNextBeacon:(SAEvent *)nextBeacon
{
    if ([self.lastCheckpointBeacon isEqual:nextBeacon]) {
        return;
    }
    
    NSString *nextCheckpoint = [NSString stringWithFormat:@"Please walk carefully against the wall until you reach %@", nextBeacon.name];
    self.currentAlertView = [[UIAlertView alloc] initWithTitle:nextCheckpoint message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [self.currentAlertView show];
    
    [self performSelector:@selector(dismissAlertView) withObject:nil afterDelay:3.0];
    
//    NSInteger currentIndex = [self.nextBeaconsArray indexOfObject:self.lastCheckpointBeacon];
    
//    if (currentIndex == NSNotFound) {
//        currentIndex = -1;
//    }
//    
//    currentIndex++;
    
//    if (currentIndex < self.nextBeaconsArray.count) {
//        
//        SAEvent *nextEvent = self.nextBeaconsArray[currentIndex];
//        [self performSelector:@selector(showAlertWithNextBeacon:) withObject:nextEvent afterDelay:10.0];
//    }
}

- (void)showAlertWithArrivedBeacon:(SAEvent *)beacon
{
    NSString *checkpoint = [NSString stringWithFormat:@"Good job! You've reached the %@", beacon.name];
    self.currentAlertView = [[UIAlertView alloc] initWithTitle:checkpoint message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [self.currentAlertView show];
    
    
    NSInteger lastIndex = [self.nextBeaconsArray indexOfObject:beacon];
    lastIndex++;
    
    if (lastIndex >= self.nextBeaconsArray.count) {
        
        [self dismissAlertView];
        
        if ([beacon.type integerValue] == SABeaconStop) {
            
            [self performSelector:@selector(showCongratsAlert) withObject:nil afterDelay:2.0];
            self.lastCheckpointBeacon = beacon;
        }
        
        return;
    }
    
    [self performSelector:@selector(dismissAlertView) withObject:nil afterDelay:3.0];
    
    [self performSelector:@selector(showAlertWithNextBeacon:) withObject:self.nextBeaconsArray[lastIndex] afterDelay:4.0];
}

- (void)showCongratsAlert
{
    [[SABeaconManager sharedManager] stopManager];
    
    self.currentAlertView = [[UIAlertView alloc] initWithTitle:@"Congratulations John, you have reached your destination! Good job!" message:nil delegate:nil cancelButtonTitle:@"Thank you" otherButtonTitles: nil];
    [self.currentAlertView show];
}

- (void)dismissAlertView
{
    if (self.currentAlertView) {
        [self.currentAlertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}

@end

@implementation SAMainViewController (UITableViewDelegateAndDataSourceImplementation)

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.nextBeaconsArray.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAEventTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SAEventTableViewCell"];

    SAEvent *beacon = self.nextBeaconsArray[indexPath.row];
//
//    NSString *distance = ([beacon.distance floatValue] != -1) ? [NSString stringWithFormat:@"%.2lf", [beacon.distance floatValue]] : @"OUT OF RANGE";
    cell.labelTitle.text = [NSString stringWithFormat:@"%@", beacon.name];
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end

