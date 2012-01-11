//
//  Timer.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 9/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Timer.h"
#import "Common.h"
BOOL doubleDigit(int x)
{
    if (x > 9)
        return YES;
    else
        return NO;
}

@interface Timer ()
{
    NSTimer *timer;
    int seconds;
    int minutes;
    int hours;
    int counter;
}
- (void)timerFireMethod:(NSTimer *)theTimer;
- (void)timerHandling:(id)sender;

@end
@implementation Timer
@synthesize elapsedTime, timeLabel, timeButton, isTiming;

- (id)initWithElapsedTime:(int)time
{
    self = [super init];
    if (self)
    {
        [self changeTimeTo:time];
        isTiming = NO;
    }
    return self;
}

- (void)changeTimeTo:(int)time
{
    int remainder;
    hours =  time / 3600;
    remainder = time % 3600;
    minutes = remainder / 60;
    seconds = remainder % 60;
    elapsedTime = time;
}

- (id)initWithLabel:(UILabel *)label
{
    self = [super init];
    if (self)
    {
        timeLabel = label;
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setTimeLabel:(UILabel *)label
{
    timeLabel = label;
    [timeLabel setText:[self timeString]];
    
}

- (void)setTimeButton:(UIButton *)button
{
    timeButton = button;
    [timeButton addTarget:self action:@selector(timerHandling:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)timerHandling:(id)sender
{
    if ([[timeButton currentTitle] isEqual:@"Start"])   
    {
        [self startTimer];
        [timeButton setTitle:@"Stop" forState:UIControlStateNormal];       
    } 
    else if ([[timeButton currentTitle] isEqual:@"Stop"]) 
    {
        [self stopTimer];
        [timeButton setTitle:@"Start" forState:UIControlStateNormal];
    }

}

- (void)startTimer
{
    if (counter < 1)
    {
        isTiming = YES;
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
        [runLoop addTimer:timer forMode:NSRunLoopCommonModes];
        [runLoop addTimer:timer forMode:UITrackingRunLoopMode];
    }
    counter ++;
}

- (void)timerFireMethod:(NSTimer *)theTimer
{
    seconds += 1;
    if ((seconds % 60) == 0)
    {
        minutes++;
        seconds = 0;
    }
    if (((minutes % 60) == 0) && (minutes > 0))
    {
        hours++;
        minutes = 0;
    }
    [timeLabel setText:[self timeString]];
}

- (void)stopTimer
{
    isTiming = NO;
    [timer invalidate];
    elapsedTime = (hours * 3600) + (minutes * 60) + seconds;
    counter --;
}

- (void)resetTimer
{
    isTiming = NO;
    [timer invalidate];
    elapsedTime = 0;
    hours = 0;
    minutes = 0;
    seconds = 0;
    counter --;
}

- (void)disconnectTimers
{
    self.timeButton = nil;
}

- (NSString *)timeString
{
    NSString *blankSeconds;
    NSString *blankMinutes;
    NSString *blankHours;
    blankSeconds = doubleDigit(seconds) ? @"" : @"0";
    blankMinutes = doubleDigit(minutes) ? @"" : @"0";
    blankHours = doubleDigit(hours) ? @"" : @"0";
    
    return [NSString stringWithFormat:@"%@%i:%@%i:%@%i", blankHours, hours, blankMinutes, minutes, blankSeconds, seconds];
}
@end
