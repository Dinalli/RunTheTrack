//
//  RunTrackMapViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import "RunTrackMapViewController.h"
#import "CoreDataHelper.h"
#import "StartFinishAnnotation.h"
#import <Social/Social.h>
#import "AppDelegate.h"
#import "RunSectors.h"
#import "StartFinishAnnotation.h"
#import "Sector1Annotaion.h"
#import "Sector2Annotation.h"
#import "LapAnnotation.h"
#import "SectorTicker.h"

@implementation RunTrackMapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
        
    runTime.text = [NSString stringWithFormat:@"%@", self.runData.runtime];
    runLaps.text = [NSString stringWithFormat:@"%@",self.runData.runlaps];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([appDelegate useKMasUnits])
    {
        runDistance.text = [NSString stringWithFormat:@"%.02f km", [self.runData.rundistance floatValue] / 1000];
    }
    else
    {
        runDistance.text = [NSString stringWithFormat:@"%.2f miles",[self.runData.rundistance floatValue] * 0.000621371192];
    }
    
    runDate.text = [NSString stringWithFormat:@"%@",self.runData.rundate];
    self.navigationItem.title = self.runData.runtrackname;

    for (NSMutableDictionary *trackInfoDict in appDelegate.tracksArray) {
        if([[trackInfoDict objectForKey:@"Race"] isEqualToString:self.runData.runtrackname])
        {
            self.trackInfo = trackInfoDict;
            trackMapImage.image = [UIImage imageNamed:[trackInfoDict objectForKey:@"mapimage"]];
        }
    }
    self.trackPointArray = [[NSMutableArray alloc] init];
    
    // Add Map Cameras
    
    MKMapCamera *camera1 = [MKMapCamera
                            cameraLookingAtCenterCoordinate:startCoordinate
                            fromEyeCoordinate:startCoordinate
                            eyeAltitude:150.0];
    
    [mv setCamera:camera1];
    runCameras = [[NSMutableArray alloc] init];
    [runCameras addObject:camera1];
    cameraIndex = 0;
    
    [self addTrackPoints];
}

-(IBAction)threeDeeSelected:(id)sender
{
    (mv.pitchEnabled) ? [mv setPitchEnabled:NO] : [mv setPitchEnabled:YES];
    MKMapCamera *nextCamera = [runCameras objectAtIndex:cameraIndex];
    [mv setCamera:nextCamera animated:YES];
}

- (IBAction)goToNextCamera:(id)sender {
    if ([runCameras count] == 0) {
        return;
    }
    cameraIndex++;
    if(cameraIndex == runCameras.count)
    {
        cameraIndex = 0;
    }
    MKMapCamera *nextCamera = [runCameras objectAtIndex:cameraIndex];
    
    [UIView animateWithDuration:1.5
                          delay:.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{[mv setCamera:nextCamera];}
                     completion:NULL];
}

#pragma mark choose track
-(void)setTrackInfo:(NSMutableDictionary *)trackInfoDict
{
    _trackInfo = trackInfoDict;
}

-(void)addTrackPoints
{
    [mv removeAnnotations:mv.annotations];
    CLLocationCoordinate2D poi;
    CLLocationDistance totalDistance;
    CLLocationDistance sectorCalcDistance;
    
    float totalTrackDistance = 0;
    
    NSArray *sectorArray = [_trackInfo objectForKey:@"trackpoints"];
    
    for(NSString *coordPoint in sectorArray)
    {
        if([self.trackPointArray count] > 0)
        {
            NSArray *latlong = [coordPoint componentsSeparatedByString:@","];
            NSString *lat = [latlong objectAtIndex:0];
            NSString *lng = [latlong objectAtIndex:1];
            
            NSArray *oldlatlong = [[self.trackPointArray lastObject] componentsSeparatedByString:@","];
            NSString *oldlat = [oldlatlong objectAtIndex:0];
            NSString *oldlng = [oldlatlong objectAtIndex:1];
            
            CLLocationCoordinate2D oldpoi = CLLocationCoordinate2DMake([oldlat doubleValue], [oldlng doubleValue]);
            poi = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
            
            CLLocationCoordinate2D coordinates[2];
            coordinates[0] = oldpoi;
            coordinates[1] = poi;
            
            [self.trackPointArray addObject:coordPoint];
            
            self.trackLine = [MKPolyline polylineWithCoordinates:coordinates count:2];
            [mv addOverlay:self.trackLine];
            
            MKCoordinateRegion region;
            MKCoordinateSpan span;
            span.latitudeDelta = 0.0150;
            span.longitudeDelta = 0.0150;
            region.span = span;
            region.center.latitude = [lat doubleValue];
            region.center.longitude = [lng doubleValue];
            [mv setRegion:region animated:YES];
            
            CLLocation *lastLocation = [[CLLocation alloc] initWithLatitude:[oldlat doubleValue] longitude:[oldlng doubleValue]];
            CLLocation *nextLocation = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
            totalTrackDistance = totalTrackDistance + [lastLocation distanceFromLocation:nextLocation];
            
            MKMapCamera *camera = [MKMapCamera
                                    cameraLookingAtCenterCoordinate:poi
                                    fromEyeCoordinate:oldpoi
                                    eyeAltitude:150.0];
            
            [runCameras addObject:camera];
        }
        else
        {
            [self.trackPointArray addObject:coordPoint];
        }
    }
    
    // add the sector points for 1, 2
    // divide the total track distance by 3
    sectorCalcDistance = totalTrackDistance / 3;
    totalDistance = 0;
    bool sector1Set = FALSE;
    self.trackSectorPointArray = [[NSMutableArray alloc] init];
    
    for(NSString *coordPoint in sectorArray)
    {
        if([self.trackSectorPointArray count] > 0)
        {
            NSArray *latlong = [coordPoint componentsSeparatedByString:@","];
            NSString *lat = [latlong objectAtIndex:0];
            NSString *lng = [latlong objectAtIndex:1];
            
            NSArray *oldlatlong = [[self.trackSectorPointArray lastObject] componentsSeparatedByString:@","];
            NSString *oldlat = [oldlatlong objectAtIndex:0];
            NSString *oldlng = [oldlatlong objectAtIndex:1];
            
            CLLocationCoordinate2D oldpoi = CLLocationCoordinate2DMake([oldlat doubleValue], [oldlng doubleValue]);
            poi = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
            
            CLLocationCoordinate2D coordinates[2];
            coordinates[0] = oldpoi;
            coordinates[1] = poi;
            
            [self.trackSectorPointArray addObject:coordPoint];
            
            CLLocation *lastLocation = [[CLLocation alloc] initWithLatitude:[oldlat doubleValue] longitude:[oldlng doubleValue]];
            CLLocation *nextLocation = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
            totalDistance = totalDistance + [lastLocation distanceFromLocation:nextLocation];
            
            if(totalDistance > (sectorCalcDistance))
            {
                if(!sector1Set)
                {
                    sector1EndPoint = [[CLLocation alloc] initWithLatitude:[lat floatValue] longitude:[lng floatValue]];
                    sector1Set = TRUE;
                    
                    sector1Ann = [[Sector1Annotaion alloc] init];
                    sector1Ann.coordinate = CLLocationCoordinate2DMake(sector1EndPoint.coordinate.latitude, sector1EndPoint.coordinate.longitude);
                    sector1Ann.title = @"Sector1";
                    [mv addAnnotation:sector1Ann];
                }
            }
            
            if(totalDistance > (sectorCalcDistance * 2))
            {
                sector2EndPoint = [[CLLocation alloc] initWithLatitude:[lat floatValue] longitude:[lng floatValue]];
                
                sector2Ann = [[Sector2Annotation alloc] init];
                sector2Ann.coordinate = sector2EndPoint.coordinate;
                sector2Ann.title = @"Sector2";
                [mv addAnnotation:sector2Ann];
                break;
            }
        }
        else
        {
            [self.trackSectorPointArray addObject:coordPoint];
        }
    }
    
    // Add start finish indicator
    NSDictionary *startFinishDict = [_trackInfo objectForKey:@"StartLine"];
    startfinish = [[StartFinishAnnotation alloc] init];
    CLLocationCoordinate2D startFinishPoi = CLLocationCoordinate2DMake([[startFinishDict objectForKey:@"Lat"] doubleValue], [[startFinishDict objectForKey:@"Long"] doubleValue]);
    startfinish.coordinate = startFinishPoi;
    startfinish.title = @"Start Finish";
    [mv addAnnotation:startfinish];
    
    [self showSectorTimes];
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.0150;
    span.longitudeDelta = 0.0150;
    region.span = span;
    region.center.latitude = poi.latitude;
    region.center.longitude = poi.longitude;
    [mv setRegion:region animated:YES];
}

-(void)zoomToPolyLine: (MKMapView*)map polyLine: (MKPolyline*)polyLine
             animated: (BOOL)animated
{
    MKPolygon* polygon =
    [MKPolygon polygonWithPoints:polyLine.points count:polyLine.pointCount];
    
    [map setRegion:MKCoordinateRegionForMapRect([polygon boundingMapRect])
          animated:animated];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKOverlayView* overlayView = nil;
    self.trackLineView = [[MKPolylineView alloc] initWithPolyline:[self trackLine]];
    
    [[self trackLineView] setFillColor:[UIColor colorWithRed:167/255.0f green:210/255.0f blue:244/255.0f alpha:1.0]];
    [[self trackLineView] setStrokeColor:[UIColor colorWithRed:106/255.0f green:151/255.0f blue:232/255.0f alpha:1.0]];
    
    [[self trackLineView] setLineWidth:5.0];
    [[self trackLineView] setLineCap:kCGLineCapRound];
    overlayView = [self trackLineView];
    return overlayView;
}

-(void)showSectorTimes
{
    if(self.runData.runSectors.count > 0)
    {
        runLapsArray = [[self.runData.runSectors allObjects] mutableCopy];
        [runLapsArray sortUsingComparator:^NSComparisonResult(id a, id b) {
            RunSectors *aRunSector = (RunSectors *)a;
            RunSectors *bRunSector = (RunSectors *)b;
            NSInteger firstInteger = [aRunSector.lapNumber integerValue];
            NSInteger secondInteger = [bRunSector.lapNumber integerValue];
            
            if (firstInteger > secondInteger)
                return NSOrderedDescending;
            if (firstInteger < secondInteger)
                return NSOrderedAscending;
            return [aRunSector.lapNumber localizedCompare: bRunSector.lapNumber];
        }];
        
        if(sectorTickerArray == nil) sectorTickerArray = [[NSMutableArray alloc] init];
        
        BOOL showTicker = FALSE;
        
        for(RunSectors *rSector in runLapsArray)
        {
            startfinish.title = [NSString stringWithFormat:@"%@, Lap %@ time %@", startfinish.title,rSector.lapNumber, rSector.lapTime];
            sector1Ann.title = [NSString stringWithFormat:@"%@ - %@",sector1Ann.title, rSector.sector1Time];
            sector2Ann.title = [NSString stringWithFormat:@"%@ - %@",sector2Ann.title,rSector.sector2Time];
            
            if(rSector.lapTime != nil)
            {
                SectorTickerView *lapTickerView = [[SectorTickerView alloc] initWithFrame:CGRectMake(0, 0, 150, 20)
                                                                                   andLap:rSector.lapNumber andSector:@"0" andTime:rSector.lapTime andPurpleSector:NO];
            
                [sectorTickerArray addObject:lapTickerView];
                showTicker = TRUE;
            }
            
            if(rSector.sector1Time != nil)
            {
                SectorTickerView *sector1TickerView = [[SectorTickerView alloc] initWithFrame:CGRectMake(0, 0, 150, 20)
                                                                            andLap:rSector.lapNumber andSector:@"1" andTime:rSector.sector1Time andPurpleSector:NO];
            
                [sectorTickerArray addObject:sector1TickerView];
                showTicker = TRUE;
            }
            
            if(rSector.sector2Time != nil)
            {
            
                SectorTickerView *sector2TickerView = [[SectorTickerView alloc] initWithFrame:CGRectMake(0, 0, 150, 20)
                                                                                   andLap:rSector.lapNumber andSector:@"2" andTime:rSector.sector2Time andPurpleSector:NO];
            
                [sectorTickerArray addObject:sector2TickerView];
                showTicker = TRUE;
            }
            
            if(rSector.sector3Time != nil)
            {
                SectorTickerView *sector3TickerView = [[SectorTickerView alloc] initWithFrame:CGRectMake(0, 0, 150, 20)
                                                                                   andLap:rSector.lapNumber andSector:@"3" andTime:rSector.sector3Time andPurpleSector:NO];
            
                [sectorTickerArray addObject:sector3TickerView];
                showTicker = TRUE;
            }
        }
        
        if(showTicker)
        {
            stkticker=[[SectorTicker alloc] initWithFrame:CGRectMake(0, 123, 320, 30)];
            stkticker.sectorDelegate=self;
            [stkticker setBackgroundColor:[UIColor clearColor]];
            [mv addSubview:stkticker];
            [stkticker start];
        }
    }
}

#pragma mark- UITickerView delegate method

- (NSInteger)numberOfRowsintickerView:(SectorTicker *)tickerView
{
    return [sectorTickerArray count];
}

- (id)tickerView:(SectorTicker*)tickerView cellForRowAtIndex:(int)index
{
    return [sectorTickerArray objectAtIndex:index];
}

//-(void)showSectorTimes
//{
//    if(self.runData.runSectors.count > 0)
//    {
//        runLapsArray = [[self.runData.runSectors allObjects] mutableCopy];
//        [runLapsArray sortUsingComparator:^NSComparisonResult(id a, id b) {
//            RunSectors *aRunSector = (RunSectors *)a;
//            RunSectors *bRunSector = (RunSectors *)b;
//            NSInteger firstInteger = [aRunSector.lapNumber integerValue];
//            NSInteger secondInteger = [bRunSector.lapNumber integerValue];
//            
//            if (firstInteger > secondInteger)
//                return NSOrderedDescending;
//            if (firstInteger < secondInteger)
//                return NSOrderedAscending;
//            return [aRunSector.lapNumber localizedCompare: bRunSector.lapNumber];
//        }];
//        
//        for(RunSectors *rSector in runLapsArray)
//        {
//            CLLocationCoordinate2D sect1Cordinate =  CLLocationCoordinate2DMake([rSector.sec1Lat doubleValue], [rSector.sec1Long doubleValue]);
//            
//            Sector1Annotaion *sector1Anno = [[Sector1Annotaion alloc] init];
//            sector1Anno.coordinate = sect1Cordinate;
//            sector1Anno.title = [NSString stringWithFormat:@"Sector 1 %@",rSector.sector1Time];
//            sector1Anno.trackName = self.runData.runtrackname;
//            sector1Anno.time = rSector.lapTime;
//            sector1Anno.lap = rSector.lapNumber;
//            sector1Anno.sectorNumber = @"1";
//            sector1Anno.sectorTime = rSector.sector1Time;
//            
//            [mv addAnnotation:sector1Anno];
//            
//            MKMapCamera *camera1 = [MKMapCamera
//                                    cameraLookingAtCenterCoordinate:sect1Cordinate
//                                    fromEyeCoordinate:startCoordinate
//                                    eyeAltitude:150.0];
//            
//            [runCameras addObject:camera1];
//            
//            if(![rSector.sec2Lat isEqualToString:@"0.000000"])
//            {
//                
//                CLLocationCoordinate2D sect2Cordinate =  CLLocationCoordinate2DMake([rSector.sec2Lat doubleValue], [rSector.sec2Long doubleValue]);
//                
//                Sector2Annotation *sector2Anno = [[Sector2Annotation alloc] init];
//                sector2Anno.coordinate = sect2Cordinate;
//                sector2Anno.title = [NSString stringWithFormat:@"Sector 2 %@",rSector.sector2Time];
//                
//                sector2Anno.trackName = self.runData.runtrackname;
//                sector2Anno.time = rSector.lapTime;
//                sector2Anno.lap = rSector.lapNumber;
//                sector2Anno.sectorNumber = @"2";
//                sector2Anno.sectorTime = rSector.sector2Time;
//                
//                [mv addAnnotation:sector2Anno];
//                
//                MKMapCamera *camera2 = [MKMapCamera
//                                        cameraLookingAtCenterCoordinate:sect2Cordinate
//                                        fromEyeCoordinate:sect1Cordinate
//                                        eyeAltitude:150.0];
//                
//                [runCameras addObject:camera2];
//                
//                
//                if(![rSector.lapLat isEqualToString:@"0.000000"])
//                {
//                    CLLocationCoordinate2D lapCordinate =  CLLocationCoordinate2DMake([rSector.lapLat doubleValue], [rSector.lapLong doubleValue]);
//                    
//                    LapAnnotation *finishAnno = [[LapAnnotation alloc] init];
//                    finishAnno.coordinate = lapCordinate;
//                    finishAnno.title = [NSString stringWithFormat:@"Lap %@ time %@",rSector.lapNumber, rSector.lapTime];
//                    
//                    finishAnno.trackName = self.runData.runtrackname;
//                    finishAnno.time = rSector.lapTime;
//                    finishAnno.lap = rSector.lapNumber;
//                    finishAnno.sectorTime = rSector.sector3Time;
//                    finishAnno.sectorNumber = @"3";
//                    [mv addAnnotation:finishAnno];
//                    
//                    MKMapCamera *camera3 = [MKMapCamera
//                                            cameraLookingAtCenterCoordinate:lapCordinate
//                                            fromEyeCoordinate:sect2Cordinate
//                                            eyeAltitude:150.0];
//                    
//                    
//                    
//                    [runCameras addObject:camera3];
//                }
//            }
//            
//        }
//    }
//}



#pragma mark MapView Delegate

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // in case it's the user location, we already have an annotation, so just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    // handle our three custom annotations
    //
    if ([annotation isKindOfClass:[StartFinishAnnotation class]])
    {
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
    } else if ([annotation isKindOfClass:[Sector1Annotaion class]])
    {
        static NSString *sector1ID = @"Sector1ID";
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mv dequeueReusableAnnotationViewWithIdentifier:sector1ID];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:sector1ID];
            UIImage *flagImage = [UIImage imageNamed:@"sector1.png"];
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
    } else if ([annotation isKindOfClass:[Sector2Annotation class]])
    {
        static NSString *sector2ID = @"Sector2ID";
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mv dequeueReusableAnnotationViewWithIdentifier:sector2ID];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:sector2ID];
            UIImage *flagImage = [UIImage imageNamed:@"sector2.png"];
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
    else if ([annotation isKindOfClass:[StartFinishAnnotation class]])
    {
        static NSString *lapID = @"LapID";
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mv dequeueReusableAnnotationViewWithIdentifier:lapID];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:lapID];
            UIImage *flagImage = [UIImage imageNamed:@"runnerLap.png"];
            // You may need to resize the image here.
            annotationView.image = flagImage;
            annotationView.canShowCallout = NO;
            return annotationView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    
    return nil;
}

#pragma mark social sharing

-(IBAction)showActivityView:(id)sender
{
    UIActionSheet *loginActionSheet;
    if([self.runData.runtype isEqualToString:@"GPSRun"])
    {
    
     loginActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share using" delegate:self cancelButtonTitle:@"Cancel"  destructiveButtonTitle:@"share on facebook" otherButtonTitles:@"share on twitter", @"go to run", nil];
    }
    else
    {
     loginActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share using" delegate:self cancelButtonTitle:@"Cancel"  destructiveButtonTitle:@"share on facebook" otherButtonTitles:@"share on twitter", nil];
    }

    [loginActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self shareOnFacebook];
    }
    else if (buttonIndex == 1) {
        [self shareOnTwitter];
    }
    else if (buttonIndex == 2)
    {
        [self goToTrack];
    }
}

-(void)goToTrack
{
    [self performSegueWithIdentifier:@"RunMapSegue" sender:self];
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
}

-(void)composePost:(NSString *)serviceType
{
    shareButton.hidden = YES;
    SLComposeViewController *composeSheet=[[SLComposeViewController alloc]init];
    composeSheet=[SLComposeViewController composeViewControllerForServiceType:serviceType];
    [composeSheet setInitialText:[NSString stringWithFormat:@"Comepleted a run round the %@ GP track. %@ %@ %@ @runthetracks", self.navigationItem.title, self.runData.runtime, runDistance.text, self.runData.runlaps]];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:currentContext];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [composeSheet addImage:screenshot];
    [self presentViewController:composeSheet animated:YES completion:nil];
    shareButton.hidden = NO;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RunMapSegue"]) {
        RunTrackMapViewController *rsvc = segue.destinationViewController;
        [rsvc setRunData:self.runData];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dealloc
{
    mv.delegate = nil;
    stkticker.sectorDelegate = nil;
}
@end
