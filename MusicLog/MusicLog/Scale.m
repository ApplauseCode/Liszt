//
//  PracticedLog.m
//  PianoLog
//
//  Created by Kyle Rosenbluth on 8/7/11.
//  Copyright 2011 __Applause Code__. All rights reserved.
//

#import "Scale.h"
#import "NSString+Number.h"
#import "CompoundString.h"

@implementation Scale

@synthesize tonic;
@synthesize scaleMode;
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
    [self setScaleMode:[aDecoder decodeIntForKey:@"mode"]];
    [self setTempo:[aDecoder decodeIntForKey:@"tempo"]];
    [self setRhythm:[aDecoder decodeIntForKey:@"rhythm"]];
    [self setOctaves:[aDecoder decodeIntForKey:@"octaves"]];
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\nTonic: %i. Type: %i. \nSpeed: %i. Rhythm: %i. Octaves: %i." , tonic, scaleMode, tempo, rhythm, octaves];
}

- (CompoundString *)tonicCompoundString
{
    CompoundString *result = [[CompoundString alloc] init];
    UIFont *defaultFont = [UIFont fontWithName:@"ACaslonPro-Regular" size:18];
    UIFont *accidentalFont = [UIFont fontWithName:@"ACaslonPro-Regular" size:15];
    NSMutableArray *s;
    NSMutableArray *f = [NSMutableArray arrayWithObjects:defaultFont, accidentalFont, defaultFont, accidentalFont, nil];
    NSNumber *zero = [NSNumber numberWithFloat:0.0];
    NSNumber *adj = [NSNumber numberWithFloat:-4.0];
    NSNumber *badj = [NSNumber numberWithFloat:-2.0];
    NSMutableArray *k = [NSMutableArray arrayWithObjects:zero, zero, adj, zero, nil];
    NSMutableArray *b = [NSMutableArray arrayWithObjects:zero, badj, zero, badj, nil];

    switch (tonic) {
        case 0:
        case 1:
        case 2:
            s = [NSMutableArray arrayWithObject:@""];
             break;
        case 3:
             s = [NSMutableArray arrayWithObject:@"C"];
             break;
        case 4:
            s = [NSMutableArray arrayWithObjects:@"C",@"\u266f",@"/ D",@"\u266d",nil];
            break;
        case 5:
            s = [NSMutableArray arrayWithObject:@"D"];
            break;
        case 6:
            s = [NSMutableArray arrayWithObjects:@"D",@"\u266f",@"/ E",@"\u266d",nil];
            break;
        case 7:
            s = [NSMutableArray arrayWithObject:@"E"];
            break;
        case 8:
            s = [NSMutableArray arrayWithObject:@"F"];
            break;
        case 9:
            s = [NSMutableArray arrayWithObjects:@"F",@"\u266f",@"/ G",@"\u266d",nil];
            break;
        case 10:
            s = [NSMutableArray arrayWithObject:@"G"];
            break;
        case 11:
            s = [NSMutableArray arrayWithObjects:@"G",@"\u266f",@"/ A",@"\u266d",nil];
            break;
        case 12:
            s = [NSMutableArray arrayWithObject:@"A"];
            break;
        case 13:
            s = [NSMutableArray arrayWithObjects:@"A",@"\u266f",@"/ B",@"\u266d",nil];
            break;
        case 14:
            s = [NSMutableArray arrayWithObject:@"B"];
            break;
        default:
             break;
    }
    [result setFonts:f];
    [result setKerns:k];
    [result setBase:b];
    if ((scaleMode > 0 && scaleMode < 4) || (scaleMode == 5 || scaleMode > 7)) {
        [s replaceObjectAtIndex:0 withObject:[[s objectAtIndex:0] lowercaseString]];   
        if ([s count] > 3) {
            [s replaceObjectAtIndex:2 withObject:[[s objectAtIndex:2] lowercaseString]];
        }
    }
    [result setStrings:s];
    return  result;
}

- (NSString *)modeString
{
    // display the typedef in proper string form on screen
    NSArray *modeArray = [NSArray arrayWithObjects:@"Major", @"Natural", @"Melodic", @"Harmonic", @"Major", @"Minor", @"Major 7", @"Dom 7", @"Min 7", @"Half Dim 7", @"Dim 7", nil];
    
    return [modeArray objectAtIndex:scaleMode];
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
    return tempo == 0 ? @"none" : [NSString stringWithInt:tempo]; 
} 

- (id)mutableCopyWithZone:(NSZone *)zone
{
    Scale *copy = [[Scale alloc] init];//[[self class] allocWithZone:zone];
    [copy setTonic:tonic];
    [copy setScaleMode:scaleMode];
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
    result = prime * result + scaleMode;
    result = prime * result + rhythm;
    result = prime * result + octaves;
    result = prime * result + tempo;
    
    return result;
}

- (BOOL)isEqual:(Scale *)object
{
    if ((tonic == [object tonic])
        && (scaleMode == [object scaleMode])
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
    [aCoder encodeInt:scaleMode forKey:@"mode"];
    [aCoder encodeInt:tempo forKey:@"tempo"];
    [aCoder encodeInt:rhythm forKey:@"rhythm"];
    [aCoder encodeInt:octaves forKey:@"octaves"];
}

@end