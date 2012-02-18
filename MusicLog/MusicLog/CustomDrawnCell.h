//
//  CustomDrawnCell.h
//  TableViewPerformance
//
//  Created by Mugunth Kumar M on 25/8/11.
//

#import <UIKit/UIKit.h>
#import "ABTableViewCell.h"

@interface CustomDrawnCell : ABTableViewCell  {
    
    NSString *_tonicLabel;
    NSString *_octavesLabel;
    NSString *_rhythmLabel;
    NSString *_modeLabel;
    NSString *_speedLabel;
    BOOL isPiece;
}

- (void) isPiece:(BOOL)piece setTonic:(NSString*) tonic octaves:(NSString*) octaves rhythm:(NSString*) rhythm mode:(NSString*) mode speed:(NSString*) speed;

@end
