//
//  Metronome.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Metronome.h"
#import <AVFoundation/AVFoundation.h>
double chooseBPM(double bpm)
{
    return (60.0 / bpm);
}

@interface Metronome ()
{
    NSTimer *tempoTimer;
}

@property (nonatomic, strong) AVAudioPlayer *tickPlayer;
@property (nonatomic) int tempo;
@property (nonatomic) BOOL isPlaying;
@end

@implementation Metronome
@synthesize tickPlayer;
@synthesize tempo;
@synthesize isPlaying;

- (id)init
{
    self = [super init];
    if (self)
    {
        NSBundle *mainBundle = [NSBundle mainBundle];        
        NSURL *tickURL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"tick5" ofType:@"aif"]];
        tickPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:tickURL error:nil];
        [tickPlayer prepareToPlay];
        [self setIsPlaying:NO];
    }
    return self;
}

- (void)startMetronomeWithTempo:(int)t
{

    tempo = t;
    if (tempoTimer)
    {
        [tempoTimer invalidate];
        tempoTimer = nil;
        [self setIsPlaying:NO];
        return;
    }
    double bpm;
    bpm =  chooseBPM(tempo);
    
    tempoTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:bpm] interval:bpm target:self selector:@selector(tempoTimerFireMethod:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:tempoTimer forMode:NSRunLoopCommonModes];
    [self setIsPlaying:YES];
}

- (void)changeTempoWithTempo:(int)t
{
    if (isPlaying)
    {
        if (tempoTimer)
        {
            [tempoTimer invalidate];
            tempoTimer = nil;
        }
        tempo = t;
        double bpm = chooseBPM(tempo);
        tempoTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:bpm] interval:bpm target:self selector:@selector(tempoTimerFireMethod:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:tempoTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)tempoTimerFireMethod:(NSTimer *)aTimer
{
    [tickPlayer play];
}

@end
