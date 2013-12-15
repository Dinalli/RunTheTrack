//
//  RunDetailViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 10/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "RunDetailViewController.h"
#import "CoreDataHelper.h"
#import "RunSectorsViewController.h"
#import <Social/Social.h>

@interface RunDetailViewController ()

@end

@implementation RunDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)addRouteToMap
{
    NSMutableArray *points = [[self.runData.runDataLocations allObjects] mutableCopy];

    [points sortUsingComparator:^NSComparisonResult(id a, id b) {
        RunLocations *aRunLocation = (RunLocations *)a;
        RunLocations *bRunLocation = (RunLocations *)b;
        NSInteger firstInteger = [aRunLocation.locationIndex integerValue];
        NSInteger secondInteger = [bRunLocation.locationIndex integerValue];
        
        if (firstInteger > secondInteger)
            return NSOrderedAscending;
        if (firstInteger < secondInteger)
            return NSOrderedDescending;
        return [aRunLocation.locationIndex localizedCompare: bRunLocation.locationIndex];
    }];
    
    NSInteger numberOfSteps = points.count;
    CLLocationCoordinate2D coordinates[numberOfSteps];
    for (NSInteger index = 0; index < numberOfSteps; index++) {
        RunLocations *runlocation = (RunLocations *)[points objectAtIndex:index];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([runlocation.lattitude doubleValue], [runlocation.longitude doubleValue]);
        coordinates[index] = coordinate;
    }
    
    self.trackLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
    [mv addOverlay:self.trackLine level:MKOverlayLevelAboveLabels];
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.0200;
    span.longitudeDelta = 0.0200;
    region.span = span;
    region.center.latitude = coordinates[numberOfSteps-1].latitude;
    region.center.longitude = coordinates[numberOfSteps-1].longitude;
    [mv setRegion:region animated:YES];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer* lineView = [[MKPolylineRenderer alloc] initWithPolyline:self.trackLine];
    lineView.strokeColor = [UIColor blueColor];
    lineView.lineWidth = 7;
    return lineView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    runTime.text = [NSString stringWithFormat:@"Time : %@", self.runData.runtime];
    runLaps.text = [NSString stringWithFormat:@"Laps : %@",self.runData.runlaps];
    runDistance.text = [NSString stringWithFormat:@"Distance : %@ miles",self.runData.rundistance];
    runDate.text = [NSString stringWithFormat:@"Date : %@",self.runData.rundate];
    trackNameLabel.text = self.runData.runtrackname;
    
    
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* plistPath = [bundle pathForResource:@"Tracks" ofType:@"plist"];
    NSArray *tracksArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    for (NSDictionary *trackInfo in tracksArray) {
        if([[trackInfo objectForKey:@"Race"] isEqualToString:self.runData.runtrackname])
        {
            trackMapImage.image = [UIImage imageNamed:[trackInfo objectForKey:@"mapimage"]];
        }
    }
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
    [self addRouteToMap];
}

#pragma mark Segue Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RunSectorsSegue"]) {
        RunSectorsViewController *rsvc = segue.destinationViewController;
        [rsvc setRunData:self.runData];
    }
}
    
#pragma social sharing
    
-(IBAction)shareOnFacebook:(id)sender
    {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        {
            [self composePost:SLServiceTypeFacebook];
        }
    }
    
-(IBAction)shareOnTwitter:(id)sender
    {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            [self composePost:SLServiceTypeTwitter];
        }
    }
    
-(void)composePost:(NSString *)serviceType
    {
        SLComposeViewController *composeSheet=[[SLComposeViewController alloc]init];
        composeSheet=[SLComposeViewController composeViewControllerForServiceType:serviceType];
        [composeSheet setInitialText:[NSString stringWithFormat:@"Just comepleted a run round the %@ GP track. Time %@ Distance %@", trackNameLabel.text, runTime.text, runDistance.text]];
        
        MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
        options.region = mv.region;
        options.scale = [UIScreen mainScreen].scale;
        options.size = mv.frame.size;
        
        MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
        [snapshotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
            
            // get the image associated with the snapshot
            
            UIImage *image = snapshot.image;
            
            // Get the size of the final image
            
            CGRect finalImageRect = CGRectMake(0, 0, image.size.width, image.size.height);
            
            // Get a standard annotation view pin. Clearly, Apple assumes that we'll only want to draw standard annotation pins!
            
            MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:@""];
            UIImage *pinImage = pin.image;
            
            // ok, let's start to create our final image
            
            UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
            
            // first, draw the image from the snapshotter
            
            [image drawAtPoint:CGPointMake(0, 0)];
            
            // now, let's iterate through the annotations and draw them, too
            
            for (id<MKAnnotation>annotation in mv.annotations)
            {
                CGPoint point = [snapshot pointForCoordinate:annotation.coordinate];
                if (CGRectContainsPoint(finalImageRect, point)) // this is too conservative, but you get the idea
                {
                    CGPoint pinCenterOffset = pin.centerOffset;
                    point.x -= pin.bounds.size.width / 2.0;
                    point.y -= pin.bounds.size.height / 2.0;
                    point.x += pinCenterOffset.x;
                    point.y += pinCenterOffset.y;
                    
                    [pinImage drawAtPoint:point];
                }
            }
            
            // grab the final image
            mapImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            [composeSheet addImage:mapImage];
            [self presentViewController:composeSheet animated:YES completion:nil];
            
        }];
    }


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
