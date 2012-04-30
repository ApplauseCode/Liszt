//
//  InfoViewController.h
//  Split
//
//  Created by Jeffrey Rosenbluth on 12/27/11.
//  Copyright (c) 2011 Applause Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface InfoViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *fullScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *drop;
@property (weak, nonatomic) IBOutlet UIButton *geometryProof;
@property (weak, nonatomic) IBOutlet UIButton *convexity;
@property (weak, nonatomic) IBOutlet UIButton *alertMe;
@property (weak, nonatomic) IBOutlet UIButton *faSchedule;
@property (weak, nonatomic) IBOutlet UIButton *twitter;
@property (weak, nonatomic) IBOutlet UIButton *website;

- (IBAction)toURL:(id)sender;
-(void)launchMailAppOnDevice;
-(void)displayComposerSheet;

@end
