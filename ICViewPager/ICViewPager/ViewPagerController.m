//
//  ViewPagerController.m
//  ICViewPager
//
//  Created by Ilter Cengiz on 28/08/2013.
//  Copyright (c) 2013 Ilter Cengiz. All rights reserved.
//

#import "ViewPagerController.h"

#define kPageViewTag 34

#define IOS_VERSION_7 [[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending

/*
 * TabView for tabs, that provides un/selected state indicators
 */
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


/*
 * ViewPagerController
 */
@interface ViewPagerController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

// Tab and content stuff
@property UIScrollView *tabsView;
@property UIView *contentView;

@property UIPageViewController *pageViewController;
@property (assign) id<UIScrollViewDelegate> actualDelegate;

// Tab and content cache
@property NSMutableArray *tabs;
@property NSMutableArray *contents;

// Options
@property (nonatomic) NSNumber *tabHeight;
@property (nonatomic) NSNumber *tabOffset;
@property (nonatomic) NSNumber *tabWidth;
@property (nonatomic) NSNumber *tabLocation;
@property (nonatomic) NSNumber *startFromSecondTab;
@property (nonatomic) NSNumber *centerCurrentTab;

@property (nonatomic) NSUInteger tabCount;
@property (nonatomic) NSUInteger activeTabIndex;

@property (getter = isAnimatingToTab, assign) BOOL animatingToTab;

// Colors
@property (nonatomic) UIColor *indicatorColor;
@property (nonatomic) UIColor *tabsViewBackgroundColor;
@property (nonatomic) UIColor *contentViewBackgroundColor;

@end

@implementation ViewPagerController

@synthesize tabHeight = _tabHeight;
@synthesize tabOffset = _tabOffset;
@synthesize tabWidth = _tabWidth;
@synthesize tabLocation = _tabLocation;
@synthesize startFromSecondTab = _startFromSecondTab;
@synthesize centerCurrentTab = _centerCurrentTab;

#pragma mark - Init
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
    frame.origin.y = [self.tabLocation boolValue] ? topLayoutGuide : CGRectGetHeight(self.view.frame) - [self.tabHeight floatValue];
    frame.size.width = CGRectGetWidth(self.view.frame);
    frame.size.height = [self.tabHeight floatValue];
    self.tabsView.frame = frame;
    
    frame = self.contentView.frame;
    frame.origin.x = 0.0;
    frame.origin.y = [self.tabLocation boolValue] ? topLayoutGuide + CGRectGetHeight(self.tabsView.frame) : topLayoutGuide;
    frame.size.width = CGRectGetWidth(self.view.frame);
    frame.size.height = CGRectGetHeight(self.view.frame) - (topLayoutGuide + CGRectGetHeight(self.tabsView.frame));
    self.contentView.frame = frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction
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

#pragma mark - Setters
- (void)setTabHeight:(NSNumber *)tabHeight {
    
    if ([tabHeight floatValue] < 4.0)
        tabHeight = [NSNumber numberWithFloat:4.0];
    else if ([tabHeight floatValue] > CGRectGetHeight(self.view.frame))
        tabHeight = [NSNumber numberWithFloat:CGRectGetHeight(self.view.frame)];
    
    _tabHeight = tabHeight;
}
- (void)setTabOffset:(NSNumber *)tabOffset {
    
    if ([tabOffset floatValue] < 0.0)
        tabOffset = [NSNumber numberWithFloat:0.0];
    else if ([tabOffset floatValue] > CGRectGetWidth(self.view.frame) - [self.tabWidth floatValue])
        tabOffset = [NSNumber numberWithFloat:CGRectGetWidth(self.view.frame) - [self.tabWidth floatValue]];
    
    _tabOffset = tabOffset;
}
- (void)setTabWidth:(NSNumber *)tabWidth {
    
    if ([tabWidth floatValue] < 4.0)
        tabWidth = [NSNumber numberWithFloat:4.0];
    else if ([tabWidth floatValue] > CGRectGetWidth(self.view.frame))
        tabWidth = [NSNumber numberWithFloat:CGRectGetWidth(self.view.frame)];
    
    _tabWidth = tabWidth;
}
- (void)setTabLocation:(NSNumber *)tabLocation {
    
    if ([tabLocation floatValue] != 1.0 && [tabLocation floatValue] != 0.0)
        tabLocation = [NSNumber numberWithFloat:1.0];
    
    _tabLocation = tabLocation;
}
- (void)setStartFromSecondTab:(NSNumber *)startFromSecondTab {
    
    if ([startFromSecondTab floatValue] != 1.0 && [startFromSecondTab floatValue] != 0.0)
        startFromSecondTab = [NSNumber numberWithFloat:0.0];
    
    _startFromSecondTab = startFromSecondTab;
}
- (void)setCenterCurrentTab:(NSNumber *)centerCurrentTab {
    
    if ([centerCurrentTab floatValue] != 1.0 && [centerCurrentTab floatValue] != 0.0)
        centerCurrentTab = [NSNumber numberWithFloat:0.0];
    
    _centerCurrentTab = centerCurrentTab;
}

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
    
    if ([self.centerCurrentTab boolValue]) {
        
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
        
        frame.origin.x -= [self.tabOffset floatValue];
        frame.size.width = CGRectGetWidth(self.tabsView.frame);
    }
    
    [self.tabsView scrollRectToVisible:frame animated:YES];
}

#pragma mark - Getters
- (NSNumber *)tabHeight {
    
    if (!_tabHeight) {
        CGFloat value = 44.0;
        if ([self.delegate respondsToSelector:@selector(viewPager:valueForOption:withDefault:)])
            value = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabHeight withDefault:value];
        self.tabHeight = [NSNumber numberWithFloat:value];
    }
    return _tabHeight;
}
- (NSNumber *)tabOffset {
    
    if (!_tabOffset) {
        CGFloat value = 56.0;
        if ([self.delegate respondsToSelector:@selector(viewPager:valueForOption:withDefault:)])
            value = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabOffset withDefault:value];
        self.tabOffset = [NSNumber numberWithFloat:value];
    }
    return _tabOffset;
}
- (NSNumber *)tabWidth {
    
    if (!_tabWidth) {
        CGFloat value = 128.0;
        if ([self.delegate respondsToSelector:@selector(viewPager:valueForOption:withDefault:)])
            value = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabWidth withDefault:value];
        self.tabWidth = [NSNumber numberWithFloat:value];
    }
    return _tabWidth;
}
- (NSNumber *)tabLocation {
    
    if (!_tabLocation) {
        CGFloat value = 1.0;
        if ([self.delegate respondsToSelector:@selector(viewPager:valueForOption:withDefault:)])
            value = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabLocation withDefault:value];
        self.tabLocation = [NSNumber numberWithFloat:value];
    }
    return _tabLocation;
}
- (NSNumber *)startFromSecondTab {
    
    if (!_startFromSecondTab) {
        CGFloat value = 0.0;
        if ([self.delegate respondsToSelector:@selector(viewPager:valueForOption:withDefault:)])
            value = [self.delegate viewPager:self valueForOption:ViewPagerOptionStartFromSecondTab withDefault:value];
        _startFromSecondTab = [NSNumber numberWithFloat:value];
    }
    return _startFromSecondTab;
}
- (NSNumber *)centerCurrentTab {
    
    if (!_centerCurrentTab) {
        CGFloat value = 0.0;
        if ([self.delegate respondsToSelector:@selector(viewPager:valueForOption:withDefault:)])
            value = [self.delegate viewPager:self valueForOption:ViewPagerOptionCenterCurrentTab withDefault:value];
        _centerCurrentTab = [NSNumber numberWithFloat:value];
    }
    return _centerCurrentTab;
}

- (UIColor *)indicatorColor {
    
    if (!_indicatorColor) {
        UIColor *color = [UIColor colorWithRed:178.0/255.0 green:203.0/255.0 blue:57.0/255.0 alpha:0.75];
        if ([self.delegate respondsToSelector:@selector(viewPager:colorForComponent:withDefault:)]) {
            color = [self.delegate viewPager:self colorForComponent:ViewPagerIndicator withDefault:color];
        }
        self.indicatorColor = color;
    }
    return _indicatorColor;
}
- (UIColor *)tabsViewBackgroundColor {
    
    if (_tabsViewBackgroundColor) {
        UIColor *color = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:0.75];
        if ([self.delegate respondsToSelector:@selector(viewPager:colorForComponent:withDefault:)]) {
            color = [self.delegate viewPager:self colorForComponent:ViewPagerTabsView withDefault:color];
        }
        self.tabsViewBackgroundColor = color;
    }
    return _tabsViewBackgroundColor;
}
- (UIColor *)contentViewBackgroundColor {
    
    if (!_contentViewBackgroundColor) {
        UIColor *color = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:0.75];
        if ([self.delegate respondsToSelector:@selector(viewPager:colorForComponent:withDefault:)]) {
            color = [self.delegate viewPager:self colorForComponent:ViewPagerContent withDefault:color];
        }
        self.contentViewBackgroundColor = color;
    }
    return _contentViewBackgroundColor;
}

#pragma mark - Public methods
- (void)reloadData {
    
    // Empty tabs and contents
    [self.tabs removeAllObjects];
    [self.contents removeAllObjects];
    
    // Get tabCount from dataSource
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
    self.tabsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), [self.tabHeight floatValue])];
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
        frame.size.width = [self.tabWidth floatValue];
        tabView.frame = frame;
        
        [self.tabsView addSubview:tabView];
        
        contentSizeWidth += CGRectGetWidth(tabView.frame);
        
        // To capture tap events
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [tabView addGestureRecognizer:tapGestureRecognizer];
    }
    
    self.tabsView.contentSize = CGSizeMake(contentSizeWidth, [self.tabHeight floatValue]);
    
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
    self.activeTabIndex = [self.startFromSecondTab unsignedIntegerValue];
}

- (CGFloat)valueForOption:(ViewPagerOption)option {
    
    switch (option) {
        case ViewPagerOptionTabHeight:
            return [[self tabHeight] floatValue];
        case ViewPagerOptionTabOffset:
            return [[self tabOffset] floatValue];
        case ViewPagerOptionTabWidth:
            return [[self tabWidth] floatValue];
        case ViewPagerOptionTabLocation:
            return [[self tabLocation] floatValue];
        case ViewPagerOptionStartFromSecondTab:
            return [[self startFromSecondTab] floatValue];
        case ViewPagerOptionCenterCurrentTab:
            return [[self centerCurrentTab] floatValue];
        default:
            return NAN;
    }
}
- (UIColor *)colorForComponent:(ViewPagerComponent)component {
    
    switch (component) {
        case ViewPagerIndicator:
            return [self indicatorColor];
        case ViewPagerTabsView:
            return [self tabsViewBackgroundColor];
        case ViewPagerContent:
            return [self contentViewBackgroundColor];
        default:
            return [UIColor clearColor];
    }
}

#pragma mark - Private methods
- (void)defaultSettings {
    
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

- (TabView *)tabViewAtIndex:(NSUInteger)index {
    
    if (index >= self.tabCount) {
        return nil;
    }
    
    if ([[self.tabs objectAtIndex:index] isEqual:[NSNull null]]) {

        // Get view from dataSource
        UIView *tabViewContent = [self.dataSource viewPager:self viewForTabAtIndex:index];
        
        // Create TabView and subview the content
        TabView *tabView = [[TabView alloc] initWithFrame:CGRectMake(0.0, 0.0, [self.tabWidth floatValue], [self.tabHeight floatValue])];
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
        
        if ([self.centerCurrentTab boolValue]) {
            
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
            
            frame.origin.x -= [self.tabOffset floatValue];
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

