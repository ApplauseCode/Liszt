//
//  Metronome.h
//  Liszt
//
//  Created by Kyle Rosenbluth on 12/28/11.
//  Copyright (c) 2011 __Applause Code__. All rights reserved.
//

#import <Foundation/Foundation.h>
double chooseBPM(double bpm);

@interface Metronome : NSObject
- (void)startMetronomeWithTempo:(int)t;
- (void)changeTempoWithTempo:(int)t;

@end

