//
//  WaypointListViewController.h
//  Haunt
//
//  Created by Aubrey Goodman on 7/14/12.
//  Copyright (c) 2012 Migrant Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaypointListViewController : UITableViewController <RKObjectLoaderDelegate> {
    
    NSArray* waypoints;
    
}

@property (strong) NSArray* waypoints;

@end
