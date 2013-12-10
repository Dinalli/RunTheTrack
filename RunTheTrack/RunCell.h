//
//  RunCell.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 10/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RunCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *trackLabel;
@property (nonatomic, strong) IBOutlet UILabel *runDistanceLabel;
@property (nonatomic, strong) IBOutlet UILabel *runTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *runDateLabel;
@property (nonatomic, strong) IBOutlet UILabel *runLaps;


@end
