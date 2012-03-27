//
//  HistoryCell.m
//  Liszt
//
//  Created by Jeffrey Rosenbluth on 3/20/12.
//  Copyright (c) 2012 Applause Code. All rights reserved.
//

#import "HistoryCell.h"
#define kLeftMargin 80
#define kTopMargin 15

@implementation HistoryCell
@synthesize titleLabel;
@synthesize subTitleLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) updateTitle:(NSString *)_title subTitle:(NSString *)_subTitle;
{
    titleLabel = _title;
    subTitleLabel = _subTitle;
    [self setNeedsDisplay];
}

- (void)drawContentView:(CGRect)r
{
    [super drawContentView:r];
    [titleLabel drawAtPoint:CGPointMake(kLeftMargin, kTopMargin)
                   forWidth:135
                   withFont:[self defaultLargeFont]
              lineBreakMode:UILineBreakModeTailTruncation];   
    [subTitleLabel drawAtPoint:CGPointMake(235, kTopMargin)
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
