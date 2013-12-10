//
//  RunSectorsViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 05/12/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "RunSectorsViewController.h"
#import "RunSectorCell.h"
#import "RunSectors.h"

@interface RunSectorsViewController ()

@end

@implementation RunSectorsViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    runLapsArray = [[self.runData.runSectors allObjects] mutableCopy];
    [runLapsArray sortUsingComparator:^NSComparisonResult(id a, id b) {
        RunSectors *aRunSector = (RunSectors *)a;
        RunSectors *bRunSector = (RunSectors *)b;
        NSInteger firstInteger = [aRunSector.lapNumber integerValue];
        NSInteger secondInteger = [bRunSector.lapNumber integerValue];
        
        if (firstInteger > secondInteger)
            return NSOrderedAscending;
        if (firstInteger < secondInteger)
            return NSOrderedDescending;
        return [aRunSector.lapNumber localizedCompare: bRunSector.lapNumber];
    }];
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
    return runLapsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RunSectorCell *cell = (RunSectorCell *)[tableView
                                dequeueReusableCellWithIdentifier:@"RunSectorCell"];
    RunSectors *runSector = (RunSectors *)[runLapsArray objectAtIndex:indexPath.row];
    
    cell.trackLabel.text = self.runData.runtrackname;
    cell.lapNumber.text = [NSString stringWithFormat:@"Lap : %@", runSector.lapNumber];
    cell.lapTime.text = [NSString stringWithFormat:@"Lap Time : %@", runSector.lapTime];
    cell.sector1Time.text = [NSString stringWithFormat:@"Sector1 : %@", runSector.sector1Time];
    cell.sector2Time.text = [NSString stringWithFormat:@"Sector2 : %@", runSector.sector2Time];
    cell.sector3Time.text = [NSString stringWithFormat:@"Sector3 : %@", runSector.sector3Time];
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
