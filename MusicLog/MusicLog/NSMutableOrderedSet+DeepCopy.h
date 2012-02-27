//
//  NSMutableOrderedSet+DeepCopy.h
//  Liszt
//
//  Created by Kyle Rosenbluth on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableOrderedSet (DeepCopy)

- (NSMutableOrderedSet *)deepCopy;

+ (NSMutableOrderedSet *)fromMutableOrderedSet:(NSMutableOrderedSet *)set;

@end
