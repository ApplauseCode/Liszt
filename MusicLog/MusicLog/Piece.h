//
//  Piece.h
//  MusicLog
//
//  Created by Kyle Rosenbluth on 11/3/11.
//  Copyright (c) 2011 __Applause Code__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"
@class Timer;
@class CompoundString;

@interface Piece : NSObject <NSMutableCopying, NSCoding>
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *composer;
@property BOOL major;
@property int tempo;
@property pieceTonicType pieceKey;
@property double pieceTime;
@property (nonatomic, strong) NSDate *startPieceDate;
- (int)updateElapsedTime:(NSDate *)d;
- (void)resetStartTime;

- (CompoundString *)keyCompoundString;


@end
