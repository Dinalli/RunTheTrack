//
//  RunDetailViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 10/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "JBKenBurnsView.h"
#import "RunData.h"
#import "RunLocations.h"

@interface RunDetailViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate>
{
    IBOutlet UILabel *runTime;
    IBOutlet UILabel *runLaps;
    IBOutlet UILabel *runDistance;
    IBOutlet UIImageView *trackMapImage;
    IBOutlet UILabel *runDate;
    IBOutlet UILabel *trackNameLabel;
    
    UIImage *mapImage;
    
    IBOutlet MKMapView *mv;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,strong) RunData *runData;

@property (nonatomic, strong) MKPolyline* trackLine;
@property (nonatomic, strong) MKPolylineView* trackLineView;

@end
