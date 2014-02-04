//
//  SectorTickerView.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 04/02/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SectorTickerView : UIView

- (id)initWithFrame:(CGRect)frame andLap:(NSString *)lap andSector:(NSString *)sector andTime:(NSString *)sectorTime andPurpleSector:(BOOL)purpleSector;

@end
