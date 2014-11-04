//
//  StatusViewController.m
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "StatusViewController.h"
#import "OpenSense.h"
#import "OAuthTwoViewController.h"


@interface StatusViewController (){
    NSUserDefaults *defaults;
}

@end

@implementation StatusViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        entriesCount = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    // Subscribe to batch saved notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batchesUpdated:) name:kOpenSenseBatchSavedNotification object:nil];
    
    
    // register with the openPDS oAuth2 server
    if (![defaults stringForKey:@"bearer_token"]) {
        OAuthTwoViewController *oAuthViewController = [[OAuthTwoViewController alloc]  init];
//        OAuthTwoViewController *oAuthViewController = [[OAuthTwoViewController alloc] initWithNibName:@"AuthVC" bundle:nil];

        // initwithnibname makes the whole thing go straight to hell. Don't do that. I have no idea why. 2014-09-05
        [self presentViewController:oAuthViewController animated:YES completion:nil];
    }

    
    
    // Start collecting
//    if (![OpenSense sharedInstance].isRunning) {
//        [self toggleCollecting:nil];
//    }
}

- (void)batchesUpdated:(NSNotification*)notification
{
    entriesCount++;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelStorage.text = [NSString stringWithFormat:@"%ld %@", entriesCount, (entriesCount == 1) ? @"entry" : @"entries"];
    });
}

- (void)updateTime:(id)sender
{
    // Calculate interval
    NSDate *start = [[OpenSense sharedInstance] startTime];
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:start];
    
    // Format to hours/minutes/seconds
    long seconds = (long)interval % 60;
    interval /= 60;
    long minutes = (long)interval % 60;
    long hours = interval / 60;
    
    self.labelTime.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hours, minutes, seconds];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleCollecting:(id)sender
{
    if ([defaults boolForKey:@"OSCollecting"]) // turn off
    {
        [defaults setBool:NO forKey:@"OSCollecting"];
        [[OpenSense sharedInstance] stopCollector];

        [self.runningView setHidden:YES];
        [self.pausedView setHidden:NO];
        
        // Stop timer
        [elapsedTimer invalidate];
        elapsedTimer = nil;
        
        // Reset entries count
        entriesCount = 0;
    }
    else // turn on
    {
        [defaults setBool:YES forKey:@"OSCollecting"];
        [[OpenSense sharedInstance] startCollector];
        [self.runningView setHidden:NO];
        [self.pausedView setHidden:YES];
        
        // Start timer to update label
        elapsedTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    }
}

- (IBAction)toggleUpload:(id)sender {
    // should only be called when OpenSense is stopped
    [[OpenSense sharedInstance] stopCollectorAndUploadData];
}

- (IBAction)registerDevice:(id)sender {
    [[OpenSense sharedInstance] registerDevice];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
