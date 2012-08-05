//
//  WaypointListViewController.m
//  Haunt
//
//  Created by Aubrey Goodman on 7/14/12.
//  Copyright (c) 2012 Migrant Studios. All rights reserved.
//

#import "WaypointListViewController.h"
#import "Waypoint.h"


@interface WaypointListViewController ()

@end

@implementation WaypointListViewController

@synthesize waypoints;

- (void)refreshWaypoints
{
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/waypoints" delegate:self];
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self refreshWaypoints];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshWaypoints)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWaypoints) name:@"WaypointCreated" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if( waypoints==nil ) {
        [self refreshWaypoints];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return waypoints.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if( cell==nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    Waypoint* tWaypoint = [self.waypoints objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%2.6f, %2.6f",[tWaypoint.lat floatValue],[tWaypoint.lng floatValue]];
    NSDateFormatter* tFormat = [NSDateFormatter new];
    tFormat.dateStyle = NSDateFormatterShortStyle;
    cell.detailTextLabel.text = [tFormat stringFromDate:tWaypoint.measuredAt];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    async_main(^{
        Alert(@"Unable to load", [error localizedDescription]);
    });
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    self.waypoints = objects;
    async_main(^{
        [self.tableView reloadData];
    });
}

@end
