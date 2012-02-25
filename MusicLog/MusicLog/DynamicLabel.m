//
//  DynamicLabel.m
//  KayVeeO
//
//  Created by Jeffrey Rosenbluth on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DynamicLabel.h"
#import "NSString+Number.h"

@implementation DynamicLabel

@synthesize seconds;

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    int time = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
    [self setText:[NSString timeStringFromInt:time]];
}

@end
