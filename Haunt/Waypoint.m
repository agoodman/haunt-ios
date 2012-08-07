//
//  Waypoint.m
//  Haunt
//
//  Created by Aubrey Goodman on 7/14/12.
//  Copyright (c) 2012 Migrant Studios. All rights reserved.
//

#import "Waypoint.h"

@implementation Waypoint

@dynamic waypointId, lat, lng, measuredAt;

- (NSString*)description
{
    return [NSString stringWithFormat:@"lat: %3.6f, lng: %3.6f, measuredAt: %@, waypointId: %d",[self.lat floatValue],[self.lng floatValue],self.measuredAt,[self.waypointId intValue]];
}

@end
