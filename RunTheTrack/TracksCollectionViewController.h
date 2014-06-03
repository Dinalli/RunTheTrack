//
//  TracksCollectionViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/10/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <iAd/iAd.h>

@interface TracksCollectionViewController : RTTBaseViewController <UICollectionViewDataSource, UICollectionViewDelegate,ADBannerViewDelegate>
{
    AppDelegate *appDelegate;
    ADBannerView *adView;
    
    IBOutlet UICollectionView *collectionView;
}
@end
