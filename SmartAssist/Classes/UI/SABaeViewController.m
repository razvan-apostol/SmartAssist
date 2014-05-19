//
//  SABaeViewController.m
//  SmartAssist
//
//  Created by Iulian Poenaru on 18/05/14.
//  Copyright (c) 2014 COM.SmartAssist. All rights reserved.
//

#import "SABaeViewController.h"

@interface SABaeViewController ()

@property (nonatomic, strong) IBOutlet UIView                   * overlayView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView  * activityView;

@end

@implementation SABaeViewController

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
	
	// Setup Overlay View
	self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.overlayView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
	[self.overlayView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight)];
	[self.overlayView setHidden:YES];
	
	// Setup Activity View
	self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[self.activityView setCenter:CGPointMake(CGRectGetMidX(self.overlayView.bounds), CGRectGetMidY(self.overlayView.bounds))];
	[self.activityView startAnimating];
	
	[self.overlayView addSubview:self.activityView];
	[self.view addSubview:self.overlayView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Overlay view

- (void)displaySpinner
{
	[self.view endEditing:YES];
	[self.view bringSubviewToFront:self.overlayView];
	[self.overlayView setHidden:NO];
}

- (void)removeSpinner
{
	[self.view sendSubviewToBack:self.overlayView];
	[self.overlayView setHidden:YES];
}

@end
