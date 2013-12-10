//
//  RunSectorCell.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 05/12/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "RunSectorCell.h"

@implementation RunSectorCell

@synthesize trackLabel, lapTime, lapNumber, sector1Time, sector2Time, sector3Time;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
