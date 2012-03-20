//
//  StatsView.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatsView.h"

@implementation StatsView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *failed = [super hitTest:point withEvent:event];
    UIView *result = [[self delegate] hitWithPoint:point];
    if (!result)
        return failed;
    return [[self delegate] hitWithPoint:point];
}

@end
