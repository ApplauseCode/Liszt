//
//  PracticedLog.m
//  PianoLog
//
//  Created by Kyle Rosenbluth on 8/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Scale.h"
#import "NSString+Number.h"

@implementation Scale

@synthesize tonic;
@synthesize mode;
@synthesize tempo;
@synthesize rhythm;
@synthesize octaves;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    [self setTonic:[aDecoder decodeIntForKey:@"tonic"]];
    [self setMode:[aDecoder decodeIntForKey:@"mode"]];
    [self setTempo:[aDecoder decodeIntForKey:@"tempo"]];
    [self setRhythm:[aDecoder decodeIntForKey:@"rhythm"]];
    [self setOctaves:[aDecoder decodeIntForKey:@"octaves"]];
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\nTonic: %i. Type: %i. \nSpeed: %i. Rhythm: %i. Octaves: %i." , tonic, mode, tempo, rhythm, octaves];
}

- (NSString *)tonicString
{
    // display the typedef in proper string form on screen
    NSArray *tonicArray = [NSArray arrayWithObjects:@"", @"", @"",@"C",@"D Flat",@"D",@"E Flat",@"E",@"F",@"G Flat",@"G",@"A Flat",@"A",@"B Flat",@"B", nil];
    
    return [tonicArray objectAtIndex:tonic];
}

- (NSString *)modeString
{
    // display the typedef in proper string form on screen
    NSArray *modeArray = [NSArray arrayWithObjects:@"Major", @"Natural Minor", @"Melodic Minor", @"Harmonic Minor", @"Major", @"Minor", @"Major 7", @"Dom 7", @"Min 7", @"Half Dim 7", @"Dim 7", nil];
    
    return [modeArray objectAtIndex:mode];
} 

- (NSString *) rhythmString
{
    // display the typedef in proper string form on screen
    NSArray *rhythmArray = [NSArray arrayWithObjects:@"Whole", @"1/2", @"1/4", @"1/8", @"1/12", @"1/16", @"1/32", @"1/64",@"Bursts", nil];

    return [rhythmArray objectAtIndex:rhythm];
}

- (NSString *)octavesString
{
    return [NSString stringWithInt:octaves];
}

- (NSString *)tempoString
{
    return [NSString stringWithInt:tempo]; 
} 

- (id)mutableCopyWithZone:(NSZone *)zone
{
    Scale *copy = [[Scale alloc] init];//[[self class] allocWithZone:zone];
    [copy setTonic:tonic];
    [copy setMode:mode];
    [copy setTempo:tempo];
    [copy setRhythm:rhythm];
    [copy setOctaves:octaves];
    return copy;
}

- (NSUInteger)hash
{
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + tonic;
    result = prime * result + mode;
    result = prime * result + rhythm;
    result = prime * result + octaves;
    result = prime * result + tempo;
    
    return result;
}

- (BOOL)isEqual:(Scale *)object
{
    if ((tonic == [object tonic])
        && (mode == [object mode])
        && (rhythm == [object rhythm])
        && (octaves == [object octaves])
        && (tempo == [object tempo]))
        return YES;
    else 
        return NO;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:tonic forKey:@"tonic"];
    [aCoder encodeInt:mode forKey:@"mode"];
    [aCoder encodeInt:tempo forKey:@"tempo"];
    [aCoder encodeInt:rhythm forKey:@"rhythm"];
    [aCoder encodeInt:octaves forKey:@"octaves"];
}

@end