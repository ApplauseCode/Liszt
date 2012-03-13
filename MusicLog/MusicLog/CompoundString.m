//
//  CompoundString.m
//  Liszt
//
//  Created by Jeffrey Rosenbluth on 3/12/12.
//  Copyright (c) 2012 Applause Code. All rights reserved.
//

#import "CompoundString.h"

@implementation CompoundString

@synthesize strings;
@synthesize fonts;
@synthesize kerns;
@synthesize base;

- (void)drawAtPoint:(CGPoint) point
{
    int stringCount = [strings count];
    CGFloat widths[stringCount];
    CGFloat b;
    for (int i = 0; i < stringCount; i++) {
        b = [[base objectAtIndex:i] floatValue];
        widths[i] = [[strings objectAtIndex:i] sizeWithFont:[fonts objectAtIndex:i]].width;
        [[strings objectAtIndex:i] drawAtPoint:CGPointMake(point.x, point.y - b) forWidth:widths[i] withFont:[fonts objectAtIndex:i] lineBreakMode:UILineBreakModeTailTruncation];
        point.x += widths[i] + [[kerns objectAtIndex:i] floatValue];
    }
}

@end
