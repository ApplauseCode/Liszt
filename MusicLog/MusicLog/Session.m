//
//  Session.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 9/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Session.h"

@implementation Session

@synthesize scaleSession,       scaleTime;
@synthesize arpeggioSession,    arpeggioTime;
@synthesize pieceSession;
@synthesize date;

- (id)initWithScales:(NSOrderedSet *)scaleSet
           arpeggios:(NSOrderedSet *)arpeggioSet
              pieces:(NSOrderedSet *)pieceSet
{
    self = [super init];
    if (self) {
        [self setScaleSession:[[NSMutableOrderedSet alloc] initWithOrderedSet:scaleSet copyItems:YES]];
        [self setArpeggioSession:[[NSMutableOrderedSet alloc] initWithOrderedSet:arpeggioSet copyItems:YES]];
        [self setPieceSession:[[NSMutableOrderedSet alloc] initWithOrderedSet:pieceSet copyItems:YES]];
        [self setDate:[NSDate date]];
        if ([scaleSession respondsToSelector:@selector(addObject:)])
            NSLog(@"It's Mutable!");
    }
    return self;
}

- (id)init
{
    return [self initWithScales:nil arpeggios:nil pieces:nil];
    //    self = [super init];
    //    if (self ) {
    //        scaleSession = nil;
    //        arpeggioSession = nil;
    //        pieceSession = nil;
    //        [self setDate:[NSDate date]];
    //    }
    //    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    Session *copy = [[Session alloc] init];
    [copy setScaleSession:[[self scaleSession] mutableCopy]];
    [copy setScaleTime:[self scaleTime]];
    [copy setArpeggioTime:[self arpeggioTime]];
    [copy setArpeggioSession:[[self arpeggioSession] mutableCopy]];
    [copy setPieceSession:[[self pieceSession] mutableCopy]];
    [copy setDate:[NSDate dateWithTimeInterval:0 sinceDate:[self date]]];
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
    [aCoder encodeObject:date forKey:@"date"];
}

- (NSString *)description
{    
    return [NSString stringWithFormat:@"Scales: %@ \nArpeggios: %@ \nPieces: %@ \nScaleTime: %i \nArpeggioTime: %i \nDate: %@", scaleSession, arpeggioSession, pieceSession, scaleTime, arpeggioTime, date];
}

@end
