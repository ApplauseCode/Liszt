#import "SectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SectionHeaderView


@synthesize titleLabel=_titleLabel, disclosureButton=_disclosureButton, delegate=_delegate, section=_section, tapGesture, swipeGesture, subTitleLabel, deleteView;


+ (Class)layerClass {
    
    return [CAGradientLayer class];
}


-(id)initWithFrame:(CGRect)frame title:(NSString*)title subTitle:(NSString *)subTitle section:(NSInteger)sectionNumber delegate:(id <SectionHeaderViewDelegate>)delegate {
    
    self = [super initWithFrame:frame];
    
    if (self != nil) {
    
        deleteView = [[UIView alloc] initWithFrame:CGRectMake(-320, 0, 320, 45)];
        [deleteView setBackgroundColor:[UIColor whiteColor]];
        // Set up the tap gesture recognizer.
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
        swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSwipe:)];
        [self addGestureRecognizer:tapGesture];
        [self addGestureRecognizer:swipeGesture];

        _delegate = delegate;        
        self.userInteractionEnabled = YES;
        
        
        // Create and configure the title label.
        _section = sectionNumber;
        CGRect titleLabelFrame = self.bounds;
        titleLabelFrame.origin.x += 35.0;
        titleLabelFrame.size.width -= 35.0;
        CGRectInset(titleLabelFrame, 0.0, 5.0);
        UILabel *label = [[UILabel alloc] initWithFrame:titleLabelFrame];
        label.text = title;
        label.font = [UIFont boldSystemFontOfSize:17.0];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        _titleLabel = label;
        
        CGRect subTitleLabelFrame = self.bounds;
        subTitleLabelFrame.origin.x += 245;
        subTitleLabelFrame.size.width -= 35.0;
        CGRectInset(subTitleLabelFrame, 0.0, 5.0);
        UILabel *subLabel = [[UILabel alloc] initWithFrame:subTitleLabelFrame];
        subLabel.text = subTitle;
        subLabel.font = [UIFont boldSystemFontOfSize:17.0];
        subLabel.textColor = [UIColor whiteColor];
        subLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:subLabel];
        subTitleLabel = subLabel;
        
        /*CGRect subTitleLabelFrame = self.bounds;
        subTitleLabelFrame.origin.x += 285;
        subTitleLabelFrame.size.width -= 35.0;
        CGRectInset(subTitleLabelFrame, 0.0, 5.0);
        UILabel *subLabel = [[UILabel alloc] initWithFrame:subTitleLabelFrame];
        subLabel.text = title;
        label.font = [UIFont boldSystemFontOfSize:17.0];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];*/
        
        
        // Create and configure the disclosure button.
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0.0, 5.0, 35.0, 35.0);
        [button setImage:[UIImage imageNamed:@"carat.png"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"carat-open.png"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(toggleOpen:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        _disclosureButton = button;
        
        
        // Set the colors for the gradient layer.
        static NSMutableArray *colors = nil;
        if (colors == nil) {
            colors = [[NSMutableArray alloc] initWithCapacity:3];
            UIColor *color = nil;
            color = [UIColor colorWithRed:0.82 green:0.84 blue:0.87 alpha:1.0];
            [colors addObject:(id)[color CGColor]];
            color = [UIColor colorWithRed:.35 green:.35 blue:.35 alpha:1.0];
            [colors addObject:(id)[color CGColor]];
            color = [UIColor colorWithRed:.35 green:.35 blue:.35 alpha:1.0];
            [colors addObject:(id)[color CGColor]];
        }
        [(CAGradientLayer *)self.layer setColors:colors];
        [(CAGradientLayer *)self.layer setLocations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.48], [NSNumber numberWithFloat:1.0], nil]];
    }
    
    return self;
}

- (void)setSubTitle:(NSString *)subName
{
    [subTitleLabel setText:subName];
}


-(IBAction)toggleOpen:(id)sender {
    
    [self.delegate sectionHeaderView:self tapped:self.section];
    //[self toggleOpenWithUserAction:YES];
}


-(void)toggleOpenWithUserAction:(BOOL)userAction {
    
    // Toggle the disclosure button state.
    self.disclosureButton.selected = !self.disclosureButton.selected;
    
    // If this was a user action, send the delegate the appropriate message.
    if (userAction) {
        if (self.disclosureButton.selected) {
            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
                //[self.delegate sectionHeaderView:self sectionOpened:self.section];
            }
        }
        else {
            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
               // [self.delegate sectionHeaderView:self sectionClosed:self.section];
            }
        }
    }
}

- (void)toggleSwipe:(id)sender
{

    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 45)];
    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancel setBackgroundColor:[UIColor blueColor]];
    [cancel addTarget:self action:@selector(cancelDelete:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *delete = [[UIButton alloc] initWithFrame:CGRectMake(160, 0, 160, 45)];
    [delete setTitle:@"Delete" forState:UIControlStateNormal];
    [delete setBackgroundColor:[UIColor blueColor]];
    [delete addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
    [deleteView addSubview:delete];
    [deleteView addSubview:cancel];
    [self addSubview:deleteView];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
        [deleteView setFrame:CGRectMake(0.0, 0.0, 320, 45)];
        //[self setFrame:CGRectMake(640, 0, 320, 45)];
    } completion:^(BOOL finished) {
        [[self tapGesture] setEnabled:NO];
    }];
}

- (void)cancelDelete:(id)sender
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
        [deleteView setFrame:CGRectMake(-320, 0, 320, 45)];
    } completion:^(BOOL finished) {
        [deleteView removeFromSuperview];
        [[self tapGesture] setEnabled:YES];
    }];
    
}

- (void)deleteCell:(id)sender
{
    [[self delegate] deleteSection:self.section headerView:self];
}

@end
