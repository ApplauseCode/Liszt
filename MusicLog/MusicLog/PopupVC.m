//
//  PopupVC.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PopupVC.h"

@interface PopupVC ()
@property (nonatomic, assign) CGRect frame;
@end

@implementation PopupVC
@synthesize staticTable;
@synthesize numberOfRows;
@synthesize staticCells;
@synthesize frame;
@synthesize delegate;

- (id)initWithFrame:(CGRect)_frame
{
    self = [super init];
    if (self)
    {
        frame = _frame;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
	// Do any additional setup after loading the view.
    [self.view setFrame:frame];
    staticTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    [staticTable setDelegate:self];
    [staticTable setDataSource:self];
    //NSLog(@"self height: %f", [self.view frame].size.height);
    [self.view addSubview:staticTable];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%i", [staticCells count]);
    return [staticCells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [staticCells objectAtIndex:[indexPath row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self delegate] cellSelectedAtIndex:[indexPath row]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
