#import "SectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+YellowTextColor.h"

@interface SectionHeaderView ()
@property (nonatomic, copy) NSString *aTitle;
@property (nonatomic, copy) NSString *aTime;
@property (nonatomic, assign) BOOL disclosure;
@end

@implementation SectionHeaderView
@synthesize aTitle;
@synthesize aTime;
@synthesize longTap;
@synthesize disclosure;

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
            _backgroundImage = [UIImage imageNamed:@"FinalScalesSectionBG.png"];
            break;
        case 1:
            _backgroundImage = [UIImage imageNamed:@"FinalArpeggioSectionBG.png"];
            break;    
        default:
            _backgroundImage = [UIImage imageNamed:@"FinalPieceSectionBG.png"];
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
    if (disclosure)
        _disclosureImage = [UIImage imageNamed:@"DisclosureArrowDown.png"];
    else {
        _disclosureImage = [UIImage imageNamed:@"DisclosureArrow.png"];
    }
    [_disclosureImage drawInRect:CGRectMake(25, 17, 6, 7)];
}

- (void)turnDownDisclosure:(BOOL)yesOrNo
{
    if (yesOrNo) {
        [self setDisclosure:YES];
    }
    else {
        [self setDisclosure:NO];
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

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(deleteCell:))
        return YES;
    return NO;
    
}

- (BOOL)canBecomeFirstResponder { return YES;}

- (void)toggleLongTap:(UILongPressGestureRecognizer *)sender
{
    if ([sender state] == UIGestureRecognizerStateBegan && [self section] > 1)
    {
        [self becomeFirstResponder];
        UIMenuController *deleteMenu = [UIMenuController sharedMenuController];
        UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteCell:)];
        [deleteMenu setMenuItems:[NSArray arrayWithObject:delete]];
        [deleteMenu update];
        CGPoint newPoint = [self.superview convertPoint:self.frame.origin toView:self.superview.superview];
        [deleteMenu setTargetRect:CGRectMake(newPoint.x, newPoint.y, self.frame.size.width, self.frame.size.height) inView:self.superview.superview];
        [deleteMenu setMenuVisible:YES animated:YES];
    }
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
- (void)deleteCell:(id)sender
{
    [[self delegate] deleteSection:self.section];
}

@end
