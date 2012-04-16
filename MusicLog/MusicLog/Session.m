//
//  Session.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 9/22/11.
//  Copyright (c) 2011 __Applause Code__. All rights reserved.
//

#import "Session.h"
#import "NSMutableOrderedSet+DeepCopy.h"
#import "Piece.h"
#import "Other.h"

@implementation Session

@synthesize scaleSession,       scaleTime,      sessionNotes;
@synthesize date,               startScaleDate, startArpeggioDate;
@synthesize arpeggioSession,    arpeggioTime;
@synthesize pieceSession;

- (id)initWithScales:(NSMutableOrderedSet *)scaleSet
           arpeggios:(NSMutableOrderedSet *)arpeggioSet
              pieces:(NSMutableOrderedSet *)pieceSet
{
    self = [super init];
    if (self) {
        if (!scaleSet)
            [self setScaleSession:[[NSMutableOrderedSet alloc] init]];
        else
            [self setScaleSession:scaleSet];
        if (!arpeggioSet)
            [self setArpeggioSession:[[NSMutableOrderedSet alloc] init]];
        else
            [self setArpeggioSession:arpeggioSet];
        if (!pieceSet)
            [self setPieceSession:[[NSMutableOrderedSet alloc] init]];
        else
            [self setPieceSession:pieceSet];

        [self setDate:[NSDate date]];
    }
    return self;
}

- (id)init
{
    return [self initWithScales:nil arpeggios:nil pieces:nil];
}

- (void) resetStartTime:(NSInteger)idx
{
    if (idx) {
        startArpeggioDate = [NSDate date];
    }
    else {
        startScaleDate = [NSDate date];
    }
}

- (int)updateElapsedTime:(NSDate *)d forIndex:(NSInteger)idx
{
    double time;
    switch (idx) {
        case 0:
            time = self.scaleTime;
            self.scaleTime = time + [d timeIntervalSince1970] - [startScaleDate timeIntervalSince1970];
            self.startScaleDate = d;
            return scaleTime;
            break;
        case 1:
            time = self.arpeggioTime;
            self.arpeggioTime = time + [d timeIntervalSince1970] - [startArpeggioDate timeIntervalSince1970];
            self.startArpeggioDate = d;
            return arpeggioTime;
            break;
        default:
            NSLog(@"idx must be 0 (scale) or 1 (arpeggio)");
            break;
    }
    return 0; // To keep compiler from compaining.
}

- (NSInteger)calculateTotalTime
{
    NSInteger total = 0;
    
    total += [self scaleTime];
    total += [self arpeggioTime];
    for (id item in [self pieceSession])
    {
        if ([item isKindOfClass:[Piece class]])
            total += [item pieceTime];
        else 
            total += [item otherTime];
    }
    return total;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    Session *copy = [[Session alloc] init];
    if ([[self scaleSession] respondsToSelector:@selector(addObject:)])
        [copy setScaleSession:[[self scaleSession] deepCopy]];
    else
    {
        [copy setScaleSession:[NSMutableOrderedSet fromOrderedSet:[self scaleSession]]];
    }
    if ([[self arpeggioSession] respondsToSelector:@selector(addObject:)])
        [copy setArpeggioSession:[[self arpeggioSession] deepCopy]];
    else
    {
        [copy setArpeggioSession:[NSMutableOrderedSet fromOrderedSet:[self arpeggioSession]]];
    }
    if ([[self pieceSession] respondsToSelector:@selector(addObject:)])
        [copy setPieceSession:[[self pieceSession] deepCopy]];
    else
    {
        [copy setPieceSession:[NSMutableOrderedSet fromOrderedSet:[self pieceSession]]];
    }
    [copy setScaleTime:[self scaleTime]];
    [copy setArpeggioTime:[self arpeggioTime]];
    [copy setDate:[NSDate dateWithTimeInterval:0 sinceDate:[self date]]];
    [copy setSessionNotes:[self sessionNotes]];
    return copy;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    [self setScaleSession:[aDecoder decodeObjectForKey:@"scaleSession"]];
    [self setScaleTime:[aDecoder decodeIntForKey:@"scaleTime"]];
    [self setArpeggioTime:[aDecoder decodeIntForKey:@"arpeggioTime"]];
    [self setArpeggioSession:[aDecoder decodeObjectForKey:@"arpeggioSession"]];
    [self setPieceSession:[aDecoder decodeObjectForKey:@"pieceSession"]];
    [self setSessionNotes:[aDecoder decodeObjectForKey:@"sessionNotes"]];
    [self setDate:[aDecoder decodeObjectForKey:@"date"]];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:scaleSession forKey:@"scaleSession"];
    [aCoder encodeInt:scaleTime forKey:@"scaleTime"];
    [aCoder encodeInt:arpeggioTime forKey:@"arpeggioTime"];
    [aCoder encodeObject:arpeggioSession forKey:@"arpeggioSession"];
    [aCoder encodeObject:pieceSession forKey:@"pieceSession"];
    [aCoder encodeObject:sessionNotes forKey:@"sessionNotes"];
    [aCoder encodeObject:date forKey:@"date"];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([(__bridge NSString *)context isEqualToString:@"scaleTime"])
        [self setScaleTime:++scaleTime];
    else
        [self setArpeggioTime:++arpeggioTime];
}

- (NSString *)description
{    
    return [NSString stringWithFormat:@"Scales: %@ \nArpeggios: %@ \nPieces: %@ \nScaleTime: %i \nArpeggioTime: %i \nDate: %@", scaleSession, arpeggioSession, pieceSession, scaleTime, arpeggioTime, date];
}

@end
