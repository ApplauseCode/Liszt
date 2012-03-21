//
//  NSString+Number.h
//  MusicLog
//
//  Created by Kyle Rosenbluth on 11/16/11.
//  Copyright (c) 2011 __Applause Code__. All rights reserved.
//

#import <Foundation/Foundation.h>
BOOL doubleNumber(int x);

@interface NSString (Number)
+ (NSString *)stringWithInt:(int)n;
+ (NSString *)timeStringFromInt:(int)seconds;

@end
