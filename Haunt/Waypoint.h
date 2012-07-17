//
//  Waypoint.h
//  Haunt
//
//  Created by Aubrey Goodman on 7/14/12.
//  Copyright (c) 2012 Migrant Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Waypoint : NSObject {
    
    NSNumber* waypointId;
    NSNumber* lat;
    NSNumber* lng;
    NSDate* measuredAt;
    
}

@property (strong) NSNumber* waypointId;
@property (strong) NSNumber* lat;
@property (strong) NSNumber* lng;
@property (strong) NSDate* measuredAt;


@end
