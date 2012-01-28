//
//  ScaleStore.h
//  InstrumentLog
//
//  Created by Kyle Rosenbluth on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Scale;
@class Session;
@class Piece;

@interface ScaleStore : NSObject

@property (nonatomic, strong) Session *mySession;
@property (nonatomic, strong) NSMutableOrderedSet *scalesInSession;
@property (nonatomic, strong) NSMutableOrderedSet *arpeggiosInSession;
@property (nonatomic, strong) NSMutableOrderedSet *piecesInSession;
@property (nonatomic, strong) NSMutableArray *sessions;


+ (ScaleStore *)defaultStore;

- (void)addScale:(Scale *)s;
- (void)addArpeggio:(Scale *)a;
- (void)addPiece:(Piece *)p;
- (void)addArpeggioArray:(NSArray *)a;
- (void)addScaleArray:(NSArray *)s;
- (void)addPieceArray:(NSArray *)p;
- (void)removeScale:(Scale *)s;
- (void)removeArpeggio:(Scale *)a;
- (void)removePiece:(Piece *)p;
- (void)addSessionStartNew:(BOOL)fresh;
- (void)clearAll;

- (void)addScalesToSession;
- (void)addArpeggiosToSession;
- (void)addPiecesToSession;

- (NSString *)scaleArchivePath;
- (BOOL)saveChanges;

@end
