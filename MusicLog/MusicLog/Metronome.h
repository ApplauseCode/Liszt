//
//  Metronome.h
//  Liszt
//
//  Created by Kyle Rosenbluth on 12/28/11.
//  Copyright (c) 2011 __Applause Code__. All rights reserved.
//

#import <Foundation/Foundation.h>
double chooseBPM(double bpm);

@protocol MetronomeDelegate;
@interface Metronome : NSObject
@property (nonatomic, weak) id <MetronomeDelegate> delegate;
@property (nonatomic) BOOL isPlaying;
- (void)startMetronomeWithTempo:(int)t;
- (void)changeTempoWithTempo:(int)t;

@end

@protocol MetronomeDelegate <NSObject>

@optional
- (void)metronomeWillStartWithInterval:(CGFloat)interval;
- (void)metronomeDidStartWithInterval:(CGFloat)interval;

@end

