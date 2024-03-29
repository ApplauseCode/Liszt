//
//  PieceCell.m
//  Liszt
//
//  Created by Jeffrey Rosenbluth on 3/12/12.
//  Copyright (c) 2012 Applause Code. All rights reserved.
//

#import "PieceCell.h"
#import "Piece.h"
#import "Other.h"
#import "CompoundString.h"

#define kLeftMargin 40
#define kTopMargin 5
#define kMiddleMargin 14
#define kBottomMargin 23
#define kRightMargin 190


@interface PieceCell ()
@property (nonatomic, copy) NSString *_composerLabel;
@property (nonatomic, copy) NSString *_modeLabel;
@property (nonatomic, copy) NSString *_speedLabel;
@property (nonatomic, strong) CompoundString *_keyCompoundString;

@end

@implementation PieceCell

@synthesize _composerLabel;
@synthesize _modeLabel;
@synthesize _speedLabel;
@synthesize _keyCompoundString;
static UIImage *_backgroundImage = nil;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

+ (void)initialize
{
    [super initialize];
    _backgroundImage = [UIImage imageNamed:@"FinalLisztCell.png"];
    
}

- (void)updateLabels:(id)item
{
    NSString *composer;
    NSString *mode;
    if ([item isKindOfClass:[Piece class]])
    {
        mode = ([item major]) ? @"Major" : @"Minor";
        composer = [item composer];
        if (_speedLabel != ([item tempo] == 0 ? @"--" : [NSString stringWithFormat:@"%i bpm", [item tempo]])) 
        {
            _speedLabel = ([item tempo] == 0 ? @"--" : [NSString stringWithFormat:@"%i bpm", [item tempo]]);
        } 
        _keyCompoundString = [item keyCompoundString];
    }
    else
    {
        composer = [item subTitle];
        mode = @"";
        _speedLabel = @"";
        _keyCompoundString = nil;
    }
    if (_composerLabel != composer) {
        _composerLabel = composer;
    }
    if (_modeLabel != mode) {
        _modeLabel = mode;
    }

    [self setNeedsDisplay];
}

- (void)drawContentView:(CGRect)r
{
    [super drawContentView:r];
    [_backgroundImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [_speedLabel drawAtPoint:CGPointMake(kLeftMargin, kBottomMargin + 2) 
                    forWidth:200 
                    withFont:[self defaultLargeFont] 
               lineBreakMode:UILineBreakModeTailTruncation];
    
    [_composerLabel drawAtPoint:CGPointMake(kLeftMargin, kTopMargin)
                       forWidth:260 withFont:[self defaultLargeFont]
                  lineBreakMode:UILineBreakModeTailTruncation];
    
    CGSize modeSize = [_modeLabel sizeWithFont:[self defaultLargeFont]];
    NSInteger rightMargin = self.frame.size.width - kLeftMargin;
    NSInteger modeXVal = rightMargin - modeSize.width;
    [_modeLabel drawAtPoint:CGPointMake(modeXVal, kMiddleMargin + 2)
                   forWidth:modeSize.width
                   withFont:[self defaultLargeFont]
              lineBreakMode:UILineBreakModeTailTruncation]; 
    
    [_keyCompoundString drawAtPoint:CGPointMake(modeXVal - 28, kMiddleMargin + 2)];
    

}


@end
