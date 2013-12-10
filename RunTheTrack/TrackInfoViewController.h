//
//  TrackInfoViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/10/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBKenBurnsView.h"

@interface TrackInfoViewController : UIViewController
{
    IBOutlet KenBurnsView *kenView;
    IBOutlet UILabel *trackName;
    IBOutlet UILabel *laps;
    IBOutlet UILabel *trackDistance;
    IBOutlet UIImageView *trackMiniMap;
    IBOutlet UIButton *selectBtn;
}

@property (nonatomic) NSMutableDictionary *trackInfo;

@end
