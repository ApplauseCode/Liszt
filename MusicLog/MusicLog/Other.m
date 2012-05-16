//
//  Other.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Other.h"
#import "CompoundString.h"

@implementation Other
@synthesize title;
@synthesize subTitle;
@synthesize otherDescription;
@synthesize otherTime;
@synthesize startOtherDate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    [self setTitle:[aDecoder decodeObjectForKey:@"title"]];
    [self setSubTitle:[aDecoder decodeObjectForKey:@"subTitle"]];
    [self setOtherDescription:[aDecoder decodeObjectForKey:@"otherDescription"]];
    [self setOtherTime:[aDecoder decodeIntegerForKey:@"otherTime"]];
    return self;
}

- (void)setTheTime: (double) t {
    self.otherTime = t;
}

- (int)updateElapsedTime:(NSDate *)d
{
    double time;
    time = self.otherTime;
    self.otherTime = time + [d timeIntervalSince1970] - [startOtherDate timeIntervalSince1970];
    self.startOtherDate = d;
    return otherTime;
}

- (void)resetStartTime
{
    self.startOtherDate = [NSDate date];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    Other *copy = [[Other alloc] init];
    [copy setTitle:title];
    [copy setSubTitle:subTitle];
    [copy setOtherDescription:otherDescription];
    [copy setOtherTime:otherTime];
    return copy;
}

- (NSUInteger)hash
{
    /*NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [title intValue];
    result = prime * result + [subTitle intValue];
    result = prime * result + [otherDescription intValue];
    result = prime * result + otherTime;*/
    
    // The amount of objects in set are small enough that we can put them all in the same bucket
    return 0;
}

- (BOOL)isEqual:(Other *)object
{
    if (([title isEqualToString:[object title]])
        && ([subTitle isEqualToString:[object subTitle]])
        && ([otherDescription isEqualToString:[object otherDescription]])
        && (otherTime == [object otherTime]))
        return YES;
    else 
        return NO;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:title forKey:@"title"];
    [aCoder encodeObject:subTitle forKey:@"subTitle"];
    [aCoder encodeObject:otherDescription forKey:@"otherDescription"];
    [aCoder encodeInteger:otherTime forKey:@"otherTime"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self setOtherTime:++otherTime];
}

@end
