//
//  RunSectorCell.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 05/12/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RunSectorCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *trackLabel;
@property (nonatomic, strong) IBOutlet UILabel *lapTime;
@property (nonatomic, strong) IBOutlet UILabel *lapNumber;
@property (nonatomic, strong) IBOutlet UILabel *sector1Time;
@property (nonatomic, strong) IBOutlet UILabel *sector2Time;
@property (nonatomic, strong) IBOutlet UILabel *sector3Time;

@end
