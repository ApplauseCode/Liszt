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
@synthesize description;
@synthesize otherTime;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    [self setTitle:[aDecoder decodeObjectForKey:@"title"]];
    [self setSubTitle:[aDecoder decodeObjectForKey:@"subTitle"]];
    [self setDescription:[aDecoder decodeObjectForKey:@"description"]];
    [self setOtherTime:[aDecoder decodeIntegerForKey:@"otherTime"]];
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    Other *copy = [[Other alloc] init];
    [copy setTitle:title];
    [copy setSubTitle:subTitle];
    [copy setDescription:description];
    [copy setOtherTime:otherTime];
    return copy;
}

- (NSUInteger)hash
{
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [title intValue];
    result = prime * result + [subTitle intValue];
    result = prime * result + [description intValue];
    result = prime * result + otherTime;
    return result;
}

- (BOOL)isEqual:(Other *)object
{
    if (([title isEqualToString:[object title]])
        && ([subTitle isEqualToString:[object subTitle]])
        && ([description isEqualToString:[object description]])
        && (otherTime == [object otherTime]))
        return YES;
    else 
        return NO;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:title forKey:@"title"];
    [aCoder encodeObject:subTitle forKey:@"subTitle"];
    [aCoder encodeObject:description forKey:@"description"];
    [aCoder encodeInteger:otherTime forKey:@"otherTime"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self setOtherTime:++otherTime];
}

@end
