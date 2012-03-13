//
//  PieceCell.h
//  Liszt
//
//  Created by Jeffrey Rosenbluth on 3/12/12.
//  Copyright (c) 2012 Applause Code. All rights reserved.
//

#import "LisztCell.h"
@class Piece;

@interface PieceCell : LisztCell

- (void) updateLabels:(Piece *)piece;

@end
