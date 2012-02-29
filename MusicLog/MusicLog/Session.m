//
//  Session.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 9/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Session.h"
#import "NSMutableOrderedSet+DeepCopy.h"

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
        if ([scaleSet respondsToSelector:@selector(addObject:)])
            NSLog(@"scale set responds to selector");
            
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([(__bridge NSString *)context isEqualToString:@"scales"])
        [self setScaleTime:++scaleTime];
    else
        [self setArpeggioTime:++arpeggioTime];
}

- (NSString *)description
{    
    return [NSString stringWithFormat:@"Scales: %@ \nArpeggios: %@ \nPieces: %@ \nScaleTime: %i \nArpeggioTime: %i \nDate: %@", scaleSession, arpeggioSession, pieceSession, scaleTime, arpeggioTime, date];
}

@end
