//
//  CustomSectionMove.h
//  Liszt
//
//  Created by Kyle Rosenbluth on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomSectionMoveDelegate;

@interface CustomSectionMove : UIControl
- (id)initWithFrame:(CGRect)frame numberOfSections:(NSInteger)sections heightOfSection:(NSInteger)height;
@property (nonatomic, assign) NSInteger numberOfSections;
@property (nonatomic, assign) NSInteger heightOfSection;
@property (nonatomic, assign) NSInteger selectedSection;
@property (nonatomic, assign) NSInteger oldSection;
@property (nonatomic, weak) id <CustomSectionMoveDelegate> delegate;

@end

@protocol CustomSectionMoveDelegate <NSObject>

- (void)sectionMoveLocationSelected:(NSInteger)section;

@end