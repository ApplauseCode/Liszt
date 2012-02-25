//
//  Piece.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Piece.h"
#import "Timer.h"

@implementation Piece
@synthesize title;
@synthesize composer;
@synthesize major;
@synthesize tempo;
@synthesize pieceKey;
//@synthesize timer;
@synthesize pieceTime;

- (id)init
{
    self = [super init];
    if (self) {
//        self.timer = [[Timer alloc] initWithElapsedTime:pieceTime];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    [self setTitle:[aDecoder decodeObjectForKey:@"title"]];
    [self setComposer:[aDecoder decodeObjectForKey:@"composer"]];
    [self setTempo:[aDecoder decodeIntForKey:@"pieceTempo"]];
    [self setMajor:[aDecoder decodeBoolForKey:@"major"]];
    [self setPieceKey:[aDecoder decodeIntForKey:@"key"]];
    [self setPieceTime:[aDecoder decodeIntForKey:@"time"]];
    
    
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    Piece *copy = [[Piece alloc] init];//[[self class] allocWithZone:zone];
    [copy setTitle:title];
    [copy setComposer:composer];
    [copy setMajor:major];
    [copy setTempo:tempo];
    [copy setPieceKey:pieceKey];
    [copy setPieceTime:pieceTime];
//    [copy setTimer:[[Timer alloc] initWithElapsedTime:pieceTime]];
    return copy;
}

- (NSUInteger)hash
{
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [title intValue];
    result = prime * result + [composer intValue];
    result = prime * result + major;
    result = prime * result + tempo;
    result = prime * result + pieceKey;
    result = prime * result + pieceTime;
    return result;
}

- (BOOL)isEqual:(Piece *)object
{
    if ((title == [object title])
        && (composer == [object composer])
        && (major == [object major])
        && (tempo == [object tempo])
        && (pieceKey == [object pieceKey])
        && (pieceTime == [object pieceTime]))
        return YES;
    else 
        return NO;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:title forKey:@"title"];
    [aCoder encodeObject:composer forKey:@"composer"];
    [aCoder encodeInt:tempo forKey:@"pieceTempo"];
    [aCoder encodeBool:major forKey:@"major"];
    [aCoder encodeInt:pieceKey forKey:@"key"];
    [aCoder encodeInt:pieceTime forKey:@"time"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self setPieceTime:++pieceTime];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Title: %@ Composer: %@ Tempo: %i Major: %i", [self title], [self composer], [self tempo], [self major]];
}

- (NSString *)keyString
{
    // display the typedef in proper string form on screen
    NSArray *keysArray = [NSArray arrayWithObjects:@"C",@"C Sharp/D Flat",@"D",@"D Sharp/E Flat",@"E",@"F",@"F Sharp/G Flat",@"G",@"G Sharp/A Flat",@"A",@"A Sharp/B Flat",@"B", nil];
    
    return [keysArray objectAtIndex:pieceKey];
}

@end
