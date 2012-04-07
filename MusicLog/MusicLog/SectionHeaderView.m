#import "SectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+YellowTextColor.h"

@interface SectionHeaderView ()
@property (nonatomic, copy) NSString *aTitle;
@property (nonatomic, copy) NSString *aTime;
@end

@implementation SectionHeaderView
@synthesize aTitle;
@synthesize aTime;
@synthesize longTap;

static UIImage *_backgroundImage = nil;
static UIImage *_disclosureImage = nil;


@synthesize delegate=_delegate, section=_section, tapGesture, swipeGesture, deleteView, notesButton, deleteButton;

+ (Class)layerClass {
    
    return [CAGradientLayer class];
}

-(id)initWithFrame:(CGRect)frame title:(NSString*)title subTitle:(NSString *)subTitle section:(NSInteger)sectionNumber delegate:(id <SectionHeaderViewDelegate>)delegate 
{
    
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self setBackgroundColor:[UIColor clearColor]];
        _section = sectionNumber;
        _delegate = delegate;  
        aTitle = title;
        aTime = subTitle;
        _disclosureImage = [UIImage imageNamed:@"DisclosureArrow.png"];
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
        longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(toggleLongTap:)];
        [self addGestureRecognizer:tapGesture];
        [self addGestureRecognizer:longTap];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    switch ([self section]) {
        case 0:
            _backgroundImage = [UIImage imageNamed:@"SectionHeader1.png"];
            break;
        case 1:
            _backgroundImage = [UIImage imageNamed:@"SectionHeader2.png"];
            break;    
        default:
            _backgroundImage = [UIImage imageNamed:@"SectionHeader3.png"];
            break;
    }    
    [_backgroundImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    UIColor *textColor = [UIColor yellowTextColor];
    [textColor set];
    [aTitle drawAtPoint:CGPointMake(37, 14)
                   forWidth:201
                   withFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:20]
              lineBreakMode:UILineBreakModeTailTruncation];
    [aTime drawAtPoint:CGPointMake(240, 13)
               forWidth:100
               withFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:20]
          lineBreakMode:UILineBreakModeTailTruncation];
    [_disclosureImage drawInRect:CGRectMake(25, 17, 6, 7)];
}

//-(id)initWithFrame:(CGRect)frame title:(NSString*)title subTitle:(NSString *)subTitle section:(NSInteger)sectionNumber delegate:(id <SectionHeaderViewDelegate>)delegate {
//        
//        [deleteView setBackgroundColor:[UIColor clearColor]];
//        [deleteView setOpaque:NO];
//        notesButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 45)];
//        [notesButton setTitle:@"Notations" forState:UIControlStateNormal];
//        [notesButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [notesButton setBackgroundColor:[UIColor clearColor]];
//        [notesButton setOpaque:NO];
//        [notesButton addTarget:self action:@selector(addNotes:) forControlEvents:UIControlEventTouchUpInside];
//        deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 0, 160, 45)];
//        [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
//        [deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [deleteButton setOpaque:NO];
//        [deleteButton setBackgroundColor:[UIColor clearColor]];
//        [deleteButton addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
//        [deleteView addSubview:deleteButton];
//        [deleteView addSubview:notesButton];
//        [self insertSubview:deleteView belowSubview:self];
//        [deleteView setBackgroundColor:[UIColor whiteColor]];
//        //ongTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(toggleLongTap:)];
//        [self addGestureRecognizer:tapGesture];
//        [self addGestureRecognizer:swipeGesture];
//        //[self addGestureRecognizer:longTap];
//        self.userInteractionEnabled = YES;
//        

- (void)turnDownDisclosure:(BOOL)yesOrNo
{
    if (yesOrNo) {
        _disclosureImage = [UIImage imageNamed:@"DisclosureArrowDown.png"];
    }
    else {
        _disclosureImage = [UIImage imageNamed:@"DisclosureArrow.png"];
    }
    [self setNeedsDisplay];
}

- (void)setSubTitle:(NSString *)subName
{
    aTime = subName;
}


-(void)toggleOpen:(id)sender {
    [self.delegate sectionTapped:self.section];
}

- (void)toggleSwipe:(id)sender
{
    [[self delegate] sectionSwiped:self.section];
    [deleteView setHidden:NO];
    [UIView animateWithDuration:0.2 animations:^{        
        // Move the side swipe view to offset 0
        deleteView.frame = CGRectMake(self.frame.size.width, 0, deleteView.frame.size.width, deleteView.frame.size.height);
        // While simultaneously moving the cell's frame offscreen
        // The net effect is that the side swipe view is pushing the cell offscreen
        self.frame = CGRectMake(-self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [[self tapGesture] setEnabled:NO];
    }];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(deleteCell:))
        return YES;
    return NO;
    
}

- (BOOL)canBecomeFirstResponder { return YES;}

- (void)toggleLongTap:(UILongPressGestureRecognizer *)sender
{
    if ([sender state] == UIGestureRecognizerStateBegan)
    {
        [self becomeFirstResponder];
        UIMenuController *deleteMenu = [UIMenuController sharedMenuController];
        UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteCell:)];
        [deleteMenu setMenuItems:[NSArray arrayWithObject:delete]];
        [deleteMenu update];
        CGPoint newPoint = [self.superview convertPoint:self.frame.origin toView:self.superview.superview];
        NSLog(@"point: %@", NSStringFromCGPoint(newPoint));
        [deleteMenu setTargetRect:CGRectMake(newPoint.x, newPoint.y, self.frame.size.width, self.frame.size.height) inView:self.superview.superview];
        [deleteMenu setMenuVisible:YES animated:YES];
    }
}
//
- (void)addNotes:(id)sender
{
//    [[self delegate] displayNotesViewForSection:self.section headerView:self];
}

- (void)cancelDelete:(id)sender
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
        [deleteView setFrame:CGRectMake(0, 0, deleteView.frame.size.width, deleteView.frame.size.height)];
        [self setFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
    } completion:^(BOOL finished) {
       // [deleteView removeFromSuperview];
        [deleteView setHidden:YES];
        [[self tapGesture] setEnabled:YES];
    }];
}
//
- (void)deleteCell:(id)sender
{
    [[self delegate] deleteSection:self.section];
}
//
//- (void)toggleLongTap:(UILongPressGestureRecognizer *)sender
//{
//    if (sender.state == UIGestureRecognizerStateBegan)
//        [[self delegate] moveSection:self.section headerView:self];
//}


@end
