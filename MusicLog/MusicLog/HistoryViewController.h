//
//  HistoryViewController.h
//  Liszt
//
//  Created by Jeffrey Rosenbluth on 3/20/12.
//  Copyright (c) 2012 Applause Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *forwardYearButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardMonthButton;
@property (weak, nonatomic) IBOutlet UIButton *todayButton;
@property (weak, nonatomic) IBOutlet UIButton *backYearButton;
@property (weak, nonatomic) IBOutlet UIButton *backMonthButton;
- (IBAction)backOneYear:(id)sender;
- (IBAction)backOneMonth:(id)sender;
- (IBAction)forwardOneMonth:(id)sender;
- (IBAction)forwardOneYear:(id)sender;
- (IBAction)toToday:(id)sender;
- (void)loadData;
- (void)reloadFirstCell;

@end
