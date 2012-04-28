//
//  ReloadDataTable.h
//  Liszt
//
//  Created by Kyle Rosenbluth on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReloadDataTableDelegate;

@interface ReloadDataTable : UITableView
@property (nonatomic, weak) id<ReloadDataTableDelegate, UITableViewDelegate, UITableViewDataSource> delegate;
@end

@protocol ReloadDataTableDelegate <NSObject>
@optional
- (void)doneReloadingData;
@end
