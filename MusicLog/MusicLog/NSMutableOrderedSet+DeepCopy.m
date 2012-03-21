//
//  NSMutableOrderedSet+DeepCopy.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 2/25/12.
//  Copyright (c) 2012 __Applause Code__. All rights reserved.
//

#import "NSMutableOrderedSet+DeepCopy.h"

@implementation NSMutableOrderedSet (DeepCopy)

- (NSMutableOrderedSet *)deepCopy
{
    NSMutableOrderedSet *copiedSet = [[NSMutableOrderedSet alloc] init];
    for (id obj in self)
    {
        if ([obj respondsToSelector:@selector(mutableCopy)])
            [copiedSet addObject:[obj mutableCopy]];
        else
            [copiedSet addObject:[obj copy]];
    }
    return copiedSet;
}

+ (NSMutableOrderedSet *)fromOrderedSet:(NSOrderedSet *)set
{
    NSMutableOrderedSet *newSet = [[NSMutableOrderedSet alloc] init];
    for (id obj in set)
        [newSet addObject:obj];
    return newSet;
}

@end
