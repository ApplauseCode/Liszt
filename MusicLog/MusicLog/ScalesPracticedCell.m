//
//  CustomCell.m
//  PianoLog
//
//  Created by Kyle Rosenbluth on 8/8/11.
//  Copyright 2011 __Applause Code__. All rights reserved.
//

#import "ScalesPracticedCell.h"

@interface ScalesPracticedCell ()
{
    IBOutlet UIView *cellView;
}
@end
@implementation ScalesPracticedCell
@synthesize octavesIdentifier;

@synthesize tonicLabel, octavesLabel, rhythmLabel, speedLabel, modeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[self contentView] addSubview:cellView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];    
}


@end
