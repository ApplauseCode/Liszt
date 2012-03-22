//
//  DynamicLabel.h
//
//  Created by Jeffrey Rosenbluth on 2/19/12.
//  Copyright (c) 2012 __Applause Code__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DynamicLabel : UILabel

@property (nonatomic) int seconds;
@property (nonatomic, copy) NSString *timeString;

@end
