//
//  SectionInfo.h
//  MusicLog
//
//  Created by Kyle Rosenbluth on 11/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SectionHeaderView;

@interface SectionInfo : NSObject
@property(nonatomic, assign) BOOL open;
@property (strong) SectionHeaderView *headerView;
@property (strong) NSString *title;
@property (assign) NSInteger countofRowsToInsert;

@end