//
//  NSMutableOrderedSet+DeepCopy.h
//  Liszt
//
//  Created by Kyle Rosenbluth on 2/25/12.
//  Copyright (c) 2012 __Applause Code__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableOrderedSet (DeepCopy)

- (NSMutableOrderedSet *)deepCopy;

+ (NSMutableOrderedSet *)fromOrderedSet:(NSOrderedSet *)set;

@end
