//
//  HistoryTableViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 16/10/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "RunCell.h"
#import "RunData.h"
#import "RunOverviewViewController.h"

@interface HistoryTableViewController ()

@end

@implementation HistoryTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    runs = [CoreDataHelper getObjectsFromContextWithEntityName:@"RunData" andSortKey:nil andSortAscending:YES withManagedObjectContext:self.managedObjectContext];
    runs = [[[runs reverseObjectEnumerator] allObjects] mutableCopy];
    
    if (runs.count == 0)
    {
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"No past runs available."
                                                     description:[NSString stringWithFormat:@"Why not go for a run. You will be able to see details of your past runs here."]
                                                            type:MessageBarMessageTypeInfo];
    }
    
    [self.tableView reloadData];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return runs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RunCell *cell = (RunCell *)[tableView
                                      dequeueReusableCellWithIdentifier:@"RunCell"];
    RunData *runData = (RunData *)[runs objectAtIndex:indexPath.row];
    cell.trackLabel.text = runData.runtrackname;
    if([appDelegate useKMasUnits])
    {
        cell.runDistanceLabel.text = [NSString stringWithFormat:@"%.02f km", [runData.rundistance floatValue] / 1000];
    }
    else
    {
        cell.runDistanceLabel.text = [NSString stringWithFormat:@"Distance %.2f miles",[runData.rundistance floatValue] * 0.000621371192];
    }
    
    cell.runLaps.text = [NSString stringWithFormat:@"Laps :%@", runData.runlaps];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss.SS"];
    NSDate *runTimeDate = [df dateFromString:[NSString stringWithFormat:@"%@",runData.runtime]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:runTimeDate];
    
    //cell.runTimeLabel.text = [df stringFromDate:runTimeDate];
    NSString *dateString = [CommonUtils timeFormattedStringForValue:(int)[components hour] :(int)[components minute] :(int)[components second]];
    cell.runTimeLabel.text = [NSString stringWithFormat:@"Time :%@", dateString];
    cell.runDateLabel.text = runData.rundate;
    
    for (NSDictionary *trackInfo in appDelegate.tracksArray) {
        if([[trackInfo objectForKey:@"Race"] isEqualToString:runData.runtrackname])
        {
            cell.trackImage.image = [UIImage imageNamed:[trackInfo objectForKey:@"mapimage"]];
            break;
        }
    }
    return cell;
}

#pragma mark Segue Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RunDataSegue"]) {
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
        RunData *runData = (RunData *)[runs objectAtIndex:selectedRowIndex.row];
        RunOverviewViewController *rovc = segue.destinationViewController;
        [rovc setRunData:runData];
    }
}

@end
