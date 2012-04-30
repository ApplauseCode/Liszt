//
//  HistoryCell.m
//  Liszt
//
//  Created by Jeffrey Rosenbluth on 3/20/12.
//  Copyright (c) 2012 Applause Code. All rights reserved.
//

#import "HistoryCell.h"
#define kLeftMargin 40
#define kTopMargin 15

@implementation HistoryCell
@synthesize titleLabel;
@synthesize subTitleLabel;
@synthesize isSelected;
@synthesize isCellBeforeSelected;
static UIImage *_separator = nil;
static UIImage *_arrow = nil;
static UIImage *_bgImage = nil;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //[self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)selectCell:(BOOL)selected
{
    [self setIsSelected:selected];
    [self setNeedsDisplay];
}

- (void)cellBeforeSelected:(BOOL)_prev
{
    [self setIsCellBeforeSelected:_prev];
    [self setNeedsDisplay];
}

+ (void)initialize
{
    [super initialize];
    _separator = [UIImage imageNamed:@"ParchSeparator.png"];
    _arrow = [UIImage imageNamed:@"HistoryExpandIcon.png"];
    _bgImage = [UIImage imageNamed:@"overstate.png"];
    //_bgImage = [_bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
}

- (void) updateTitle:(NSString *)_title subTitle:(NSString *)_subTitle
{
    titleLabel = _title;
    subTitleLabel = _subTitle;
    [self setNeedsDisplay];
}


- (void)drawContentView:(CGRect)r
{
    [super drawContentView:r];
    if (isSelected)
    {
        [_bgImage drawInRect:CGRectMake(6, 0, _bgImage.size.width + 50, _bgImage.size.height + 8)];
    }
    else if (!isCellBeforeSelected)
    {
        CGSize sepSize = [_separator size];
        [_separator drawInRect:CGRectMake(kLeftMargin, self.frame.size.height - sepSize.height, sepSize.width, sepSize.height)];
    }
    
    CGSize arrowSize = [_arrow size];

    [titleLabel drawAtPoint:CGPointMake(kLeftMargin, kTopMargin)
                   forWidth:135
                   withFont:[self defaultLargeFont]
              lineBreakMode:UILineBreakModeTailTruncation];   
    [subTitleLabel drawAtPoint:CGPointMake(165, kTopMargin)
                      forWidth:135
                      withFont:[self defaultLargeFont]
                 lineBreakMode:UILineBreakModeTailTruncation];
    [_arrow drawInRect:CGRectMake(self.frame.size.width - 75, (self.frame.size.height/2.0) - 2, arrowSize.width, arrowSize.height)];
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
