#import <UIKit/UIKit.h>
#import "AWESlidingTabbarProtocol.h"
#import "AWESlidingScrollView.h"

typedef NS_ENUM(NSInteger, AWESlidingVCTransitionType) {
    AWESlidingVCTransitionTypeTapTab = 0,
    AWESlidingVCTransitionTypeScroll = 1,
};

@class AWESlidingViewController;

@protocol AWESlidingViewControllerDelegate <NSObject>

- (NSInteger)numberOfControllers:(AWESlidingViewController *)slidingController;
- (UIViewController *)slidingViewController:(AWESlidingViewController *)slidingViewController viewControllerAtIndex:(NSInteger)index;

@optional
- (void)slidingViewController:(AWESlidingViewController *)slidingViewController didSelectIndex:(NSInteger)index;

- (void)slidingViewController:(AWESlidingViewController *)slidingViewController didSelectIndex:(NSInteger)index transitionType:(AWESlidingVCTransitionType)transitionType;

- (void)slidingViewController:(AWESlidingViewController *)slidingViewController willTransitionToViewController:(UIViewController *)pendingViewController;

- (void)slidingViewController:(AWESlidingViewController *)slidingViewController willTransitionToViewController:(UIViewController *)pendingViewController transitionType:(AWESlidingVCTransitionType)transitionType;

- (void)slidingViewController:(AWESlidingViewController *)slidingViewController didFinishTransitionFromPreviousViewController:(UIViewController *)previousViewController currentViewController:(UIViewController *)currentViewController;

- (void)slidingViewControllerDidScroll:(UIScrollView *)scrollView;

@end

@interface AWESlidingViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, strong) UIView<AWESlidingTabbarProtocol> *tabbarView;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) BOOL slideEnabled;
@property (nonatomic, assign) BOOL needAnimationWithTapTab;
@property (nonatomic, weak) id<AWESlidingViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL shouldAdjustScrollInsets;
@property (nonatomic, strong) AWESlidingScrollView *contentScrollView;
@property (nonatomic, assign) BOOL enableSwipeCardEffect; //卡片横向切换效果

- (instancetype)initWithSelectedIndex:(NSInteger)index;
- (void)reloadViewControllers;
- (UIViewController *)controllerAtIndex:(NSInteger)index;
- (Class)scrollViewClass;
- (NSInteger)currentScrollPage;
- (NSInteger)numberOfControllers;
- (NSArray<UIView *> *)visibleViews;
- (NSArray *)currentViewControllers;

@end
