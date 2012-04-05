//
//  NSString+Number.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 11/16/11.
//  Copyright (c) 2011 __Applause Code__. All rights reserved.
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

+ (NSString *)timeStringFromInt:(int)seconds
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

+ (NSString *)convertDateToString:(NSDate *)date
{
//    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSDateComponents *components = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
//    NSDate *today = [cal dateFromComponents:components];
//    components = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
//    NSDate *passedInDate = [cal dateFromComponents:components];
    
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:date];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:[NSDate date]];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    if ([difference day] == 0)
        return @"Today";
    else if ([difference day] == 1)
        return @"Yesterday";
    else if ([difference day] < 7)
    {
        [dateFormat setDateFormat:@"EEEE"];
        return [[dateFormat stringFromDate:date] capitalizedString];
    }
    else
    {
        [dateFormat setDateFormat:@"MMM dd, yyyy"];
        return [dateFormat stringFromDate:date];
    }


}

@end
