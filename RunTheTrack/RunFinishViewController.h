//
//  RunFinishViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 27/10/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "JBKenBurnsView.h"

@interface RunFinishViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate>
{
    IBOutlet UIImageView *trackMapImage;
    IBOutlet UILabel *runTime;
    IBOutlet UILabel *runLaps;
    IBOutlet UILabel *runDistance;
    IBOutlet UILabel *paceLabel;
    IBOutlet UILabel *trackName;

    IBOutlet MKMapView *mv;
    
    UIImage *mapImage;
    
    UIView *toastView;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) NSMutableDictionary *trackInfo;
@property (nonatomic) NSDictionary *runInfo;

@property (nonatomic, strong) MKPolyline* trackLine;
@property (nonatomic, strong) MKPolylineView* trackLineView;

@end
