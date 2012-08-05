//
//  SettingsViewController.m
//  Haunt
//
//  Created by Aubrey Goodman on 7/16/12.
//  Copyright (c) 2012 Migrant Studios. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)switchChanged:(id)sender
{
    if( hauntEnabled.on ) {
        async_main(^{
            progressView.hidden = NO;
            captionView.hidden = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Haunt" object:nil];
        });
    }else{
        async_main(^{
            progressView.hidden = YES;
            captionView.hidden = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Exorcise" object:nil];
        });
    }
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    hauntEnabled.on = ![[NSUserDefaults standardUserDefaults] boolForKey:@"Exorcised"];

    [hauntEnabled addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults* tDef = [NSUserDefaults standardUserDefaults];
    float tTotal = [tDef floatForKey:@"TotalTime"];
    if( isnan(tTotal) ) tTotal = 0.03333;
    NSDate* tStart = [tDef objectForKey:@"StartDate"];
    if( tStart ) {
        float tDiff = [[NSDate date] timeIntervalSinceDate:tStart];
        tTotal += tDiff;
    }
    
    float tMax = 30*86500;
    float tProgress = tTotal / tMax;
    if( tProgress<0 ) tProgress = 0;
    if( tProgress>1 ) tProgress = 1;
    
    progressView.progress = tProgress;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSRange tRange = [[UIDevice currentDevice].model rangeOfString:@"iPad"];
    return UIInterfaceOrientationIsPortrait(interfaceOrientation) || tRange.location!=NSNotFound;
}

@end
