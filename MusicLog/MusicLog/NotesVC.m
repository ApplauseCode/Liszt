//
//  NotesVC.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotesVC.h"
#import "Scale.h"
#import "Piece.h"
#import "SessionStore.h"
#import "Session.h"

@interface NotesVC ()
@property (nonatomic, strong) id item;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) id notesLocation;
@property (nonatomic, strong) UITextView *notesTextView;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, strong) Session *session;
@end

@implementation NotesVC
@synthesize item;
@synthesize notes;
@synthesize notesTextView;
@synthesize doneButton;
@synthesize notesLocation;
@synthesize section;
@synthesize session;

- (id)initWithIndexPath:(NSIndexPath *)_indexPath session:(Session *)_session
{
    self = [super init];
    if (self)
    {
        section = [_indexPath section];
        NSInteger row = [_indexPath row];
        session = _session;
        switch (section) {
            case 0:
                item = [[session scaleSession] objectAtIndex:row - 1];
                notes = [session scaleNotes];
                break;
            case 1:
                item = [[session arpeggioSession] objectAtIndex:row - 1];
                notes = [session arpeggioNotes];
            default:
                item = [[session pieceSession] objectAtIndex:row - 1];
                notes = [item pieceNotes];
                break;
        }
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self.view setBackgroundColor:[UIColor blueColor]];
    notesTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 225, 280, 100)];
    [notesTextView setDelegate:self];
    [self.view addSubview:notesTextView];
    
    doneButton = [[UIButton alloc] initWithFrame:CGRectMake(230, 7, 80, 49)];
    [self.view addSubview:doneButton];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
        [self setNotes:[textView text]];
//        NSLog(@"%@", [[[SessionStore defaultStore] mySession] scaleNotes]);
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

//- (void)viewWillDisappear:(BOOL)animated
//{
//    switch (section) {
//        case 0:
//            [session setScaleNotes:notes];
//            break;
//        case 1:
//            [session setArpeggioNotes:notes];
//        default:
//            //[session
//            break;
//    }
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
