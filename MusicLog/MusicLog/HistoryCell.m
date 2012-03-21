//
//  HistoryCell.m
//  Liszt
//
//  Created by Jeffrey Rosenbluth on 3/20/12.
//  Copyright (c) 2012 Applause Code. All rights reserved.
//

#import "HistoryCell.h"
#define kLeftMargin 40
#define kTopMargin 5

@implementation HistoryCell
@synthesize tempLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawContentView:(CGRect)r
{
    [super drawContentView:r];
    [tempLabel drawAtPoint:CGPointMake(kLeftMargin, kTopMargin)
                   forWidth:135
                   withFont:[self defaultLargeFont]
              lineBreakMode:UILineBreakModeTailTruncation];   
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
