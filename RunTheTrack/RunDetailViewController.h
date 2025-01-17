//
//  RunDetailViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 10/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RunData.h"
#import "RunLocations.h"
#import "SectorTicker.h"

@interface RunDetailViewController : RTTBaseViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate, SectorTickerDelegate>
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
    
    IBOutlet UIButton *shareButton;
    
    NSMutableArray *runCameras;
    
    CLLocationCoordinate2D startCoordinate;
    CLLocationCoordinate2D endCoordinate;
    int cameraIndex;
    
    NSMutableArray *sectorArray;
    SectorTicker *stkticker;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,strong) RunData *runData;

@property (nonatomic, strong) MKPolyline* trackLine;
@property (nonatomic, strong) MKPolylineView* trackLineView;

@end
