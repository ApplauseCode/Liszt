//
//  LisztCell.h
//  Liszt
//
//  Created by Jeffrey Rosenbluth on 3/11/12.
//  Copyright (c) 2012 Applause Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LisztCell : UITableViewCell
{
	UIView *contentView;
}

- (void) updateLabels:(id) thing;

- (void)drawContentView:(CGRect)r; // subclasses should implement
- (UIFont *)defaultVerySmallFont;
- (UIFont *)defaultSmallFont;
- (UIFont *)defaultLargeFont;
- (NSString *)octaveFinisher;

@end
