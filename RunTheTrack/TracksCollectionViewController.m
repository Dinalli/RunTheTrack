//
//  TracksCollectionViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/10/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "TracksCollectionViewController.h"
#import "TrackCell.h"
#import "RunViewController.h"
#import "CoreDataHelper.h"
#import "RunData.h"

@interface TracksCollectionViewController ()

@end

@implementation TracksCollectionViewController

    
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
//        // On iOS 6 ADBannerView introduces a new initializer, use it when available.
//        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
//            adView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
//        } else {
//            adView = [[ADBannerView alloc] init];
//        }
//        adView.delegate = self;
    }
    return self;
}
    
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.canDisplayBannerAds = YES;
    
    adView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    adView.delegate = self;
    [self.view addSubview:adView];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TrackSelectedSegue"]) {
        NSArray *indexPaths = [collectionView indexPathsForSelectedItems];
        RunViewController *rvc = segue.destinationViewController;
        
        NSIndexPath *index = [indexPaths objectAtIndex:0];
        NSDictionary *selectedTrackInfo = [appDelegate.tracksArray  objectAtIndex:index.row];
        rvc.TrackInfo = [selectedTrackInfo mutableCopy];
        
        [collectionView
         deselectItemAtIndexPath:index animated:YES];
    }
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view
     numberOfItemsInSection:(NSInteger)section {
    return [appDelegate.tracksArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *TrackInfo = (NSMutableDictionary *)[appDelegate.tracksArray objectAtIndex:indexPath.row];

    TrackCell *cell = [cv
                                  dequeueReusableCellWithReuseIdentifier:@"TrackDetailCell"
                                  forIndexPath:indexPath];
    
    cell.trackName.text = [TrackInfo objectForKey:@"Race"];
    cell.totalLaps.text = [NSString stringWithFormat:@"Laps : %@",[TrackInfo objectForKey:@"Laps"]];
    cell.Distance.text = [NSString stringWithFormat:@"Distance : %@ miles",[TrackInfo objectForKey:@"Distance"]];
    
    cell.trackImage.image = [UIImage imageNamed:[TrackInfo objectForKey:@"mapimage"]];
    
    NSDictionary *totals = [self calculateTotalsWithTrackInfo:TrackInfo andTrackName:cell.trackName.text];
    cell.completeDistance.text = [totals objectForKey:@"distance"];
    cell.completeLaps.text = [totals objectForKey:@"laps"];
    cell.completeTime.text = [totals objectForKey:@"time"];
    return cell;
}


-(NSDictionary *)calculateTotalsWithTrackInfo:(NSMutableDictionary *)TrackInfo andTrackName:(NSString *)trackName
{
    
    self.managedObjectContext = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
    
    runs = [CoreDataHelper getObjectsFromContextWithEntityName:@"RunData" andSortKey:nil andSortAscending:YES withManagedObjectContext:self.managedObjectContext];
    
    float laps = 0;
    float totalDistance;
    NSString *completedLaps, *completedDistance, *completedTime;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss.SS"];
    NSDate *totalRunTime = [df dateFromString:@"00:00:00.00"];
    NSDate *zeroRunTime = [df dateFromString:@"00:00:00.00"];
    
    for (RunData *rd in runs) {
        if([rd.runtrackname isEqualToString:trackName])
        {
            laps = laps + [rd.runlaps floatValue];
            totalDistance = totalDistance + [rd.rundistance floatValue];
            NSDate *runTimeDate = [df dateFromString:[NSString stringWithFormat:@"%@",rd.runtime]];
            NSTimeInterval interval = [runTimeDate timeIntervalSinceDate:zeroRunTime];
            totalRunTime = [totalRunTime dateByAddingTimeInterval:interval];
        }
    }
    
    completedLaps = [NSString stringWithFormat:@"%f",laps];
    
    if([appDelegate useKMasUnits])
    {
        completedDistance = [NSString stringWithFormat:@"%.02f km", totalDistance / 1000];
    }
    else
    {
        completedDistance = [NSString stringWithFormat:@"%.02f miles", totalDistance * 0.000621371192];
    }

    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:totalRunTime];
    NSString *dateString = [CommonUtils timeFormattedStringForValue:(int)[components hour] :(int)[components minute] :(int)[components second]];
    completedTime = [NSString stringWithFormat:@"Time :%@", dateString];
    
//    if(laps > 0)
//    {
//        CGFloat progress = (laps / trackLaps);
//        [cell setProgress:progress animated:YES];
//    }
//    else{
//        [cell setProgress:0.01 animated:YES];
//    }
    return @{@"laps": completedLaps, @"distance": completedDistance, @"time": completedTime};
}

- (IBAction)unwindToTrackSelect:(UIStoryboardSegue *)unwindSegue
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
- (void)viewDidLayoutSubviews {
    CGRect contentFrame = self.view.bounds, bannerFrame = CGRectZero;
    
    // All we need to do is ask the banner for a size that fits into the layout area we are using.
    // At this point in this method contentFrame=self.view.bounds, so we'll use that size for the layout.
    bannerFrame.size = [adView sizeThatFits:contentFrame.size];
    
    if (adView.bannerLoaded) {
        contentFrame.size.height -= bannerFrame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
    } else {
        bannerFrame.origin.y = contentFrame.size.height;
    }
    adView.frame = bannerFrame;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
    {
        NSLog(@"Banner View Did load Ad");
    }
    
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
    {
        NSLog(@"Banner Error %@", error.localizedDescription);
    }

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
    {
        NSLog(@"Banner View Should begin YES");
        return YES;
    }
    
- (void)bannerViewActionDidFinish:(ADBannerView *)banner
    {
        NSLog(@"Banner Action Did Finish");
    }

@end
