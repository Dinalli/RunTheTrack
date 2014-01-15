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
#import "HistoryBaseViewController.h"

@interface RunTrackMapViewController : HistoryBaseViewController <MKMapViewDelegate, UIActionSheetDelegate>
{
    IBOutlet UILabel *runTime;
    IBOutlet UILabel *runLaps;
    IBOutlet UILabel *runDistance;
    IBOutlet UIImageView *trackMapImage;
    IBOutlet UILabel *runDate;
    
    UIImage *mapImage;
    
    IBOutlet MKMapView *mv;
    
    NSMutableArray *runLapsArray;
    
    CLLocation *sector1EndPoint;
    CLLocation *sector2EndPoint;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,strong) RunData *runData;
@property (nonatomic, strong) NSMutableArray *trackPointArray;
@property (nonatomic) NSMutableDictionary *trackInfo;
@property (nonatomic, strong) NSMutableArray *trackSectorPointArray;
@property (nonatomic, strong) MKPolyline* trackLine;
@property (nonatomic, strong) MKPolylineView* trackLineView;

@end

