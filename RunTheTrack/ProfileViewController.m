//
//  ProfileViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 26/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileCollectionCell.h"
#import "ProfileHeaderView.h"
#import "CoreDataHelper.h"
#import "RunData.h"
#import "XYPieChart.h"

@interface ProfileViewController ()
{
    NSMutableArray *slices;
    NSArray        *sliceColors;
}

@property (strong, nonatomic) IBOutlet XYPieChart *pieChartLeft;
@property (strong, nonatomic) IBOutlet XYPieChart *pieChartRight;

@end

/* 
 - Locations user has run with number of times
 - Locations user has run with total distance
 - Loctions user has run with total time
 - total time
 - total distance
 
 */

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    slices = [NSMutableArray arrayWithCapacity:10];
    
    for(int i = 0; i < 5; i ++)
    {
        NSNumber *one = [NSNumber numberWithInt:rand()%60+20];
        [slices addObject:one];
    }
    
    [self.pieChartLeft setDataSource:self];
    [self.pieChartLeft setStartPieAngle:M_PI_2];
    [self.pieChartLeft setAnimationSpeed:1.0];
    [self.pieChartLeft setLabelFont:[UIFont fontWithName:@"DBLCDTempBlack" size:24]];
    [self.pieChartLeft setLabelRadius:0];
    [self.pieChartLeft setShowPercentage:YES];
    [self.pieChartLeft setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
    [self.pieChartLeft setPieCenter:CGPointMake(75, 75)];
    [self.pieChartLeft setUserInteractionEnabled:NO];
    [self.pieChartLeft setLabelShadowColor:[UIColor blackColor]];
    
    [self.pieChartRight setDelegate:self];
    [self.pieChartRight setDataSource:self];
    [self.pieChartRight setPieCenter:CGPointMake(75, 75)];
    [self.pieChartRight setShowPercentage:NO];
    [self.pieChartRight setLabelColor:[UIColor blackColor]];
    
    sliceColors =[NSArray arrayWithObjects:
                       [UIColor colorWithRed:246/255.0 green:155/255.0 blue:0/255.0 alpha:1],
                       [UIColor colorWithRed:129/255.0 green:195/255.0 blue:29/255.0 alpha:1],
                       [UIColor colorWithRed:62/255.0 green:173/255.0 blue:219/255.0 alpha:1],
                       [UIColor colorWithRed:229/255.0 green:66/255.0 blue:115/255.0 alpha:1],
                       [UIColor colorWithRed:148/255.0 green:141/255.0 blue:139/255.0 alpha:1],nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* plistPath = [bundle pathForResource:@"Tracks" ofType:@"plist"];
    tracksArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
    trackRunsArray = [[NSMutableArray alloc] initWithCapacity:tracksArray.count];
    
    self.managedObjectContext = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
    
    runs = [CoreDataHelper getObjectsFromContextWithEntityName:@"RunData" andSortKey:nil andSortAscending:YES withManagedObjectContext:self.managedObjectContext];
    
    for (NSDictionary *track in tracksArray)
    {
        for(RunData *rd in runs)
        {
            if([[track objectForKey:@"Race"] isEqualToString:rd.runtrackname])
            {
                if(![trackRunsArray containsObject:track])
                {
                    [trackRunsArray addObject:track];
                }
            }
        }
    }
    
    if (runs.count == 0)
    {
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"No past runs available."
                                                     description:[NSString stringWithFormat:@"Why not go for a run. You will see your progress on each track here."]
                                                            type:MessageBarMessageTypeInfo];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.pieChartLeft reloadData];
    [self.pieChartRight reloadData];
}


#pragma mark XYChart Delegate

#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return slices.count;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [[slices objectAtIndex:index] intValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    if(pieChart == self.pieChartRight) return nil;
    return [sliceColors objectAtIndex:(index % sliceColors.count)];
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will select slice at index %d",index);
}
- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will deselect slice at index %d",index);
}
- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did deselect slice at index %d",index);
}
- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did select slice at index %d",index);
    //self.selectedSliceLabel.text = [NSString stringWithFormat:@"$%@",[self.slices objectAtIndex:index]];
}


//#pragma mark - UICollectionViewDelegate
//- (void)collectionView:(UICollectionView *)collectionView
//didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//}
//
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionReusableView *reusableview = nil;
//    
//    if (kind == UICollectionElementKindSectionHeader) {
//         headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
//        reusableview = headerView;
//        
//        float laps = 0;
//        float totalDistance = 0;
//        
//        NSDateFormatter *df = [[NSDateFormatter alloc] init];
//        [df setDateFormat:@"HH:mm:ss.SS"];
//        NSDate *totalRunTime = [df dateFromString:@"00:00:00.00"];
//        NSDate *zeroRunTime = [df dateFromString:@"00:00:00.00"];
//        
//        for (RunData *rd in runs) {
//            laps = laps + [rd.runlaps floatValue];
//            totalDistance = totalDistance + [rd.rundistance floatValue];
//            
//            NSDate *runTimeDate = [df dateFromString:[NSString stringWithFormat:@"%@",rd.runtime]];
//            NSTimeInterval interval = [runTimeDate timeIntervalSinceDate:zeroRunTime];
//            totalRunTime = [totalRunTime dateByAddingTimeInterval:interval];
//        }
//        headerView.totalLaps.text = [NSString stringWithFormat:@"Laps :%.2f", laps];
//        
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        if([appDelegate useKMasUnits])
//        {
//            headerView.totalDistance.text = [NSString stringWithFormat:@"%.02f km", totalDistance / 1000];
//        }
//        else
//        {
//            headerView.totalDistance.text = [NSString stringWithFormat:@"%.02f miles", totalDistance * 0.000621371192];
//        }
//
//        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
//        
//        NSCalendar *calendar = [NSCalendar currentCalendar];
//        NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:totalRunTime];
//        NSString *dateString = [CommonUtils timeFormattedStringForValue:(int)[components hour] :(int)[components minute] :(int)[components second]];
//        headerView.totalTime.text = [NSString stringWithFormat:@"Time :%@", dateString];
//        headerView.totalTracks.text = [NSString stringWithFormat:@"Tracks %d", (int)trackRunsArray.count];
//    }
//    
////    if (kind == UICollectionElementKindSectionFooter) {
////        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
////        
////        reusableview = footerview;
////    }
//    
//    return reusableview;
//}
//
//#pragma mark - UICollectionView Datasource
//
//- (NSInteger)collectionView:(UICollectionView *)view
//     numberOfItemsInSection:(NSInteger)section {
//    return [trackRunsArray count];
//}
//
//- (NSInteger)numberOfSectionsInCollectionView:
//(UICollectionView *)collectionView {
//    return 1;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)cv
//                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    NSMutableDictionary *TrackInfo = (NSMutableDictionary *)[trackRunsArray objectAtIndex:indexPath.row];
//    
//    ProfileCollectionCell *cell = [cv
//                       dequeueReusableCellWithReuseIdentifier:@"ProfileCollectionCell"
//                       forIndexPath:indexPath];
//    cell.trackName.text = [TrackInfo objectForKey:@"Race"];
//    cell.imageView.image = [UIImage imageNamed:[TrackInfo objectForKey:@"trackimage"]];
//    
//    [cell initFlatWithIndicatorProgressBar];
//
//    int trackLaps = [[NSString stringWithFormat:@"%@",[TrackInfo objectForKey:@"Laps"]] intValue];
//    float laps = 0;
//    float totalDistance;
//    
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    [df setDateFormat:@"HH:mm:ss.SS"];
//    NSDate *totalRunTime = [df dateFromString:@"00:00:00.00"];
//    NSDate *zeroRunTime = [df dateFromString:@"00:00:00.00"];
//    
//    for (RunData *rd in runs) {
//        if([rd.runtrackname isEqualToString:cell.trackName.text])
//        {
//            laps = laps + [rd.runlaps floatValue];
//            totalDistance = totalDistance + [rd.rundistance floatValue];
//            NSDate *runTimeDate = [df dateFromString:[NSString stringWithFormat:@"%@",rd.runtime]];
//            NSTimeInterval interval = [runTimeDate timeIntervalSinceDate:zeroRunTime];
//            totalRunTime = [totalRunTime dateByAddingTimeInterval:interval];
//        }
//    }
//    
//    cell.totalLaps.text = [NSString stringWithFormat:@"Laps :%f", laps];
//    
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    if([appDelegate useKMasUnits])
//    {
//        cell.totalDistance.text = [NSString stringWithFormat:@"%.02f km", totalDistance / 1000];
//    }
//    else
//    {
//        cell.totalDistance.text = [NSString stringWithFormat:@"%.02f miles", totalDistance * 0.000621371192];
//    }
//    
//    
//    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
//    
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:totalRunTime];
//    NSString *dateString = [CommonUtils timeFormattedStringForValue:(int)[components hour] :(int)[components minute] :(int)[components second]];
//    cell.totalTime.text = [NSString stringWithFormat:@"Time :%@", dateString];
//    
//    if(laps > 0)
//    {
//        CGFloat progress = (laps / trackLaps);
//        [cell setProgress:progress animated:YES];
//    }
//    else{
//        [cell setProgress:0.01 animated:YES];
//    }
//    
//    return cell;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
