//
//  RunTrackMapViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "RunData.h"
#import "RunLocations.h"
#import "Sector1Annotaion.h"
#import "Sector2Annotation.h"
#import "StartFinishAnnotation.h"
#import "SectorTickerView.h"
#import "SectorTicker.h"

@interface RunTrackMapViewController : RTTBaseViewController <MKMapViewDelegate, UIActionSheetDelegate, SectorTickerDelegate>
{
    IBOutlet UILabel *runTime;
    IBOutlet UILabel *runLaps;
    IBOutlet UILabel *runDistance;
    IBOutlet UIImageView *trackMapImage;
    IBOutlet UILabel *runDate;
    
    IBOutlet UIView *detailsView;
    
    UIImage *mapImage;
    
    IBOutlet MKMapView *mv;
    
    
    NSMutableArray *runLapsArray;
    
    CLLocation *sector1EndPoint;
    CLLocation *sector2EndPoint;
    
    Sector1Annotaion *sector1Ann;
    Sector2Annotation *sector2Ann;
    StartFinishAnnotation *startfinish;
    
    IBOutlet UIButton *shareButton;
    
    NSMutableArray *runCameras;
    
    CLLocationCoordinate2D startCoordinate;
    CLLocationCoordinate2D endCoordinate;
    int cameraIndex;
    
    NSMutableArray *sectorTickerArray;
    SectorTicker *stkticker;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,strong) RunData *runData;
@property (nonatomic, strong) NSMutableArray *trackPointArray;
@property (nonatomic) NSMutableDictionary *trackInfo;
@property (nonatomic, strong) NSMutableArray *trackSectorPointArray;
@property (nonatomic, strong) MKPolyline* trackLine;
@property (nonatomic, strong) MKPolylineView* trackLineView;

@end

