//
//  CustomCell.h
//  PianoLog
//
//  Created by Kyle Rosenbluth on 8/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScalesPracticedCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *tonicLabel;
@property (nonatomic, strong) IBOutlet UILabel *octavesLabel;
@property (nonatomic, strong) IBOutlet UILabel *rhythmLabel;
@property (nonatomic, strong) IBOutlet UILabel *speedLabel;
@property (nonatomic, strong) IBOutlet UILabel *modeLabel;
@property (strong, nonatomic) IBOutlet UILabel *octavesIdentifier;

@end
