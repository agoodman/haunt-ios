//
//  AppDelegate.h
//  Haunt
//
//  Created by Aubrey Goodman on 7/14/12.
//  Copyright (c) 2012 Migrant Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, CLLocationManagerDelegate,RKObjectLoaderDelegate>

@property (strong, nonatomic) IBOutlet UIWindow *window;

@property (strong, nonatomic) IBOutlet UIViewController *settingsViewController;

@property (strong, nonatomic) CLLocationManager* locationManager;

@property (strong, nonatomic) NSString* token;

@end
