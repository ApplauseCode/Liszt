//
//  SessionStore.h
//  Liszt
//
//  Created by Jeffrey Rosenbluth on 2/15/12.
//  Copyright (c) 2012 Applause Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Scale;
@class Session;
@class Piece;

@interface SessionStore : NSObject

@property (nonatomic, strong) Session *mySession;
@property (nonatomic, strong) NSMutableArray *sessions;

+ (SessionStore *)defaultStore;

- (void)startNewSession:(BOOL)fresh;
- (BOOL)saveChanges;

@end
