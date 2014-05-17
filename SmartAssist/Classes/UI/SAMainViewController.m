//
//  SAMainViewController.m
//  SmartAssist
//
//  Created by Iulian Poenaru on 17/05/14.
//  Copyright (c) 2014 COM.SmartAssist. All rights reserved.
//

#import "SAMainViewController.h"

#import "SAEventTableViewCell.h"

#import "SACoreDataManager.h"
#import "SAUser.h"
#import "SAEvent.h"

@interface SAMainViewController ()

@property (weak, nonatomic) IBOutlet UIView         * viewPlace;
@property (weak, nonatomic) IBOutlet UILabel        * labelPlaceName;

@property (weak, nonatomic) IBOutlet UITableView    * tableView;

// data source
@property (strong, nonatomic) NSArray               * eventsArray;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation SAMainViewController (UITableViewDelegateAndDataSourceImplementation)

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.eventsArray.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAEventTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SAEventTableViewCell"];
//    if (!cell) {
//        cell = [[WKTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WKTableViewCell"];
//    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
