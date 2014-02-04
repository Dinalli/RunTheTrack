//
//  SectorTicker.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 04/02/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SectorTicker;

@protocol SectorTickerDelegate<NSObject>

@required
- (NSInteger)numberOfRowsintickerView:(SectorTicker *)tickerView;
- (id)tickerView:(SectorTicker*)tickerView cellForRowAtIndex:(int)index;
@end

@interface SectorTicker : UIScrollView
{
@private
    int count;
    int numberOfObjects;
}

@property (assign) id<SectorTickerDelegate>sectorDelegate;

-(void)start;
@end
