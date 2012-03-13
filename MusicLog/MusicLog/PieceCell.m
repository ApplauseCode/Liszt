//
//  PieceCell.m
//  Liszt
//
//  Created by Jeffrey Rosenbluth on 3/12/12.
//  Copyright (c) 2012 Applause Code. All rights reserved.
//

#import "PieceCell.h"
#import "Piece.h"
#import "CompoundString.h"

#define kLeftMargin 40
#define kTopMargin 5
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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)updateLabels:(Piece *)piece
{
    NSString *mode = ([piece major]) ? @"Major" : @"Minor";
    NSString *composer = [piece composer];
    if (_composerLabel != composer) {
        _composerLabel = composer;
    }
    if (_modeLabel != mode) {
        _modeLabel = mode;
    }
    if (_speedLabel != [NSString stringWithFormat:@"%i bpm", [piece tempo]]) {
        _speedLabel = [NSString stringWithFormat:@"%i bpm", [piece tempo]];
    } 
    _keyCompoundString = [piece keyCompoundString];
    [self setNeedsDisplay];
}

- (void)drawContentView:(CGRect)r
{
    [super drawContentView:r];
    [_composerLabel drawAtPoint:CGPointMake(kLeftMargin, kTopMargin)
                       forWidth:260 withFont:[self defaultLargeFont]
                  lineBreakMode:UILineBreakModeTailTruncation];
    [_speedLabel drawAtPoint:CGPointMake(kLeftMargin, kBottomMargin + 2) 
                    forWidth:200 
                    withFont:[self defaultSmallFont] 
               lineBreakMode:UILineBreakModeTailTruncation];
    [_keyCompoundString drawAtPoint:CGPointMake(kRightMargin, kBottomMargin)];
    [_modeLabel drawAtPoint:CGPointMake(kRightMargin + 30, kBottomMargin)
                   forWidth:135
                   withFont:[self defaultLargeFont]
              lineBreakMode:UILineBreakModeTailTruncation];        
}


@end
