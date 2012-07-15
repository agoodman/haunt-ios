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
@synthesize tabBarController = _tabBarController;
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
    [[RKObjectManager sharedManager] postObject:tWaypoint delegate:self];
}

- (void)alertLocationRequired
{
    async_main(^{
        Alert(@"Location Services Required", @"Please enable location services");
    });
}

- (void)initObjectManager
{
//	RKObjectManager* tMgr = [RKObjectManager objectManagerWithBaseURL:@"https://haunt.heroku.com"];
    RKObjectManager* tMgr = [RKObjectManager objectManagerWithBaseURLString:@"http://local:3000"];
    tMgr.serializationMIMEType = RKMIMETypeJSON;
}

- (void)initObjectMappings
{
    RKObjectManager* tMgr = [RKObjectManager sharedManager];
    
    RKObjectMapping* tMapping = [RKObjectMapping mappingForClass:[Waypoint class]];
    [tMapping mapKeyPath:@"lat" toAttribute:@"lat"];
    [tMapping mapKeyPath:@"lng" toAttribute:@"lng"];
    [tMgr.mappingProvider setMapping:tMapping forKeyPath:@"waypoint"];
    
    RKObjectMapping* tSerial = [RKObjectMapping mappingForClass:[Waypoint class]];
    [tSerial mapKeyPath:@"lat" toAttribute:@"lat"];
    [tSerial mapKeyPath:@"lng" toAttribute:@"lng"];
    tSerial.rootKeyPath = @"waypoint";
    [tMgr.mappingProvider setSerializationMapping:tSerial forClass:[Waypoint class]];
    
    [tMgr.router routeClass:[Waypoint class] toResourcePath:[NSString stringWithFormat:@"/devices/%@/waypoints",self.token] forMethod:RKRequestMethodPOST];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@",newLocation);
    [manager stopUpdatingLocation];
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
#warning TODO retrieve token from push notif system
    self.token = @"abc123";
    [self initObjectManager];
    [self initObjectMappings];
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    
    [self configureLocationManager];
    
    [self.window addSubview:self.tabBarController.view];
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

#pragma mark - RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    NSLog(@"failed to post waypoint: %@",[error localizedDescription]);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object
{
    NSLog(@"waypoint posted: %@",object);
}

@end
