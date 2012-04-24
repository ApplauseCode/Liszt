//
//  OtherCell.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OtherCell.h"
#import "Other.h"

#define kLeftMargin 40
#define kTopMargin 5
#define kMiddleMargin 14
#define kBottomMargin 23
#define kRightMargin 190

@interface OtherCell ()
@property (nonatomic, copy) NSString *_titleString;
@property (nonatomic, copy) NSString *_subTitleString;
@property (nonatomic, copy) NSString *_descriptionString;
@end
@implementation OtherCell
@synthesize _titleString;
@synthesize _subTitleString;
@synthesize _descriptionString;
static UIImage *_topBackgroundImage = nil;
static UIImage *_bottomBackgroundImage = nil;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (void)initialize
{
    [super initialize];
    _topBackgroundImage = [UIImage imageNamed:@"FinalLisztCell.png"];
    _bottomBackgroundImage = [UIImage imageNamed:@"NotesInputArea"];
}

- (void)updateLabels:(Other *)other
{
    NSString *title = [other title];
    NSString *subTitle = [other subTitle];
    NSString *description = [other description];
    
    if (_titleString != title) {
        _titleString = title;
    }
    if (_subTitleString != subTitle) {
        _subTitleString = subTitle;
    }
    if (_descriptionString != description) {
        _descriptionString = description;
    }
    [self setNeedsDisplay];
}

- (void)drawContentView:(CGRect)r
{
    [_topBackgroundImage drawInRect:CGRectMake(0,
                                               0,
                                               _topBackgroundImage.size.width,
                                               _topBackgroundImage.size.height)];
    
    [_subTitleString drawAtPoint:CGPointMake(kLeftMargin, kTopMargin)
                       forWidth:260 withFont:[self defaultLargeFont]
                  lineBreakMode:UILineBreakModeTailTruncation];
    
    [_bottomBackgroundImage drawInRect:CGRectMake(_topBackgroundImage.size.width/2.0 - _bottomBackgroundImage.size.width/2.0,
                                                  _topBackgroundImage.size.height,
                                                  _bottomBackgroundImage.size.width,
                                                  _bottomBackgroundImage.size.height)];
    [_descriptionString drawInRect:CGRectMake(_topBackgroundImage.size.width/2.0 - 215/2.0,
                                              _topBackgroundImage.size.height + 10,
                                              215,
                                              127) 
                          withFont:[UIFont fontWithName:@"ACaslonPro-Italic" size:18]
                     lineBreakMode:UILineBreakModeTailTruncation];
}
@end
