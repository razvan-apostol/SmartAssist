//
//  SASplashViewController.m
//  SmartAssist
//
//  Created by Iulian Poenaru on 17/05/14.
//  Copyright (c) 2014 COM.SmartAssist. All rights reserved.
//

#import "SASplashViewController.h"
#import "AFNetworking.h"

#import "SACoreDataManager.h"
#import "SAUser.h"

@interface SASplashViewController ()

@property (weak, nonatomic) IBOutlet UIImageView    * imageViewLogo;
@property (weak, nonatomic) IBOutlet UILabel        * labelHello;


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
    
    // TODO: GET USER and Event Request Request
    
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

@end
