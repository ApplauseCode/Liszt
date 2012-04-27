//
//  Piece.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 11/3/11.
//  Copyright (c) 2011 __Applause Code__. All rights reserved.
//

#import "Piece.h"
#import "CompoundString.h"


@implementation Piece
@synthesize title;
@synthesize composer;
@synthesize major;
@synthesize tempo;
@synthesize pieceKey;
@synthesize pieceTime;
@synthesize startPieceDate;

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

- (int)updateElapsedTime:(NSDate *)d
{
    double time;
    time = self.pieceTime;
    self.pieceTime = time + [d timeIntervalSince1970] - [startPieceDate timeIntervalSince1970];
    self.startPieceDate = d;
    return pieceTime;

}

- (void)resetStartTime
{
    self.startPieceDate = [NSDate date];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    Piece *copy = [[Piece alloc] init];
    [copy setTitle:title];
    [copy setComposer:composer];
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
    result = prime * result + major;
    result = prime * result + tempo;
    result = prime * result + pieceKey;
    result = prime * result + pieceTime;
    return 0;
}

- (BOOL)isEqual:(Piece *)object
{
    if (([title isEqualToString:[object title]])
        && ([composer isEqualToString:[object composer]])
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

- (CompoundString *)keyCompoundString
{
    CompoundString *result = [[CompoundString alloc] init];
    UIFont *defaultFont = [UIFont fontWithName:@"ACaslonPro-Regular" size:18];
    UIFont *accidentalFont = [UIFont fontWithName:@"ACaslonPro-Regular" size:15];
    NSMutableArray *s;
    NSMutableArray *f = [NSMutableArray arrayWithObjects:defaultFont, accidentalFont, nil];
    NSNumber *zero = [NSNumber numberWithFloat:0.0];
    NSNumber *adj = [NSNumber numberWithFloat:-2.0];
    NSNumber *badj = [NSNumber numberWithFloat:-1.0];
    NSMutableArray *k = [NSMutableArray arrayWithObjects:adj, zero, nil];
    NSMutableArray *b = [NSMutableArray arrayWithObjects:zero, badj, nil];
    
    switch (pieceKey) {
        case 0:
            s = [NSMutableArray arrayWithObject:@"C"];
            break;
        case 1:
            s = [NSMutableArray arrayWithObjects:@"C",@"\u266f",nil];
            break;
        case 2:
            s = [NSMutableArray arrayWithObjects:@"D",@"\u266d",nil];
            break;
        case 3:
            s = [NSMutableArray arrayWithObject:@"D"];
            break;
        case 4:
            s = [NSMutableArray arrayWithObjects:@"D",@"\u266f",nil];
            break;
        case 5:
            s = [NSMutableArray arrayWithObjects:@"E",@"\u266d",nil];
            break;
        case 6:
            s = [NSMutableArray arrayWithObject:@"E"];
            break;
        case 7:
            s = [NSMutableArray arrayWithObject:@"F"];
            break;
        case 8:
            s = [NSMutableArray arrayWithObjects:@"F",@"\u266f",nil];
            break;
        case 9:
            s = [NSMutableArray arrayWithObjects:@"G",@"\u266d",nil];
            break;
        case 10:
            s = [NSMutableArray arrayWithObject:@"G"];
            break;
        case 11:
            s = [NSMutableArray arrayWithObjects:@"G",@"\u266f",nil];
            break;
        case 12:
            s = [NSMutableArray arrayWithObjects:@"A",@"\u266d",nil];
            break;
        case 13:
            s = [NSMutableArray arrayWithObject:@"A"];
            break;
        case 14:
            s = [NSMutableArray arrayWithObjects:@"A",@"\u266f",nil];
            break;
        case 15:
            s = [NSMutableArray arrayWithObjects:@"B",@"\u266d",nil];
            break;
        case 16:
            s = [NSMutableArray arrayWithObject:@"B"];
            break;
        default:
            break;
    }
    [result setFonts:f];
    [result setKerns:k];
    [result setBase:b];
    if (!major) 
        [s replaceObjectAtIndex:0 withObject:[[s objectAtIndex:0] lowercaseString]];   
    [result setStrings:s];
    return  result;
 
}

@end
