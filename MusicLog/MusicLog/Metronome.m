//
//  Metronome.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 12/28/11.
//  Copyright (c) 2011 __Applause Code__. All rights reserved.
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
@property (nonatomic, assign) int firstTimeTimer;
@property (nonatomic, strong) NSDate *firstDate;
@end

@implementation Metronome
@synthesize tickPlayer;
@synthesize tempo;
@synthesize isPlaying;
@synthesize delegate;
@synthesize firstTimeTimer;
@synthesize firstDate;
//@synthesize mySound;

- (id)init
{
    self = [super init];
    if (self)
    {
        NSBundle *mainBundle = [NSBundle mainBundle];   
        // Use GCD so that startup time isn't delayed
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
        dispatch_async(queue, ^{
            NSURL *tickURL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"tick" ofType:@"caf"]];
            tickPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:tickURL error:nil];
            [tickPlayer prepareToPlay];
            [self setIsPlaying:NO];
        });
        // Keep sound even when phone is muted
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:NULL];
    }
    return self;
}

- (void)startMetronomeWithTempo:(int)t
{
    firstTimeTimer = 0;
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
    
    tempoTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:bpm] interval:1/10 target:self selector:@selector(tempoTimerFireMethod:) userInfo:nil repeats:YES];
    [[self delegate] metronomeWillStartWithInterval:chooseBPM(tempo)];
    firstDate = [NSDate date];
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
        tempoTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:bpm] interval:1/10 target:self selector:@selector(tempoTimerFireMethod:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:tempoTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)tempoTimerFireMethod:(NSTimer *)aTimer
{
    NSTimeInterval interval = -[firstDate timeIntervalSinceNow];
    if (interval >= chooseBPM(tempo))
    {
        [tickPlayer play];
        firstDate = [NSDate date];
        [[self delegate] metronomeDidStartWithInterval:chooseBPM(tempo)];
    }
//    if (firstTimeTimer++ < 1)
//    {
//        [tickPlayer setVolume:0];
//        [[self delegate] metronomeWillStartWithInterval:chooseBPM(tempo)];
//    }
//    else {
//        [tickPlayer setVolume:1];
//        [tickPlayer play];
//        [[self delegate] metronomeDidStartWithInterval:chooseBPM(tempo)];
//    }

}

@end
