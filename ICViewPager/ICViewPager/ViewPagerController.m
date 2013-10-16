//
//  ViewPagerController.m
//  ICViewPager
//
//  Created by Ilter Cengiz on 28/08/2013.
//  Copyright (c) 2013 Ilter Cengiz. All rights reserved.
//

#import "ViewPagerController.h"

#define kDefaultTabHeight 44.0 // Default tab height
#define kDefaultTabOffset 56.0 // Offset of the second and further tabs' from left
#define kDefaultTabWidth 128.0

#define kDefaultTabLocation 1.0 // 1.0: Top, 0.0: Bottom

#define kDefaultStartFromSecondTab 0.0 // 1.0: YES, 0.0: NO

#define kDefaultCenterCurrentTab 0.0 // 1.0: YES, 0.0: NO

#define kPageViewTag 34

#define kDefaultIndicatorColor [UIColor colorWithRed:178.0/255.0 green:203.0/255.0 blue:57.0/255.0 alpha:0.75]
#define kDefaultTabsViewBackgroundColor [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:0.75]
#define kDefaultContentViewBackgroundColor [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:0.75]

#define IOS_VERSION_7 [[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending

// TabView for tabs, that provides un/selected state indicators
@class TabView;

@interface TabView : UIView
@property (nonatomic, getter = isSelected) BOOL selected;
@property (nonatomic) UIColor *indicatorColor;
@end

@implementation TabView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)setSelected:(BOOL)selected {
    _selected = selected;
    // Update view as state changed
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect {
    
    UIBezierPath *bezierPath;
    
    // Draw top line
    bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0.0, 0.0)];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), 0.0)];
    [[UIColor colorWithWhite:197.0/255.0 alpha:0.75] setStroke];
    [bezierPath setLineWidth:1.0];
    [bezierPath stroke];
    
    // Draw bottom line
    bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0.0, CGRectGetHeight(rect))];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect))];
    [[UIColor colorWithWhite:197.0/255.0 alpha:0.75] setStroke];
    [bezierPath setLineWidth:1.0];
    [bezierPath stroke];
    
    // Draw an indicator line if tab is selected
    if (self.selected) {
        
        bezierPath = [UIBezierPath bezierPath];
        
        // Draw the indicator
        [bezierPath moveToPoint:CGPointMake(0.0, CGRectGetHeight(rect) - 1.0)];
        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect) - 1.0)];
        [bezierPath setLineWidth:5.0];
        [self.indicatorColor setStroke];
        [bezierPath stroke];
    }
}
@end


// ViewPagerController
@interface ViewPagerController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

@property UIPageViewController *pageViewController;
@property (assign) id<UIScrollViewDelegate> actualDelegate;

@property UIScrollView *tabsView;
@property UIView *contentView;

@property NSMutableArray *tabs;
@property NSMutableArray *contents;

@property NSUInteger tabCount;
@property (getter = isAnimatingToTab, assign) BOOL animatingToTab;

@property (nonatomic) NSUInteger activeTabIndex;

@end

@implementation ViewPagerController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self defaultSettings];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self defaultSettings];
    }
    return self;
}

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // Reload data
    [self reloadData];
}
- (void)viewWillLayoutSubviews {
    
    CGFloat topLayoutGuide = 0.0;
    if (IOS_VERSION_7) {
        topLayoutGuide = 20.0;
        if (self.navigationController && !self.navigationController.navigationBarHidden) {
            topLayoutGuide += self.navigationController.navigationBar.frame.size.height;
        }
    }
    
    CGRect frame = self.tabsView.frame;
    frame.origin.x = 0.0;
    frame.origin.y = self.tabLocation ? topLayoutGuide : CGRectGetHeight(self.view.frame) - self.tabHeight;
    frame.size.width = CGRectGetWidth(self.view.frame);
    frame.size.height = self.tabHeight;
    self.tabsView.frame = frame;
    
    frame = self.contentView.frame;
    frame.origin.x = 0.0;
    frame.origin.y = self.tabLocation ? topLayoutGuide + CGRectGetHeight(self.tabsView.frame) : topLayoutGuide;
    frame.size.width = CGRectGetWidth(self.view.frame);
    frame.size.height = CGRectGetHeight(self.view.frame) - (topLayoutGuide + CGRectGetHeight(self.tabsView.frame));
    self.contentView.frame = frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)handleTapGesture:(id)sender {
    
    self.animatingToTab = YES;
    
    // Get the desired page's index
    UITapGestureRecognizer *tapGestureRecognizer = (UITapGestureRecognizer *)sender;
    UIView *tabView = tapGestureRecognizer.view;
    __block NSUInteger index = [self.tabs indexOfObject:tabView];
    
    // Get the desired viewController
    UIViewController *viewController = [self viewControllerAtIndex:index];
    
    // __weak pageViewController to be used in blocks to prevent retaining strong reference to self
    __weak UIPageViewController *weakPageViewController = self.pageViewController;
    __weak ViewPagerController *weakSelf = self;
    
    NSLog(@"%@",weakPageViewController.view);
    
    if (index < self.activeTabIndex) {
        [self.pageViewController setViewControllers:@[viewController]
                                          direction:UIPageViewControllerNavigationDirectionReverse
                                           animated:YES
                                         completion:^(BOOL completed) {
                                             weakSelf.animatingToTab = NO;
                                             
                                             // Set the current page again to obtain synchronisation between tabs and content
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [weakPageViewController setViewControllers:@[viewController]
                                                                                  direction:UIPageViewControllerNavigationDirectionReverse
                                                                                   animated:NO
                                                                                 completion:nil];
                                             });
                                         }];
    } else if (index > self.activeTabIndex) {
        [self.pageViewController setViewControllers:@[viewController]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES
                                         completion:^(BOOL completed) {
                                             weakSelf.animatingToTab = NO;
                                             
                                             // Set the current page again to obtain synchronisation between tabs and content
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [weakPageViewController setViewControllers:@[viewController]
                                                                                  direction:UIPageViewControllerNavigationDirectionForward
                                                                                   animated:NO
                                                                                 completion:nil];
                                             });
                                         }];
    }
    
    // Set activeTabIndex
    self.activeTabIndex = index;
}

#pragma mark - Interface rotation
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    // Re-align tabs if needed
    self.activeTabIndex = self.activeTabIndex;
}

#pragma mark - Setter/Getter
- (void)setActiveTabIndex:(NSUInteger)activeTabIndex {
    
    TabView *activeTabView;
    
    // Set to-be-inactive tab unselected
    activeTabView = [self tabViewAtIndex:self.activeTabIndex];
    activeTabView.selected = NO;
    
    // Set to-be-active tab selected
    activeTabView = [self tabViewAtIndex:activeTabIndex];
    activeTabView.selected = YES;
    
    // Set current activeTabIndex
    _activeTabIndex = activeTabIndex;
    
    // Inform delegate about the change
    if ([self.delegate respondsToSelector:@selector(viewPager:didChangeTabToIndex:)]) {
        [self.delegate viewPager:self didChangeTabToIndex:self.activeTabIndex];
    }
    
    // Bring tab to active position
    // Position the tab in center if centerCurrentTab option provided as YES
    
    UIView *tabView = [self tabViewAtIndex:self.activeTabIndex];
    CGRect frame = tabView.frame;
    
    if (self.centerCurrentTab) {
        
        frame.origin.x += (CGRectGetWidth(frame) / 2);
        frame.origin.x -= CGRectGetWidth(self.tabsView.frame) / 2;
        frame.size.width = CGRectGetWidth(self.tabsView.frame);
        
        if (frame.origin.x < 0) {
            frame.origin.x = 0;
        }
        
        if ((frame.origin.x + CGRectGetWidth(frame)) > self.tabsView.contentSize.width) {
            frame.origin.x = (self.tabsView.contentSize.width - CGRectGetWidth(self.tabsView.frame));
        }
    } else {
        
        frame.origin.x -= self.tabOffset;
        frame.size.width = CGRectGetWidth(self.tabsView.frame);
    }
    
    [self.tabsView scrollRectToVisible:frame animated:YES];
}

#pragma mark -
- (void)defaultSettings {
    
    // Default settings
    self.tabHeight = kDefaultTabHeight;
    self.tabOffset = kDefaultTabOffset;
    self.tabWidth = kDefaultTabWidth;
    
    self.tabLocation = kDefaultTabLocation;
    
    self.startFromSecondTab = kDefaultStartFromSecondTab;
    
    self.centerCurrentTab = kDefaultCenterCurrentTab;
    
    // Default colors
    self.indicatorColor = kDefaultIndicatorColor;
    self.tabsViewBackgroundColor = kDefaultTabsViewBackgroundColor;
    self.contentViewBackgroundColor = kDefaultContentViewBackgroundColor;
    
    // pageViewController
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
    [self addChildViewController:self.pageViewController];

    // Setup some forwarding events to hijack the scrollview
    // Keep a reference to the actual delegate
    self.actualDelegate = ((UIScrollView *)[self.pageViewController.view.subviews objectAtIndex:0]).delegate;
    // Set self as new delegate
    ((UIScrollView *)[self.pageViewController.view.subviews objectAtIndex:0]).delegate = self;
    
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    self.animatingToTab = NO;
}
- (void)reloadData {
    
    // Get settings if provided
    if ([self.delegate respondsToSelector:@selector(viewPager:valueForOption:withDefault:)]) {
        self.tabHeight = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabHeight withDefault:kDefaultTabHeight];
        self.tabOffset = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabOffset withDefault:kDefaultTabOffset];
        self.tabWidth = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabWidth withDefault:kDefaultTabWidth];
        
        self.tabLocation = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabLocation withDefault:kDefaultTabLocation];
        
        self.startFromSecondTab = [self.delegate viewPager:self valueForOption:ViewPagerOptionStartFromSecondTab withDefault:kDefaultStartFromSecondTab];
        
        self.centerCurrentTab = [self.delegate viewPager:self valueForOption:ViewPagerOptionCenterCurrentTab withDefault:kDefaultCenterCurrentTab];
    }
    
    // Get colors if provided
    if ([self.delegate respondsToSelector:@selector(viewPager:colorForComponent:withDefault:)]) {
        self.indicatorColor = [self.delegate viewPager:self colorForComponent:ViewPagerIndicator withDefault:kDefaultIndicatorColor];
        self.tabsViewBackgroundColor = [self.delegate viewPager:self colorForComponent:ViewPagerTabsView withDefault:kDefaultTabsViewBackgroundColor];
        self.contentViewBackgroundColor = [self.delegate viewPager:self colorForComponent:ViewPagerContent withDefault:kDefaultContentViewBackgroundColor];
    }
    
    // Empty tabs and contents
    [self.tabs removeAllObjects];
    [self.contents removeAllObjects];
    
    self.tabCount = [self.dataSource numberOfTabsForViewPager:self];
    
    // Populate arrays with [NSNull null];
    self.tabs = [NSMutableArray arrayWithCapacity:self.tabCount];
    for (int i = 0; i < self.tabCount; i++) {
        [self.tabs addObject:[NSNull null]];
    }
    
    self.contents = [NSMutableArray arrayWithCapacity:self.tabCount];
    for (int i = 0; i < self.tabCount; i++) {
        [self.contents addObject:[NSNull null]];
    }
    
    // Add tabsView
    self.tabsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), self.tabHeight)];
    self.tabsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tabsView.backgroundColor = self.tabsViewBackgroundColor;
    self.tabsView.showsHorizontalScrollIndicator = NO;
    self.tabsView.showsVerticalScrollIndicator = NO;
    
    [self.view insertSubview:self.tabsView atIndex:0];
    
    // Add tab views to _tabsView
    CGFloat contentSizeWidth = 0;
    for (int i = 0; i < self.tabCount; i++) {
        
        UIView *tabView = [self tabViewAtIndex:i];
        
        CGRect frame = tabView.frame;
        frame.origin.x = contentSizeWidth;
        frame.size.width = self.tabWidth;
        tabView.frame = frame;
        
        [self.tabsView addSubview:tabView];
        
        contentSizeWidth += CGRectGetWidth(tabView.frame);
        
        // To capture tap events
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [tabView addGestureRecognizer:tapGestureRecognizer];
    }
    
    self.tabsView.contentSize = CGSizeMake(contentSizeWidth, self.tabHeight);
    
    // Add contentView
    self.contentView = [self.view viewWithTag:kPageViewTag];
    
    if (!self.contentView) {
        
        self.contentView = self.pageViewController.view;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.contentView.backgroundColor = self.contentViewBackgroundColor;
        self.contentView.bounds = self.view.bounds;
        self.contentView.tag = kPageViewTag;
        
        [self.view insertSubview:self.contentView atIndex:0];
    }
    
    // Set first viewController
    UIViewController *viewController;
    
    if (self.startFromSecondTab) {
        viewController = [self viewControllerAtIndex:1];
    } else {
        viewController = [self viewControllerAtIndex:0];
    }
    
    if (viewController == nil) {
        viewController = [[UIViewController alloc] init];
        viewController.view = [[UIView alloc] init];
    }
    
    [self.pageViewController setViewControllers:@[viewController]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
    // Set activeTabIndex
    self.activeTabIndex = self.startFromSecondTab;
}

- (TabView *)tabViewAtIndex:(NSUInteger)index {
    
    if (index >= self.tabCount) {
        return nil;
    }
    
    if ([[self.tabs objectAtIndex:index] isEqual:[NSNull null]]) {

        // Get view from dataSource
        UIView *tabViewContent = [self.dataSource viewPager:self viewForTabAtIndex:index];
        
        // Create TabView and subview the content
        TabView *tabView = [[TabView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tabWidth, self.tabHeight)];
        [tabView addSubview:tabViewContent];
        [tabView setClipsToBounds:YES];
        [tabView setIndicatorColor:self.indicatorColor];
        
        tabViewContent.center = tabView.center;
        
        // Replace the null object with tabView
        [self.tabs replaceObjectAtIndex:index withObject:tabView];
    }
    
    return [self.tabs objectAtIndex:index];
}
- (NSUInteger)indexForTabView:(UIView *)tabView {
    
    return [self.tabs indexOfObject:tabView];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    if (index >= self.tabCount) {
        return nil;
    }
    
    if ([[self.contents objectAtIndex:index] isEqual:[NSNull null]]) {
        
        UIViewController *viewController;
        
        if ([self.dataSource respondsToSelector:@selector(viewPager:contentViewControllerForTabAtIndex:)]) {
            viewController = [self.dataSource viewPager:self contentViewControllerForTabAtIndex:index];
        } else if ([self.dataSource respondsToSelector:@selector(viewPager:contentViewForTabAtIndex:)]) {
            
            UIView *view = [self.dataSource viewPager:self contentViewForTabAtIndex:index];
            
            // Adjust view's bounds to match the pageView's bounds
            UIView *pageView = [self.view viewWithTag:kPageViewTag];
            view.frame = pageView.bounds;
            
            viewController = [UIViewController new];
            viewController.view = view;
        } else {
            viewController = [[UIViewController alloc] init];
            viewController.view = [[UIView alloc] init];
        }
        
        [self.contents replaceObjectAtIndex:index withObject:viewController];
    }
    
    return [self.contents objectAtIndex:index];
}
- (NSUInteger)indexForViewController:(UIViewController *)viewController {
    
    return [self.contents indexOfObject:viewController];
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexForViewController:viewController];
    index++;
    return [self viewControllerAtIndex:index];
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexForViewController:viewController];
    index--;
    return [self viewControllerAtIndex:index];
}

#pragma mark - UIPageViewControllerDelegate
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    UIViewController *viewController = self.pageViewController.viewControllers[0];
    self.activeTabIndex = [self indexForViewController:viewController];
}

#pragma mark - UIScrollViewDelegate, Responding to Scrolling and Dragging
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([self.actualDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.actualDelegate scrollViewDidScroll:scrollView];
    }
    
    if (![self isAnimatingToTab]) {
        UIView *tabView = [self tabViewAtIndex:self.activeTabIndex];
        
        // Get the related tab view position
        CGRect frame = tabView.frame;
        
        CGFloat movedRatio = (scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame)) - 1;
        frame.origin.x += movedRatio * CGRectGetWidth(frame);
        
        if (self.centerCurrentTab) {
            
            frame.origin.x += (frame.size.width / 2);
            frame.origin.x -= CGRectGetWidth(self.tabsView.frame) / 2;
            frame.size.width = CGRectGetWidth(self.tabsView.frame);
            
            if (frame.origin.x < 0) {
                frame.origin.x = 0;
            }
            
            if ((frame.origin.x + frame.size.width) > self.tabsView.contentSize.width) {
                frame.origin.x = (self.tabsView.contentSize.width - CGRectGetWidth(self.tabsView.frame));
            }
        } else {
            
            frame.origin.x -= self.tabOffset;
            frame.size.width = CGRectGetWidth(self.tabsView.frame);
        }
        
        [self.tabsView scrollRectToVisible:frame animated:NO];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.actualDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.actualDelegate scrollViewWillBeginDragging:scrollView];
    }
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([self.actualDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.actualDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([self.actualDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.actualDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    if ([self.actualDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [self.actualDelegate scrollViewShouldScrollToTop:scrollView];
    }
    return NO;
}
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if ([self.actualDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [self.actualDelegate scrollViewDidScrollToTop:scrollView];
    }
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([self.actualDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.actualDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.actualDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.actualDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

#pragma mark - UIScrollViewDelegate, Managing Zooming
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if ([self.actualDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [self.actualDelegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if ([self.actualDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [self.actualDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if ([self.actualDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [self.actualDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if ([self.actualDelegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [self.actualDelegate scrollViewDidZoom:scrollView];
    }
}

#pragma mark - UIScrollViewDelegate, Responding to Scrolling Animations
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self.actualDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.actualDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

@end

