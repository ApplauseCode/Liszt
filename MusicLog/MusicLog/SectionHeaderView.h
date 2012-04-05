

#import <Foundation/Foundation.h>

@protocol SectionHeaderViewDelegate;

@interface SectionHeaderView : UIView 

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longTap;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGesture;
@property (nonatomic, strong) UIView *deleteView;
@property (nonatomic, strong) UIButton *notesButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, weak) id <SectionHeaderViewDelegate> delegate;

-(id)initWithFrame:(CGRect)frame title:(NSString*)title subTitle:(NSString *)subTitle section:(NSInteger)sectionNumber delegate:(id <SectionHeaderViewDelegate>)delegate;
//-(void)toggleOpenWithUserAction:(BOOL)userAction;
- (void)setSubTitle:(NSString *)subName;
- (void)toggleSwipe:(id)sender;
- (void)toggleLongTap:(UILongPressGestureRecognizer *)sender;
- (void)cancelDelete:(id)sender;
//- (void)deleteCell:(id)sender;
- (void)addNotes:(id)sender;
- (void)turnDownDisclosure:(BOOL)yesOrNo;

@end



// Protocol to be adopted by the section header's delegate; the section header tells its delegate when the section should be opened and closed.

@protocol SectionHeaderViewDelegate <NSObject>

@optional
- (void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView tapped:(NSInteger)section;
- (void)deleteSection:(NSInteger)section headerView:(SectionHeaderView *)sectionHeaderView;
- (void)moveSection:(NSInteger)section headerView:(SectionHeaderView *)sectionHeaderView;
- (void)sectionSwiped:(NSInteger)section headerView:(SectionHeaderView *)sectionHeaderView;
- (void)displayNotesViewForSection:(NSInteger)section headerView:(SectionHeaderView *)headerView;

@end

