//
//  Piece.h
//  MusicLog
//
//  Created by Kyle Rosenbluth on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"
@class Timer;

@interface Piece : NSObject <NSMutableCopying, NSCoding>
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *composer;
@property BOOL major;
@property int tempo;
@property tonicType pieceKey;
@property (nonatomic, strong) Timer *timer;
@property int pieceTime;

- (NSString *)keyString;

@end
