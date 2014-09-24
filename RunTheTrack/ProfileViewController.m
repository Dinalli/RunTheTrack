//
//  ProfileViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 26/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "ProfileViewController.h"
#import "CoreDataHelper.h"
#import "RunData.h"
#import "XYPieChart.h"
#import "StartFinishAnnotation.h"

@interface ProfileViewController ()
{
    NSMutableArray *slices;
    NSArray        *sliceColors;
    IBOutlet UILabel       *totalTimeLabel;
    IBOutlet UILabel       *totalDistanceLabel;
    IBOutlet UILabel       *totalLapsLabel;
    NSMutableDictionary *tracksRanData;
    IBOutlet UILabel    *selectedSliceLabel;
    int totalRuns;
}

@property (strong, nonatomic) IBOutlet XYPieChart *pieChartLeft;
@property (strong, nonatomic) IBOutlet XYPieChart *pieChartRight;

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
    
    [self.pieChartLeft setDelegate:self];
    [self.pieChartLeft setDataSource:self];
    [self.pieChartLeft setStartPieAngle:M_PI_2];
    [self.pieChartLeft setAnimationSpeed:1.0];
    [self.pieChartLeft setLabelFont:[UIFont fontWithName:@"DBLCDTempBlack" size:8]];
    [self.pieChartLeft setLabelRadius:30];
    [self.pieChartLeft setShowPercentage:YES];
    [self.pieChartLeft setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
    [self.pieChartLeft setPieCenter:CGPointMake(75, 75)];
    [self.pieChartLeft setUserInteractionEnabled:YES];
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
    
    tracksRanData = [NSMutableDictionary new];
    totalRuns = 0;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* plistPath = [bundle pathForResource:@"Tracks" ofType:@"plist"];
    tracksArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
    trackRunsArray = [[NSMutableArray alloc] initWithCapacity:tracksArray.count];
    
    self.managedObjectContext = self.appDelegate.managedObjectContext;
    
    runs = [CoreDataHelper getObjectsFromContextWithEntityName:@"RunData" andSortKey:nil andSortAscending:YES withManagedObjectContext:self.managedObjectContext];
    
    for (NSDictionary *track in tracksArray)
    {
        for(RunData *rd in runs)
        {
            if([[track objectForKey:@"Race"] isEqualToString:rd.runtrackname])
            {
                if(![trackRunsArray containsObject:track])
                {
                    NSMutableDictionary *currentRunData = [NSMutableDictionary new];
                    [trackRunsArray addObject:track];
                    NSString *trackName = [track objectForKey:@"Race"];
                    
                    // add to map
                    StartFinishAnnotation *startAnno = [[StartFinishAnnotation alloc] init];
                    startAnno.coordinate = CLLocationCoordinate2DMake([[track objectForKey:@"Lat"] doubleValue], [[track objectForKey:@"Long"] doubleValue]);
                    startAnno.title = [track objectForKey:@"Race"];
                    [mv addAnnotation:startAnno];
                    
                    float laps = 0;
                    float totalDistance;
                    int trackRuns = 0;
                    
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    [df setDateFormat:@"HH:mm:ss.SS"];
                    NSDate *totalRunTime = [df dateFromString:@"00:00:00.00"];
                    NSDate *zeroRunTime = [df dateFromString:@"00:00:00.00"];
                    
                    for (RunData *rd in runs) {
                        if([rd.runtrackname isEqualToString:trackName])
                        {
                            totalRuns += 1;
                            trackRuns += 1;
                            laps = laps + [rd.runlaps floatValue];
                            totalDistance = totalDistance + [rd.rundistance floatValue];
                            NSDate *runTimeDate = [df dateFromString:[NSString stringWithFormat:@"%@",rd.runtime]];
                            NSTimeInterval interval = [runTimeDate timeIntervalSinceDate:zeroRunTime];
                            totalRunTime = [totalRunTime dateByAddingTimeInterval:interval];
                        }
                    }
                    
                    [currentRunData setObject:[NSString stringWithFormat:@"%d", trackRuns] forKey:@"Runs"];
                    [currentRunData setObject:[NSString stringWithFormat:@"%.2f", laps] forKey:@"Laps"];
                    
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    if([appDelegate useKMasUnits])
                    {
                        [currentRunData setObject:[NSString stringWithFormat:@"%.02f km", totalDistance / 1000] forKey:@"Distance"];
                    }
                    else
                    {
                        [currentRunData setObject:[NSString stringWithFormat:@"%.02f miles", totalDistance * 0.000621371192]  forKey:@"Distance"];
                    }
                    
                    
                    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
                    
                    NSCalendar *calendar = [NSCalendar currentCalendar];
                    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:totalRunTime];
                    NSString *dateString = [CommonUtils timeFormattedStringForValue:(int)[components hour] :(int)[components minute] :(int)[components second]];
                    [currentRunData setObject:[NSString stringWithFormat:@"%@", dateString] forKey:@"Time"];

                    [tracksRanData setObject:currentRunData forKey:trackName];
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

    [self getDataTotals];
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
    return trackRunsArray.count;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    NSDictionary *track = [trackRunsArray objectAtIndex:index];
    NSDictionary *runData = [tracksRanData objectForKey:[track objectForKey:@"Race"]];
    NSString *runsForTrack = [runData objectForKey:@"Runs"];
    return [runsForTrack intValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    if(pieChart == self.pieChartRight) return nil;
    return [sliceColors objectAtIndex:(index % sliceColors.count)];
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{

}

- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    NSDictionary *track = [trackRunsArray objectAtIndex:index];
    selectedSliceLabel.text = [track objectForKey:@"Race"];
    [selectedSliceLabel setHighlighted:NO];
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.0200;
    span.longitudeDelta = 0.0200;
    region.span = span;
    region.center.latitude = [[track objectForKey:@"Lat"] doubleValue];
    region.center.longitude = [[track objectForKey:@"Long"] doubleValue];
    [mv setRegion:region animated:YES];
    
    NSDictionary *runData = [tracksRanData objectForKey:[track objectForKey:@"Race"]];
    totalDistanceLabel.text = [runData objectForKey:@"Distance"];
    totalLapsLabel.text = [runData objectForKey:@"Laps"];
    totalTimeLabel.text = [runData objectForKey:@"Time"];
}

#pragma mark Map Delegate

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // in case it's the user location, we already have an annotation, so just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }

    static NSString *SFAnnotationIdentifier = @"StartFinishID";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mv dequeueReusableAnnotationViewWithIdentifier:SFAnnotationIdentifier];
    if (!pinView)
    {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                        reuseIdentifier:SFAnnotationIdentifier];
        
        UIImage *flagImage = [UIImage imageNamed:@"cheq.png"];
        // You may need to resize the image here.
        annotationView.image = flagImage;
        annotationView.canShowCallout = YES;
        return annotationView;
    }
    else
    {
        pinView.annotation = annotation;
    }
 
    return pinView;
}


#pragma mark Data

-(void)getDataTotals
{
    float laps = 0;
    float totalDistance = 0;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss.SS"];
    NSDate *totalRunTime = [df dateFromString:@"00:00:00.00"];
    NSDate *zeroRunTime = [df dateFromString:@"00:00:00.00"];
    
    for (RunData *rd in runs) {
        laps = laps + [rd.runlaps floatValue];
        totalDistance = totalDistance + [rd.rundistance floatValue];
        
        NSDate *runTimeDate = [df dateFromString:[NSString stringWithFormat:@"%@",rd.runtime]];
        NSTimeInterval interval = [runTimeDate timeIntervalSinceDate:zeroRunTime];
        totalRunTime = [totalRunTime dateByAddingTimeInterval:interval]; 
    }
    
    totalLapsLabel.text = [NSString stringWithFormat:@"%.2f", laps];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([appDelegate useKMasUnits])
    {
        totalDistanceLabel.text = [NSString stringWithFormat:@"%.02f km", totalDistance / 1000];
    }
    else
    {
        totalDistanceLabel.text = [NSString stringWithFormat:@"%.02f miles", totalDistance * 0.000621371192];
    }
    
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:totalRunTime];
    NSString *dateString = [CommonUtils timeFormattedStringForValue:(int)[components hour] :(int)[components minute] :(int)[components second]];
    totalTimeLabel.text = [NSString stringWithFormat:@"%@", dateString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark social sharing

-(IBAction)showActivityView:(id)sender
{
    UIActionSheet *loginActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share using" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"share on facebook" otherButtonTitles:@"share on twitter", nil];
    
    [loginActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self shareOnFacebook];
    }
    else if (buttonIndex == 1) {
        [self shareOnTwitter];
    }
}

-(void)shareOnFacebook
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"Share on facebook"
                                                     description:@"Creating the post now"
                                                            type:MessageBarMessageTypeInfo];
        [self composePost:SLServiceTypeFacebook];
    }
    else
    {
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"Cannot Share on Facebook"
                                                     description:@"Please make sure you are Logged In"
                                                            type:MessageBarMessageTypeInfo];
    }
}

-(void)shareOnTwitter
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"Share on twitter"
                                                     description:@"Creating the post now"
                                                            type:MessageBarMessageTypeInfo];
        [self composePost:SLServiceTypeTwitter];
    }
    else
    {
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"Cannot Share on Twitter"
                                                     description:@"Please make sure you are Logged In"
                                                            type:MessageBarMessageTypeInfo];
    }
}

-(void)composePost:(NSString *)serviceType
{
    SLComposeViewController *composeSheet=[[SLComposeViewController alloc]init];
    composeSheet=[SLComposeViewController composeViewControllerForServiceType:serviceType];
    [composeSheet setInitialText:[NSString stringWithFormat:@"Comepleted %d runs on %ld tracks, using @runthetracks", totalRuns, trackRunsArray.count]];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:currentContext];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [composeSheet addImage:screenshot];
    [self presentViewController:composeSheet animated:YES completion:nil];
}

@end
