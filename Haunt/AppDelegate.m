//
//  AppDelegate.m
//  Haunt
//
//  Created by Aubrey Goodman on 7/14/12.
//  Copyright (c) 2012 Migrant Studios. All rights reserved.
//

#import "AppDelegate.h"
#import "Waypoint.h"


@implementation AppDelegate

@synthesize window = _window;
@synthesize settingsViewController = _settingsViewController;
@synthesize locationManager = _locationManager;
@synthesize token = _token;

- (void)configureLocationManager
{
    if( [CLLocationManager regionMonitoringAvailable] && 
       [CLLocationManager regionMonitoringEnabled] && 
       [CLLocationManager locationServicesEnabled] ) 
    {
        if( self.locationManager.monitoredRegions.count==0 ) {
            // not currently monitoring; establish region
            [self establishGeoFence];
        }
    }else{
        [self alertLocationRequired];
    }
}

- (void)establishGeoFence
{
    if( self.locationManager.location==nil ) {
        NSLog(@"startMonitoringLocation");
        [self.locationManager startMonitoringSignificantLocationChanges];
    }else{
        CLRegion* tRegion = [[CLRegion alloc] initCircularRegionWithCenter:self.locationManager.location.coordinate     radius:800 identifier:@"Haunt"];
        NSLog(@"establishGeoFence: %@",tRegion);
        [self.locationManager startMonitoringForRegion:tRegion desiredAccuracy:50];
        
        [self postWaypoint:tRegion.center];
    }
}

- (void)postWaypoint:(CLLocationCoordinate2D)aCoordinate
{
    Waypoint* tWaypoint = [Waypoint new];
    tWaypoint.lat = [NSNumber numberWithFloat:aCoordinate.latitude];
    tWaypoint.lng = [NSNumber numberWithFloat:aCoordinate.longitude];
    tWaypoint.measuredAt = [NSDate date];
    [[RKObjectManager sharedManager] postObject:tWaypoint delegate:self];
}

- (void)alertLocationRequired
{
    async_main(^{
        Alert(@"Location Services Required", @"Please enable location services");
    });
}

- (void)tokenAssigned
{
    [self initObjectManagerWithToken:self.token];
    [self initObjectMappings];
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    
    [self configureLocationManager];
}

- (void)initObjectManagerWithToken:(NSString*)aToken
{
    NSString* tHost = @"https://haunt.herokuapp.com";
//    NSString* tHost = @"http://local:3000";
    NSString* tPath = [NSString stringWithFormat:@"%@/devices/%@",tHost,aToken];
	RKObjectManager* tMgr = [RKObjectManager objectManagerWithBaseURLString:tPath];
    tMgr.serializationMIMEType = RKMIMETypeJSON;
}

- (void)initObjectMappings
{
    RKObjectManager* tMgr = [RKObjectManager sharedManager];
    
    RKObjectMapping* tMapping = [RKObjectMapping mappingForClass:[Waypoint class]];
    [tMapping mapKeyPath:@"lat" toAttribute:@"lat"];
    [tMapping mapKeyPath:@"lng" toAttribute:@"lng"];
    [tMapping mapKeyPath:@"measured_at" toAttribute:@"measuredAt"];
    [tMgr.mappingProvider setMapping:tMapping forKeyPath:@"waypoint"];
    
    RKObjectMapping* tSerial = [RKObjectMapping mappingForClass:[Waypoint class]];
    [tSerial mapKeyPath:@"lat" toAttribute:@"lat"];
    [tSerial mapKeyPath:@"lng" toAttribute:@"lng"];
    [tSerial mapKeyPath:@"measuredAt" toAttribute:@"measured_at"];
    tSerial.rootKeyPath = @"waypoint";
    [tMgr.mappingProvider setSerializationMapping:tSerial forClass:[Waypoint class]];
    
    [tMgr.router routeClass:[Waypoint class] toResourcePath:@"/waypoints" forMethod:RKRequestMethodPOST];
}

- (void)haunt
{
    [self establishGeoFence];
}

- (void)exorcise
{
    for (CLRegion* region in self.locationManager.monitoredRegions) {
        [self.locationManager stopMonitoringForRegion:region];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@",newLocation);
    [manager stopMonitoringSignificantLocationChanges];
    [self establishGeoFence];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@",error);
    [manager stopUpdatingLocation];
    if( [error code]==kCLErrorDenied ) {
        [self alertLocationRequired];
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"didStartMonitoringRegion: %@",region);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    [manager stopMonitoringForRegion:region];
    async_main(^{
        Alert(@"Configuration Failed", @"Unable to configure location services");
    });
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"didExitRegion: %@",region);
    [manager stopMonitoringForRegion:region];
    [self establishGeoFence];
}

#pragma mark -

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haunt) name:@"Haunt" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exorcise) name:@"Exorcise" object:nil];
    
    [self.window addSubview:self.settingsViewController.view];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString* tRaw = [deviceToken description];
    self.token = [[[tRaw stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    async_main(^{
        [self tokenAssigned];
    });
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if( [error code]==3010 ) {
        self.token = @"abc123";
        async_main(^{
            [self tokenAssigned];
        });
    }else{
        async_main(^{
            Alert(@"Notifications Required", [error localizedDescription]);
        });
    }
}

#pragma mark - RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    NSLog(@"failed to post waypoint: %@",[error localizedDescription]);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object
{
    NSLog(@"waypoint posted: %@",object);
    async_main(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WaypointCreated" object:nil];
    });
}

@end
