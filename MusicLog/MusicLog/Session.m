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

- (id)initWithScales:(NSMutableOrderedSet *)scaleSet
           arpeggios:(NSMutableOrderedSet *)arpeggioSet
              pieces:(NSMutableOrderedSet *)pieceSet
{
    self = [super init];
    if (self) {
        
        [self setScaleSession:[[NSMutableOrderedSet alloc] initWithOrderedSet:scaleSet]];
        [self setArpeggioSession:[[NSMutableOrderedSet alloc] initWithOrderedSet:arpeggioSet]];
        [self setPieceSession:[[NSMutableOrderedSet alloc] initWithOrderedSet:pieceSet]];
        [self setDate:[NSDate date]];
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

- (id)copyWithZone:(NSZone *)zone
{
    Session *copy = [[Session alloc] init];
    [copy setScaleSession:[[self scaleSession] copy]];
    [copy setScaleTime:[self scaleTime]];
    [copy setArpeggioTime:[self arpeggioTime]];
    [copy setArpeggioSession:[[self arpeggioSession] copy]];
    [copy setPieceSession:[[self pieceSession] copy]];
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
