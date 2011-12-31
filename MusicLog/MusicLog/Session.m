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
@synthesize pieceSession/*,       pieceTime*/;
@synthesize date;

- (id)initWithDayOffset:(int)n
{
    self = [super init];
    scaleSession = nil;
    arpeggioSession = nil;
    pieceSession = nil;
    //[self setDate:[NSDate date]];
    // ***** TEMPORARY DATE SET FOR DEBBUGING
    static int d = -1;
    [self setDate:[Session getForDays:d fromDate:[NSDate date]]];
    d-=n;
    // ***** END TEMP
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    Session *copy = [[Session alloc] initWithDayOffset:0];
    [copy setScaleSession:[[self scaleSession] copy]];
    [copy setScaleTime:[self scaleTime]];
    [copy setArpeggioTime:[self arpeggioTime]];
    //[copy setPieceTime:[self pieceTime]];
    [copy setArpeggioSession:[[self arpeggioSession] copy]];
    [copy setPieceSession:[[self pieceSession] copy]];
    return copy;
}

//REMOVE LATER
+ (NSDate *)getForDays:(int)days fromDate:(NSDate *)date
{
    NSDateComponents *components= [[NSDateComponents alloc] init];
    [components setDay:days];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:components toDate:date options:0];
}
//END REMOVE

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    [self setScaleSession:[aDecoder decodeObjectForKey:@"scaleSession"]];
    [self setScaleTime:[aDecoder decodeIntForKey:@"scaleTime"]];
    [self setArpeggioTime:[aDecoder decodeIntForKey:@"arpeggioTime"]];
    //[self setPieceTime:[aDecoder decodeIntForKey:@"pieceTime"]];
    [self setArpeggioSession:[aDecoder decodeObjectForKey:@"arpeggioSession"]];
    [self setPieceSession:[aDecoder decodeObjectForKey:@"pieceSession"]];
    [self setDate:[aDecoder decodeObjectForKey:@"date"]];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   // NSLog(@"Piece Time %i", pieceTime);
    [aCoder encodeObject:scaleSession forKey:@"scaleSession"];
    NSLog(@"Scale Time %i",scaleTime);
    [aCoder encodeInt:scaleTime forKey:@"scaleTime"];
    [aCoder encodeInt:arpeggioTime forKey:@"arpeggioTime"];
    //[aCoder encodeInt:pieceTime forKey:@"pieceTime"];
    [aCoder encodeObject:arpeggioSession forKey:@"arpeggioSession"];
    [aCoder encodeObject:pieceSession forKey:@"pieceSession"];
    [aCoder encodeObject:date forKey:@"date"];
}

- (NSString *)description
{    
    return [NSString stringWithFormat:@"Scales: %@ \nArpeggios: %@ \nPieces: %@ \nScaleTime: %i \nArpeggioTime: %i \nDate: %@", scaleSession, arpeggioSession, pieceSession, scaleTime, arpeggioTime, date];
}

@end
