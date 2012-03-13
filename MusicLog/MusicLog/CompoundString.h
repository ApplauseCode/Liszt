//
//  CompoundString.h
//  Liszt
//
//  Created by Jeffrey Rosenbluth on 3/12/12.
//  Copyright (c) 2012 Applause Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompoundString : NSObject

@property (nonatomic, strong) NSMutableArray *strings;
@property (nonatomic, strong) NSMutableArray *fonts;
@property (nonatomic, strong) NSMutableArray *kerns;
@property (nonatomic, strong) NSMutableArray *base;

- (void)drawAtPoint:(CGPoint) point;

@end
