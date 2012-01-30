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
@synthesize opus;
@synthesize major;
@synthesize tempo;
@synthesize pieceKey;
@synthesize timer;
@synthesize pieceTime;

- (id)init
{
    self = [super init];
    if (self) {
        self.timer = [[Timer alloc] initWithElapsedTime:0.0];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    [self setTitle:[aDecoder decodeObjectForKey:@"title"]];
    [self setComposer:[aDecoder decodeObjectForKey:@"composer"]];
    [self setOpus:[aDecoder decodeIntForKey:@"opus"]];
    [self setTempo:[aDecoder decodeIntForKey:@"pieceTempo"]];
    [self setMajor:[aDecoder decodeBoolForKey:@"major"]];
    [self setPieceKey:[aDecoder decodeIntForKey:@"key"]];
    [self setPieceTime:[aDecoder decodeIntForKey:@"time"]];
    
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    Piece *copy = [[self class] allocWithZone:zone];
    [copy setTitle:title];
    [copy setComposer:composer];
    [copy setOpus:opus];
    [copy setMajor:major];
    [copy setTempo:tempo];
    [copy setPieceKey:pieceKey];
    [copy setPieceTime:pieceTime];
    return copy;
}

- (NSUInteger)hash
{
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [title intValue];
    result = prime * result + [composer intValue];
    result = prime * result + opus;
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
        && (opus == [object opus])
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
    [aCoder encodeInt:opus forKey:@"opus"];
    [aCoder encodeInt:pieceKey forKey:@"key"];
    [aCoder encodeInt:pieceTime forKey:@"time"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Title: %@ Composer: %@ Tempo: %i Major: %i Opus: %i", [self title], [self composer], [self tempo], [self major], [self opus]];
}

- (NSString *)keyString
{
    // display the typedef in proper string form on screen
    NSArray *keysArray = [NSArray arrayWithObjects:@"C",@"C Sharp/D Flat",@"D",@"D Sharp/E Flat",@"E",@"F",@"F Sharp/G Flat",@"G",@"G Sharp/A Flat",@"A",@"A Sharp/B Flat",@"B", nil];
    
    return [keysArray objectAtIndex:pieceKey];
}

@end
