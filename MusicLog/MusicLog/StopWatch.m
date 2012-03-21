//
//  StopWatch.m
//  KayVeeO
//
//  Created by Jeffrey Rosenbluth on 2/19/12.
//  Copyright (c) 2012 __Applause Code__. All rights reserved.
//

#import "StopWatch.h"
@interface StopWatch ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation StopWatch
@synthesize timer;
@synthesize totalSeconds;

- (id)init
{
    self = [super init];
    if (self) {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(fireAction:) userInfo:nil repeats:YES];
        [runLoop addTimer:timer forMode:NSRunLoopCommonModes];
        [runLoop addTimer:timer forMode:UITrackingRunLoopMode];
    }
    return self;
}

- (void)fireAction:(NSTimer *)aTimer
{
    [self setTotalSeconds:++totalSeconds];
}

@end
