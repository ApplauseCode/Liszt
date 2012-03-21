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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
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
    if (_speedLabel != [NSString stringWithFormat:@"%@ bpm", speed]) {
        _speedLabel = [NSString stringWithFormat:@"%@ bpm", speed];
    } 
    _tonicCompoundString = [scale tonicCompoundString];
    [self setNeedsDisplay];
}

- (void)drawContentView:(CGRect)r
{
    [super drawContentView:r];
    [_tonicCompoundString drawAtPoint:CGPointMake(kLeftMargin, kTopMargin)];
    [_speedLabel drawAtPoint:CGPointMake(kLeftMargin, kBottomMargin) 
                    forWidth:200 
                    withFont:[self defaultSmallFont] 
               lineBreakMode:UILineBreakModeTailTruncation];    
    [_rhythmLabel drawAtPoint:CGPointMake(kRightMargin, kBottomMargin) 
                     forWidth:62 
                     withFont:[self defaultSmallFont] 
                lineBreakMode:UILineBreakModeTailTruncation];    
    [_modeLabel drawAtPoint:CGPointMake(kRightMargin, kTopMargin)
                   forWidth:135
                   withFont:[self defaultLargeFont]
              lineBreakMode:UILineBreakModeTailTruncation];    
    NSInteger octavesXCoord = kRightMargin + [_rhythmLabel sizeWithFont:[self defaultSmallFont]].width + 10;
    
    NSInteger octavesFinisherXCoord = octavesXCoord + [_octavesLabel sizeWithFont:[self defaultVerySmallFont]].width + 6;
    
    [_octavesLabel drawAtPoint:CGPointMake(octavesXCoord , kBottomMargin)
                      forWidth:60
                      withFont:[self defaultSmallFont]
                 lineBreakMode:UILineBreakModeTailTruncation];
    
    [[self octaveFinisher] drawAtPoint:CGPointMake(octavesFinisherXCoord, kBottomMargin+2)
                       forWidth:40
                       withFont:[self defaultVerySmallFont]
                  lineBreakMode:UILineBreakModeTailTruncation];
}

@end