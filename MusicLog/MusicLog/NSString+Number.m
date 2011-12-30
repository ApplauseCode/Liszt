//
//  NSString+Number.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+Number.h"

BOOL doubleNumber(int x)
{
    if (x > 9)
        return YES;
    else
        return NO;
}


@implementation NSString (Number)

+ (NSString *)stringWithInt:(int)n
{
    return [NSString stringWithFormat:@"%i", n];
}

+ (NSString *)TimeStringFromInt:(int)seconds
{
    int hours, minutes, remainder;
    hours =  seconds / 3600;
    remainder = seconds % 3600;
    minutes = remainder / 60;
    seconds = remainder % 60;
    
    NSString *blankSeconds;
    NSString *blankMinutes;
    NSString *blankHours;
    blankSeconds = doubleNumber(seconds) ? @"" : @"0";
    blankMinutes = doubleNumber(minutes) ? @"" : @"0";
    blankHours = doubleNumber(hours) ? @"" : @"0";
    
    return [NSString stringWithFormat:@"%@%i:%@%i:%@%i", blankHours, hours, blankMinutes, minutes, blankSeconds, seconds];    
}

@end
