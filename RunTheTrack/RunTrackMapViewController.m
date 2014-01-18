//
//  RunTrackMapViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import "RunTrackMapViewController.h"
#import "CoreDataHelper.h"
#import "MKRunnerAnnotation.h"
#import "StartFinishAnnotation.h"
#import "Sector1Annotaion.h"
#import "Sector2Annotation.h"
#import <Social/Social.h>
#import "AppDelegate.h"

@implementation RunTrackMapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES];
        
    runTime.text = [NSString stringWithFormat:@"Time : %@", self.runData.runtime];
    runLaps.text = [NSString stringWithFormat:@"Laps : %@",self.runData.runlaps];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([appDelegate useKMasUnits])
    {
        runDistance.text = [NSString stringWithFormat:@"%.02f km", [self.runData.rundistance floatValue] / 1000];
    }
    else
    {
        runDistance.text = [NSString stringWithFormat:@"Distance %.2f miles",[self.runData.rundistance floatValue] * 0.000621371192];
    }
    
    runDate.text = [NSString stringWithFormat:@"Date : %@",self.runData.rundate];
    self.navigationItem.title = self.runData.runtrackname;

    for (NSMutableDictionary *trackInfoDict in appDelegate.tracksArray) {
        if([[trackInfoDict objectForKey:@"Race"] isEqualToString:self.runData.runtrackname])
        {
            self.trackInfo = trackInfoDict;
            trackMapImage.image = [UIImage imageNamed:[trackInfoDict objectForKey:@"mapimage"]];
        }
    }
    self.trackPointArray = [[NSMutableArray alloc] init];
    [self addTrackPoints];
    
    [CommonUtils shadowAndRoundView:detailsView];
    [CommonUtils addMotionEffectToView:detailsView];

    mv.camera.pitch = 45;

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
        }
        else
        {
            [self.trackPointArray addObject:coordPoint];
        }
    }
    
    NSLog(@"TOTAL TRACK DISTANCE %.2f", totalTrackDistance / 1000);
    
    MKRunnerAnnotation *runner = [[MKRunnerAnnotation alloc] init];
    runner.coordinate = poi;
    runner.title = @"Runner";
    [mv addAnnotation:runner];
    
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
                    
                    Sector1Annotaion *sector1Ann = [[Sector1Annotaion alloc] init];
                    sector1Ann.coordinate = CLLocationCoordinate2DMake(sector1EndPoint.coordinate.latitude, sector1EndPoint.coordinate.longitude);
                    sector1Ann.title = @"Sector1";
                    [mv addAnnotation:sector1Ann];
                }
            }
            
            if(totalDistance > (sectorCalcDistance * 2))
            {
                sector2EndPoint = [[CLLocation alloc] initWithLatitude:[lat floatValue] longitude:[lng floatValue]];
                
                Sector2Annotation *sector2Ann = [[Sector2Annotation alloc] init];
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
    StartFinishAnnotation *startfinish = [[StartFinishAnnotation alloc] init];
    CLLocationCoordinate2D startFinishPoi = CLLocationCoordinate2DMake([[startFinishDict objectForKey:@"Lat"] doubleValue], [[startFinishDict objectForKey:@"Long"] doubleValue]);
    startfinish.coordinate = startFinishPoi;
    startfinish.title = @"Start Finish";
    [mv addAnnotation:startfinish];
    
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
    if ([annotation isKindOfClass:[MKRunnerAnnotation class]])
    {
        static NSString *RunnerAnnotationIdentifier = @"runnerID";
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mv dequeueReusableAnnotationViewWithIdentifier:RunnerAnnotationIdentifier];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:RunnerAnnotationIdentifier];
            UIImage *flagImage = [UIImage imageNamed:@"runnerDot.png"];
            // You may need to resize the image here.
            annotationView.image = flagImage;
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
        static NSString *SFAnnotationIdentifier = @"StartFinishID";
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mv dequeueReusableAnnotationViewWithIdentifier:SFAnnotationIdentifier];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:SFAnnotationIdentifier];
            
            UIImage *flagImage = [UIImage imageNamed:@"cheq.png"];
            // You may need to resize the image here.
            annotationView.image = flagImage;
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


@end
