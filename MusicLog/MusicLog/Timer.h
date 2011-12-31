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

@property (nonatomic, readonly) int elapsedTime;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *timeButton;

- (id)initWithElapsedTime:(int)time;
- (id)initWithLabel:(UILabel *)label;
- (void)startTimer;
- (void)stopTimer;
- (void)resetTimer;
- (NSString *)timeString;
- (void)disconnectTimers;

@end
