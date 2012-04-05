//
//  HistoryViewController.h
//  Liszt
//
//  Created by Jeffrey Rosenbluth on 3/20/12.
//  Copyright (c) 2012 Applause Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource>
- (IBAction)backOneYear:(id)sender;
- (IBAction)backOneMonth:(id)sender;
- (IBAction)toToday:(id)sender;
- (void)loadData;
- (void)reloadFirstCell;

@end
