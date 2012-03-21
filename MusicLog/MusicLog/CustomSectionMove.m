//
//  CustomSectionMove.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 3/16/12.
//  Copyright (c) 2012 __Applause Code__. All rights reserved.
//

#import "CustomSectionMove.h"

@implementation CustomSectionMove
@synthesize numberOfSections;
@synthesize heightOfSection;
@synthesize selectedSection;
@synthesize delegate;
@synthesize oldSection;

- (id)initWithFrame:(CGRect)frame numberOfSections:(NSInteger)sections heightOfSection:(NSInteger)height;
{
    self = [super initWithFrame:frame];
    if (self) {
        numberOfSections = sections;
        heightOfSection = height;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
//    NSLog(@"touch location:%f", [touch locationInView:self].y);
    selectedSection = ceil([touch locationInView:self].y / heightOfSection);
    [[self delegate] sectionMoveLocationSelected:selectedSection];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
