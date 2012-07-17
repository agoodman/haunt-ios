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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Haunt" object:nil];
        });
    }else{
        async_main(^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Exorcise" object:nil];
        });
    }
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];

    [hauntEnabled addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
