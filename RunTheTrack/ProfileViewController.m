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

@interface ProfileViewController ()

@end

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
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        ProfileHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        reusableview = headerView;
        
        int laps = 0;
        float totalDistance;
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"HH:mm:ss.SS"];
        NSDate *totalRunTime = [df dateFromString:@"00:00:00.00"];
        NSDate *zeroRunTime = [df dateFromString:@"00:00:00.00"];
        
        for (RunData *rd in runs) {
            laps = laps + [rd.runlaps intValue];
            totalDistance = totalDistance + [rd.rundistance floatValue];
            
            NSDate *runTimeDate = [df dateFromString:[NSString stringWithFormat:@"%@",rd.runtime]];
            NSTimeInterval interval = [runTimeDate timeIntervalSinceDate:zeroRunTime];
            totalRunTime = [totalRunTime dateByAddingTimeInterval:interval];
        }
        headerView.totalLaps.text = [NSString stringWithFormat:@"Laps :%d", laps];
        headerView.totalDistance.text = [NSString stringWithFormat:@"%.02f miles", totalDistance];
        
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
        headerView.totalTime.text = [df stringFromDate:totalRunTime];

        headerView.totalTracks.text = [NSString stringWithFormat:@"Tracks %d", (int)trackRunsArray.count];
    }
    
//    if (kind == UICollectionElementKindSectionFooter) {
//        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
//        
//        reusableview = footerview;
//    }
    
    return reusableview;
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view
     numberOfItemsInSection:(NSInteger)section {
    return [trackRunsArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *TrackInfo = (NSMutableDictionary *)[trackRunsArray objectAtIndex:indexPath.row];
    
    ProfileCollectionCell *cell = [cv
                       dequeueReusableCellWithReuseIdentifier:@"ProfileCollectionCell"
                       forIndexPath:indexPath];
    cell.trackName.text = [TrackInfo objectForKey:@"Race"];
    cell.imageView.image = [UIImage imageNamed:[TrackInfo objectForKey:@"trackimage"]];
    
    int laps = 0;
    float totalDistance;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss.SS"];
    NSDate *totalRunTime = [df dateFromString:@"00:00:00.00"];
    NSDate *zeroRunTime = [df dateFromString:@"00:00:00.00"];
    
    for (RunData *rd in runs) {
        if([rd.runtrackname isEqualToString:cell.trackName.text])
        {
            laps = laps + [rd.runlaps intValue];
            totalDistance = totalDistance + [rd.rundistance floatValue];
            NSDate *runTimeDate = [df dateFromString:[NSString stringWithFormat:@"%@",rd.runtime]];
            NSTimeInterval interval = [runTimeDate timeIntervalSinceDate:zeroRunTime];
            totalRunTime = [totalRunTime dateByAddingTimeInterval:interval];
        }
    }
    
    cell.totalLaps.text = [NSString stringWithFormat:@"Laps :%d", laps];
    cell.totalDistance.text = [NSString stringWithFormat:@"%.02f miles", totalDistance];
    
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    cell.totalTime.text = [df stringFromDate:totalRunTime];
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
