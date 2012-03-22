//
//  DynamicLabel.m
//
//  Created by Jeffrey Rosenbluth on 2/19/12.
//  Copyright (c) 2012 __Applause Code__. All rights reserved.
//

#import "DynamicLabel.h"
#import "NSString+Number.h"

@implementation DynamicLabel

@synthesize seconds;
@synthesize timeString;

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    int time = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
    timeString = [NSString timeStringFromInt:time];
    [self setText:timeString];
}

@end
