//
//  TimeCalloutView.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 03/02/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeCalloutView : UIView

@property (nonatomic) UILabel *trackName;
@property (nonatomic) UILabel *lap;
@property (nonatomic) UILabel *time;
@property (nonatomic) UILabel *sectorNumber;

-(void)setTrackNameText:(NSString *)trackNameValue;
-(void)setSectorText:(NSString *)sectorValue;
-(void)setLapText:(NSString *)lapValue;
-(void)setTimeText:(NSString *)timeValue;

@end
