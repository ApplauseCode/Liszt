//
//  ScaleCell.m
//  Liszt
//
//  Created by Jeffrey Rosenbluth on 3/11/12.
//  Copyright (c) 2012 Applause Code. All rights reserved.
//

#import "ScaleCell.h"
#import "Scale.h"
#import "CompoundString.h"


#define kLeftMargin 40
#define kTopMargin 5
#define kBottomMargin 25
#define kRightMargin 190


@interface ScaleCell ()
@property (nonatomic, copy) NSString *_octavesLabel;
@property (nonatomic, copy) NSString *_rhythmLabel;
@property (nonatomic, copy) NSString *_modeLabel;
@property (nonatomic, copy) NSString *_speedLabel;
@property (nonatomic, strong) CompoundString *_tonicCompoundString;

@end

@implementation ScaleCell

@synthesize _octavesLabel;
@synthesize _rhythmLabel;
@synthesize _modeLabel;
@synthesize _speedLabel;
@synthesize _tonicCompoundString;
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
- (void)updateLabels:(Scale *)scale
{
    NSString *octaves = [scale octavesString];
    NSString *rhythm = [scale rhythmString];
    NSString *mode = [scale modeString];
    NSString *speed = [scale tempoString];
    
    if (_octavesLabel != octaves) {
        _octavesLabel = octaves;
    }
    if (_rhythmLabel != rhythm) {
        _rhythmLabel = rhythm;
    }
    if (_modeLabel != mode) {
        _modeLabel = mode;
    }
    if (_speedLabel != speed) {
        _speedLabel = speed;
    } 
    _tonicCompoundString = [scale tonicCompoundString];
    [self setNeedsDisplay];
}

- (void)drawContentView:(CGRect)r
{
    [super drawContentView:r];
    [_backgroundImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [_tonicCompoundString drawAtPoint:CGPointMake(kLeftMargin, kTopMargin)];
    [_speedLabel drawAtPoint:CGPointMake(kLeftMargin, kBottomMargin) 
                    forWidth:200 
                    withFont:[self defaultSmallFont] 
               lineBreakMode:UILineBreakModeTailTruncation]; 
    
    CGSize modeSize = [_modeLabel sizeWithFont:[self defaultLargeFont]];
    NSInteger rightMargin = self.frame.size.width - kLeftMargin;
    NSInteger modeXVal = rightMargin - modeSize.width;
    NSInteger octavesFinisherXVal = rightMargin - [[self octaveFinisher] sizeWithFont:[self defaultVerySmallFont]].width;
    
    [[self octaveFinisher] drawAtPoint:CGPointMake(octavesFinisherXVal, kBottomMargin+2)
                              forWidth:40
                              withFont:[self defaultVerySmallFont]
                         lineBreakMode:UILineBreakModeTailTruncation];
    
  
    [_modeLabel drawAtPoint:CGPointMake(modeXVal, kTopMargin)
                   forWidth:135
                   withFont:[self defaultLargeFont]
              lineBreakMode:UILineBreakModeTailTruncation];    
    NSInteger octavesXVal = octavesFinisherXVal - 6 - [_octavesLabel sizeWithFont:[self defaultSmallFont]].width;
    NSInteger rhythmXVal = octavesXVal - 10 - [_rhythmLabel sizeWithFont:[self defaultSmallFont]].width;
    //NSInteger octavesXCoord = modeXVal + [_rhythmLabel sizeWithFont:[self defaultSmallFont]].width + 10;
    
    
    //NSInteger octavesFinisherXCoord = octavesXCoord + [_octavesLabel sizeWithFont:[self defaultVerySmallFont]].width + 6;
    
    [_rhythmLabel drawAtPoint:CGPointMake(rhythmXVal, kBottomMargin) 
                     forWidth:62 
                     withFont:[self defaultSmallFont] 
                lineBreakMode:UILineBreakModeTailTruncation];  
    
    [_octavesLabel drawAtPoint:CGPointMake(octavesXVal , kBottomMargin)
                      forWidth:60
                      withFont:[self defaultSmallFont]
                 lineBreakMode:UILineBreakModeTailTruncation];
    

}

@end
