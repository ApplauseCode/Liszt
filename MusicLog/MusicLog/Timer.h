//
//  Timer.h
//  MusicLog
//
//  Created by Kyle Rosenbluth on 9/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
BOOL doubleDigit(int x);
@interface Timer : NSObject

@property (nonatomic, /*readonly*/) int elapsedTime;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic) BOOL isTiming;


- (id)initWithElapsedTime:(int)time;
- (void)startTimer;
- (void)stopTimer;
- (void)resetTimer;
- (void)changeTimeTo:(int)time;

@end
