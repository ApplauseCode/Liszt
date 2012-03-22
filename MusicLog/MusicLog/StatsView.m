//
//  StatsView.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 3/17/12.
//  Copyright (c) 2012 __Applause Code__. All rights reserved.
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

//- (void) drawRect:(CGRect)rect
//{
//    CGContextRef context = UIGraphicsGetCurrentContext();    
//    UIColor *blackColor = [UIColor whiteColor];
//    [blackColor set];
//    CGContextBeginPath(context);
//    CGContextMoveToPoint(context, 50.0, -50.0);
//    CGContextAddLineToPoint(context, 50.0, rect.size.height + 100);
//    CGContextSetLineWidth(context, 20);
//    CGContextClosePath(context);
//    CGContextSetShadowWithColor(context, CGSizeMake(-20, 0), 3, [UIColor blackColor].CGColor);
//    CGContextStrokePath(context);
//}

@end

