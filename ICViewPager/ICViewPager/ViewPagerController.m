//
//  ViewPagerController.m
//  ICViewPager
//
//  Created by Ilter Cengiz on 28/08/2013.
//  Copyright (c) 2013 Ilter Cengiz. All rights reserved.
//

#import "ViewPagerController.h"

#pragma mark - Constants and macros
#define kTabViewTag 38
#define kContentViewTag 34
#define IOS_VERSION_7 [[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending

#define kTabHeight 44.0
#define kTabOffset 56.0
#define kTabWidth 128.0
#define kTabLocation 1.0
#define kStartFromSecondTab 0.0
#define kCenterCurrentTab 0.0
#define kFixFormerTabsPositions 0.0
#define kFixLatterTabsPositions 0.0

#define kIndicatorColor [UIColor colorWithRed:178.0/255.0 green:203.0/255.0 blue:57.0/255.0 alpha:0.75]
#define ktabBarBackgroundColor [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:0.75]
#define kContentViewBackgroundColor [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:0.75]

#pragma mark - UIColor+Equality
@interface UIColor (Equality)
- (BOOL)isEqualToColor:(UIColor *)otherColor;
@end

@implementation UIColor (Equality)
// This method checks if two UIColors are the same
// Thanks to @samvermette for this method: http://stackoverflow.com/a/8899384/1931781
- (BOOL)isEqualToColor:(UIColor *)otherColor {
    
    CGColorSpaceRef colorSpaceRGB = CGColorSpaceCreateDeviceRGB();
    
    UIColor *(^convertColorToRGBSpace)(UIColor *) = ^(UIColor *color) {
        if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) == kCGColorSpaceModelMonochrome) {
            const CGFloat *oldComponents = CGColorGetComponents(color.CGColor);
            CGFloat components[4] = {oldComponents[0], oldComponents[0], oldComponents[0], oldComponents[1]};
            return [UIColor colorWithCGColor:CGColorCreate(colorSpaceRGB, components)];
        } else {
            return color;
        }
    };
    
    UIColor *selfColor = convertColorToRGBSpace(self);
    otherColor = convertColorToRGBSpace(otherColor);
    CGColorSpaceRelease(colorSpaceRGB);
    
    return [selfColor isEqual:otherColor];
}
@end

#pragma mark - TabView
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

#pragma mark - ViewPagerController
@interface ViewPagerController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

// Tab and content stuff
@property (nonatomic) UIPageViewController *pageViewController;
@property (nonatomic) UIView *contentView;
@property (nonatomic) UIScrollView *tabBar;

// Helpers
@property (nonatomic, assign) id<UIScrollViewDelegate> actualScrollViewDelegate;

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
@property (nonatomic) NSNumber *fixFormerTabsPositions;
@property (nonatomic) NSNumber *fixLatterTabsPositions;

@property (nonatomic) NSUInteger tabCount;
@property (nonatomic) NSUInteger activeTabIndex;
@property (nonatomic) NSUInteger activeContentIndex;

@property (getter = isAnimatingToTab, assign) BOOL animatingToTab;
@property (getter = isDefaultSetupDone, assign) BOOL defaultSetupDone;

// Colors
@property (nonatomic) UIColor *indicatorColor;
@property (nonatomic) UIColor *tabBarBackgroundColor;
@property (nonatomic) UIColor *contentViewBackgroundColor;

@end

@implementation ViewPagerController

@synthesize tabHeight = _tabHeight;
@synthesize tabOffset = _tabOffset;
@synthesize tabWidth = _tabWidth;
@synthesize tabLocation = _tabLocation;
@synthesize startFromSecondTab = _startFromSecondTab;
@synthesize centerCurrentTab = _centerCurrentTab;
@synthesize fixFormerTabsPositions = _fixFormerTabsPositions;
@synthesize fixLatterTabsPositions = _fixLatterTabsPositions;

#pragma mark - Init
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

#pragma mark - Initializer
- (void)initialize {
    
    /*
     * This method creates a pageViewController to use its view as contentView
     * and a scrollView to use as tabBar
     */
    
    // Create pageViewController to use its view as contentView
    self.pageViewController = ({
        
        UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                                   navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                                                 options:@{UIPageViewControllerOptionInterPageSpacingKey: @(0.0)}];
        
        // Add pageViewController as child
        [self addChildViewController:pageViewController];
        
        // Assign self as delegate of pageView's scrollView to hijack some delegate methods
        // Keep a reference to the actual delegate to respond to other delegate methods as original
        self.actualScrollViewDelegate = ((UIScrollView *)pageViewController.view.subviews[0]).delegate;
        // Set self as new delegate
        ((UIScrollView *)[pageViewController.view.subviews objectAtIndex:0]).delegate = self;
        
        // Assign self as dataSource and delegate of pageViewController
        pageViewController.dataSource = self;
        pageViewController.delegate = self;
        
        // Return pageViewController
        pageViewController;
        
    });
    
    // Get pageViewController's view and assign it as contentView
    // contentView will be added as subview when adjusting its layout in -layoutSubviews method
    self.contentView = ({
        
        // Get pageView and setup it
        UIView *contentView = self.pageViewController.view;
        contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        contentView.tag = kContentViewTag;
        
        // Return pageView to assign it to the contentView
        contentView;
        
    });
    
    // Create tabBar, setup it, and assign it
    // tabBar will be added as subvire when adjusting its layout in -layoutSubviews method
    self.tabBar = ({
        
        // Create and setup tabBar
        UIScrollView *tabBar = [UIScrollView new];
        tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tabBar.scrollsToTop = NO;
        tabBar.showsHorizontalScrollIndicator = NO;
        tabBar.showsVerticalScrollIndicator = NO;
        tabBar.tag = kTabViewTag;
        
        // Return the tabBar
        tabBar;
        
    });
    
}

#pragma mark - View life cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Add tabBar as subview
    [self.view insertSubview:self.tabBar atIndex:0];
    // Adjust tabBar's frame size to calculate the tab's positions correctly
    self.tabBar.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), kTabHeight);
    
    // Add contentView as subview
    [self.view insertSubview:self.contentView atIndex:0];
    
}
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // Do setup if it's not done yet
    if (![self isDefaultSetupDone]) {
        [self setup];
    }
    
}
- (void)viewWillLayoutSubviews {
    // Re-layout sub views
    [self layoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)layoutSubviews {
    
    CGFloat topLayoutGuide = 0.0;
    if (IOS_VERSION_7) {
        topLayoutGuide = 20.0;
        if (self.navigationController && !self.navigationController.navigationBarHidden) {
            topLayoutGuide += self.navigationController.navigationBar.frame.size.height;
        }
    }
    
    self.tabBar.backgroundColor = self.tabBarBackgroundColor;
    self.tabBar.frame = ({
        CGRect frame = self.tabBar.frame;
        frame.origin.x = 0.0;
        frame.origin.y = [self.tabLocation boolValue] ? topLayoutGuide : CGRectGetHeight(self.view.frame) - [self.tabHeight floatValue];
        frame.size.width = CGRectGetWidth(self.view.frame);
        frame.size.height = [self.tabHeight floatValue];
        frame;
    });
    
    self.contentView.backgroundColor = self.contentViewBackgroundColor;
    self.contentView.bounds = self.view.bounds;
    self.contentView.frame = ({
        CGRect frame = self.contentView.frame;
        frame.origin.x = 0.0;
        frame.origin.y = [self.tabLocation boolValue] ? topLayoutGuide + CGRectGetHeight(self.tabBar.frame) : topLayoutGuide;
        frame.size.width = CGRectGetWidth(self.view.frame);
        frame.size.height = CGRectGetHeight(self.view.frame) - (topLayoutGuide + CGRectGetHeight(self.tabBar.frame)) - CGRectGetHeight(self.tabBarController.tabBar.frame);
        frame;
    });
    
}

#pragma mark - IBAction
- (IBAction)handleTapGesture:(id)sender {
    
    // Get the desired page's index
    UITapGestureRecognizer *tapGestureRecognizer = (UITapGestureRecognizer *)sender;
    UIView *tabView = tapGestureRecognizer.view;
    __block NSUInteger index = [self.tabs indexOfObject:tabView];
    
    // Select the tab
    [self selectTabAtIndex:index];
}

#pragma mark - Interface rotation
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    // Re-layout sub views
    [self layoutSubviews];
    
    // Re-align tabs if needed
    self.activeTabIndex = self.activeTabIndex;
}

#pragma mark - Public methods
- (void)reloadData {
    
    // Empty all options and colors
    // So that, ViewPager will reflect the changes
    // Empty all options
    _tabHeight = nil;
    _tabOffset = nil;
    _tabWidth = nil;
    _tabLocation = nil;
    _startFromSecondTab = nil;
    _centerCurrentTab = nil;
    _fixFormerTabsPositions = nil;
    _fixLatterTabsPositions = nil;
    
    // Empty all colors
    _indicatorColor = nil;
    _tabBarBackgroundColor = nil;
    _contentViewBackgroundColor = nil;
    
    // Call to setup again with the updated data
    [self setup];
}
- (void)selectTabAtIndex:(NSUInteger)index {
    self.animatingToTab = YES;
    
    // Set activeTabIndex
    self.activeTabIndex = index;
    
    // Set activeContentIndex
    self.activeContentIndex = index;
    
    // Inform delegate about the change
    if ([self.delegate respondsToSelector:@selector(viewPager:didChangeTabToIndex:)]) {
        [self.delegate viewPager:self didChangeTabToIndex:self.activeTabIndex];
    }
}

- (void)setNeedsReloadOptions {
    
    // If our delegate doesn't respond to our options method, return
    // Otherwise reload options
    if (![self.delegate respondsToSelector:@selector(viewPager:valueForOption:withDefault:)]) {
        return;
    }
    
    // Update these options
    self.tabWidth = [NSNumber numberWithFloat:[self.delegate viewPager:self valueForOption:ViewPagerOptionTabWidth withDefault:kTabWidth]];
    self.tabOffset = [NSNumber numberWithFloat:[self.delegate viewPager:self valueForOption:ViewPagerOptionTabOffset withDefault:kTabOffset]];
    self.centerCurrentTab = [NSNumber numberWithFloat:[self.delegate viewPager:self valueForOption:ViewPagerOptionCenterCurrentTab withDefault:kCenterCurrentTab]];
    self.fixFormerTabsPositions = [NSNumber numberWithFloat:[self.delegate viewPager:self valueForOption:ViewPagerOptionFixFormerTabsPositions withDefault:kFixFormerTabsPositions]];
    self.fixLatterTabsPositions = [NSNumber numberWithFloat:[self.delegate viewPager:self valueForOption:ViewPagerOptionFixLatterTabsPositions withDefault:kFixLatterTabsPositions]];
    
    // We should update contentSize property of our tabBar, so we should recalculate it with the new values
    CGFloat contentSizeWidth = 0;
    
    // Give the standard offset if fixFormerTabsPositions is provided as YES
    if ([self.fixFormerTabsPositions boolValue]) {
        
        // And if the centerCurrentTab is provided as YES fine tune the offset according to it
        if ([self.centerCurrentTab boolValue]) {
            contentSizeWidth = (CGRectGetWidth(self.tabBar.frame) - [self.tabWidth floatValue]) / 2.0;
        } else {
            contentSizeWidth = [self.tabOffset floatValue];
        }
    }
    
    // Update every tab's frame
    for (NSUInteger i = 0; i < self.tabCount; i++) {
        
        UIView *tabView = [self tabViewAtIndex:i];
        
        CGRect frame = tabView.frame;
        frame.origin.x = contentSizeWidth;
        frame.size.width = [self.tabWidth floatValue];
        tabView.frame = frame;
        
        contentSizeWidth += CGRectGetWidth(tabView.frame);
    }
    
    // Extend contentSizeWidth if fixLatterTabsPositions is provided YES
    if ([self.fixLatterTabsPositions boolValue]) {
        
        // And if the centerCurrentTab is provided as YES fine tune the content size according to it
        if ([self.centerCurrentTab boolValue]) {
            contentSizeWidth += (CGRectGetWidth(self.tabBar.frame) - [self.tabWidth floatValue]) / 2.0;
        } else {
            contentSizeWidth += CGRectGetWidth(self.tabBar.frame) - [self.tabWidth floatValue] - [self.tabOffset floatValue];
        }
    }
    
    // Update tabBar's contentSize with the new width
    self.tabBar.contentSize = CGSizeMake(contentSizeWidth, [self.tabHeight floatValue]);
    
}
- (void)setNeedsReloadColors {
    
    // If our delegate doesn't respond to our colors method, return
    // Otherwise reload colors
    if (![self.delegate respondsToSelector:@selector(viewPager:colorForComponent:withDefault:)]) {
        return;
    }
    
    // These colors will be updated
    UIColor *indicatorColor;
    UIColor *tabBarBackgroundColor;
    UIColor *contentViewBackgroundColor;
    
    // Get indicatorColor and check if it is different from the current one
    // If it is, update it
    indicatorColor = [self.delegate viewPager:self colorForComponent:ViewPagerIndicator withDefault:kIndicatorColor];
    
    if (![self.indicatorColor isEqualToColor:indicatorColor]) {
        
        // We will iterate through all of the tabs to update its indicatorColor
        [self.tabs enumerateObjectsUsingBlock:^(TabView *tabView, NSUInteger index, BOOL *stop) {
            tabView.indicatorColor = indicatorColor;
        }];
        
        // Update indicatorColor to check again later
        self.indicatorColor = indicatorColor;
    }
    
    // Get tabBarBackgroundColor and check if it is different from the current one
    // If it is, update it
    tabBarBackgroundColor = [self.delegate viewPager:self colorForComponent:ViewPagerTabBar withDefault:ktabBarBackgroundColor];
    
    if (![self.tabBarBackgroundColor isEqualToColor:tabBarBackgroundColor]) {
        
        // Update it
        self.tabBar.backgroundColor = tabBarBackgroundColor;
        
        // Update tabBarBackgroundColor to check again later
        self.tabBarBackgroundColor = tabBarBackgroundColor;
    }
    
    // Get contentViewBackgroundColor and check if it is different from the current one
    // Yeah update it, too
    contentViewBackgroundColor = [self.delegate viewPager:self colorForComponent:ViewPagerContent withDefault:kContentViewBackgroundColor];
    
    if (![self.contentViewBackgroundColor isEqualToColor:contentViewBackgroundColor]) {
        
        // Yup, update
        self.contentView.backgroundColor = contentViewBackgroundColor;
        
        // Update this, too, to check again later
        self.contentViewBackgroundColor = contentViewBackgroundColor;
    }
    
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
        case ViewPagerTabBar:
            return [self tabBarBackgroundColor];
        case ViewPagerContent:
            return [self contentViewBackgroundColor];
        default:
            return [UIColor clearColor];
    }
}

#pragma mark - Private methods
- (void)setup {
    
    // Get tabCount from dataSource
    self.tabCount = [self.dataSource numberOfTabsForViewPager:self];
    
    // Load tabs
    [self loadTabs];
    
    // Load contents
    [self loadContents];
    
    // Select initial tab
    NSUInteger index = [self.startFromSecondTab boolValue] ? 1 : 0;
    [self selectTabAtIndex:index];
    
    // Set defaultSetupDone as YES
    self.defaultSetupDone = YES;
    
}
- (void)loadTabs {
    
    // Empty tabs if there are any, or create an empty array
    if (self.tabs) {
        // Remove all tabs from scroll view
        [self.tabs enumerateObjectsUsingBlock:^(TabView *tabView, NSUInteger index, BOOL *stop) {
            [tabView removeFromSuperview];
        }];
        // Remove all tabs from the holder array
        [self.tabs removeAllObjects];
    } else {
        // Create an array with capacity of tabCount
        self.tabs = [NSMutableArray arrayWithCapacity:self.tabCount];
    }
    
    // Populate the array with [NSNull null];
    for (NSUInteger i = 0; i < self.tabCount; i++) {
        [self.tabs addObject:[NSNull null]];
    }
    
    // Set contentSize of tabBar to zero
    self.tabBar.contentSize = CGSizeZero;
    
    // Add tabs to tabBar
    // This will hold the width of total scrollable area
    CGFloat contentSizeWidth = 0;
    
    // Give the standard offset if fixFormerTabsPositions is provided as YES
    if ([self.fixFormerTabsPositions boolValue]) {
        // And if the centerCurrentTab is provided as YES fine tune the offset according to it
        if ([self.centerCurrentTab boolValue]) {
            contentSizeWidth = (CGRectGetWidth(self.tabBar.frame) - [self.tabWidth floatValue]) / 2.0;
        } else {
            contentSizeWidth = [self.tabOffset floatValue];
        }
    }
    
    for (NSUInteger i = 0; i < self.tabCount; i++) {
        
        UIView *tabView = [self tabViewAtIndex:i];
        
        tabView.frame = ({
            CGRect frame = tabView.frame;
            frame.origin.x = contentSizeWidth;
            frame.size.width = [self.tabWidth floatValue];
            frame;
        });
        [self.tabBar addSubview:tabView];
        
        // Extend the contentSize by width of tabView
        contentSizeWidth += CGRectGetWidth(tabView.frame);
        
        // Add a tapGestureRecognizer to capture tap events
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [tabView addGestureRecognizer:tapGestureRecognizer];
        
    }
    
    // Extend contentSizeWidth if fixLatterTabsPositions is provided YES
    if ([self.fixLatterTabsPositions boolValue]) {
        // And if the centerCurrentTab is provided as YES fine tune the content size according to it
        if ([self.centerCurrentTab boolValue]) {
            contentSizeWidth += (CGRectGetWidth(self.tabBar.frame) - [self.tabWidth floatValue]) / 2.0;
        } else {
            contentSizeWidth += CGRectGetWidth(self.tabBar.frame) - [self.tabWidth floatValue] - [self.tabOffset floatValue];
        }
    }
    
    // Adjust contentSize of tabBar
    self.tabBar.contentSize = CGSizeMake(contentSizeWidth, [self.tabHeight floatValue]);
    
}
- (void)loadContents {
    
    // Empty contents if there are any, or create an empty array
    if (self.contents) {
        // Remove all contents from the holder array
        [self.contents removeAllObjects];
    } else {
        // Create an array with capacity of tabCount
        self.contents = [NSMutableArray arrayWithCapacity:self.tabCount];
    }
    
    // Populate the array with [NSNull null];
    for (NSUInteger i = 0; i < self.tabCount; i++) {
        [self.contents addObject:[NSNull null]];
    }
    
}

- (TabView *)tabViewAtIndex:(NSUInteger)index {
    
    if (index >= self.tabCount) {
        return nil;
    }
    
    if ([[self.tabs objectAtIndex:index] isEqual:[NSNull null]]) {

        // Get view from dataSource
        UIView *tabViewContent = [self.dataSource viewPager:self viewForTabAtIndex:index];
        tabViewContent.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
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
            UIView *pageView = [self.view viewWithTag:kContentViewTag];
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
    
    // Select tab
    NSUInteger index = [self indexForViewController:viewController];
    [self selectTabAtIndex:index];
}

#pragma mark - UIScrollViewDelegate, Responding to Scrolling and Dragging
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([self.actualScrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.actualScrollViewDelegate scrollViewDidScroll:scrollView];
    }
    
    if (![self isAnimatingToTab]) {
        UIView *tabView = [self tabViewAtIndex:self.activeTabIndex];
        
        // Get the related tab view position
        CGRect frame = tabView.frame;
        
        CGFloat movedRatio = (scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame)) - 1;
        frame.origin.x += movedRatio * CGRectGetWidth(frame);
        
        if ([self.centerCurrentTab boolValue]) {
            
            frame.origin.x += (frame.size.width / 2);
            frame.origin.x -= CGRectGetWidth(self.tabBar.frame) / 2;
            frame.size.width = CGRectGetWidth(self.tabBar.frame);
            
            if (frame.origin.x < 0) {
                frame.origin.x = 0;
            }
            
            if ((frame.origin.x + frame.size.width) > self.tabBar.contentSize.width) {
                frame.origin.x = (self.tabBar.contentSize.width - CGRectGetWidth(self.tabBar.frame));
            }
        } else {
            
            frame.origin.x -= [self.tabOffset floatValue];
            frame.size.width = CGRectGetWidth(self.tabBar.frame);
        }
        
        [self.tabBar scrollRectToVisible:frame animated:NO];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.actualScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.actualScrollViewDelegate scrollViewWillBeginDragging:scrollView];
    }
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([self.actualScrollViewDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.actualScrollViewDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([self.actualScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.actualScrollViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    if ([self.actualScrollViewDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [self.actualScrollViewDelegate scrollViewShouldScrollToTop:scrollView];
    }
    return NO;
}
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if ([self.actualScrollViewDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [self.actualScrollViewDelegate scrollViewDidScrollToTop:scrollView];
    }
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([self.actualScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.actualScrollViewDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.actualScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.actualScrollViewDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

#pragma mark - UIScrollViewDelegate, Managing Zooming
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if ([self.actualScrollViewDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [self.actualScrollViewDelegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if ([self.actualScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [self.actualScrollViewDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if ([self.actualScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [self.actualScrollViewDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if ([self.actualScrollViewDelegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [self.actualScrollViewDelegate scrollViewDidZoom:scrollView];
    }
}

#pragma mark - UIScrollViewDelegate, Responding to Scrolling Animations
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self.actualScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.actualScrollViewDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

#pragma mark - Getters
- (NSNumber *)tabHeight {
    
    if (!_tabHeight) {
        CGFloat value = kTabHeight;
        if ([self.delegate respondsToSelector:@selector(viewPager:valueForOption:withDefault:)])
            value = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabHeight withDefault:value];
        self.tabHeight = [NSNumber numberWithFloat:value];
    }
    return _tabHeight;
}
- (NSNumber *)tabOffset {
    
    if (!_tabOffset) {
        CGFloat value = kTabOffset;
        if ([self.delegate respondsToSelector:@selector(viewPager:valueForOption:withDefault:)])
            value = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabOffset withDefault:value];
        self.tabOffset = [NSNumber numberWithFloat:value];
    }
    return _tabOffset;
}
- (NSNumber *)tabWidth {
    
    if (!_tabWidth) {
        CGFloat value = kTabWidth;
        if ([self.delegate respondsToSelector:@selector(viewPager:valueForOption:withDefault:)])
            value = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabWidth withDefault:value];
        self.tabWidth = [NSNumber numberWithFloat:value];
    }
    return _tabWidth;
}
- (NSNumber *)tabLocation {
    
    if (!_tabLocation) {
        CGFloat value = kTabLocation;
        if ([self.delegate respondsToSelector:@selector(viewPager:valueForOption:withDefault:)])
            value = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabLocation withDefault:value];
        self.tabLocation = [NSNumber numberWithFloat:value];
    }
    return _tabLocation;
}
- (NSNumber *)startFromSecondTab {
    
    if (!_startFromSecondTab) {
        CGFloat value = kStartFromSecondTab;
        if ([self.delegate respondsToSelector:@selector(viewPager:valueForOption:withDefault:)])
            value = [self.delegate viewPager:self valueForOption:ViewPagerOptionStartFromSecondTab withDefault:value];
        self.startFromSecondTab = [NSNumber numberWithFloat:value];
    }
    return _startFromSecondTab;
}
- (NSNumber *)centerCurrentTab {
    
    if (!_centerCurrentTab) {
        CGFloat value = kCenterCurrentTab;
        if ([self.delegate respondsToSelector:@selector(viewPager:valueForOption:withDefault:)])
            value = [self.delegate viewPager:self valueForOption:ViewPagerOptionCenterCurrentTab withDefault:value];
        self.centerCurrentTab = [NSNumber numberWithFloat:value];
    }
    return _centerCurrentTab;
}
- (NSNumber *)fixFormerTabsPositions {
    
    if (!_fixFormerTabsPositions) {
        CGFloat value = kFixFormerTabsPositions;
        if ([self.delegate respondsToSelector:@selector(viewPager:valueForOption:withDefault:)])
            value = [self.delegate viewPager:self valueForOption:ViewPagerOptionFixFormerTabsPositions withDefault:value];
        self.fixFormerTabsPositions = [NSNumber numberWithFloat:value];
    }
    return _fixFormerTabsPositions;
}
- (NSNumber *)fixLatterTabsPositions {
    
    if (!_fixLatterTabsPositions) {
        CGFloat value = kFixLatterTabsPositions;
        if ([self.delegate respondsToSelector:@selector(viewPager:valueForOption:withDefault:)])
            value = [self.delegate viewPager:self valueForOption:ViewPagerOptionFixLatterTabsPositions withDefault:value];
        self.fixLatterTabsPositions = [NSNumber numberWithFloat:value];
    }
    return _fixLatterTabsPositions;
}

- (UIColor *)indicatorColor {
    
    if (!_indicatorColor) {
        UIColor *color = kIndicatorColor;
        if ([self.delegate respondsToSelector:@selector(viewPager:colorForComponent:withDefault:)]) {
            color = [self.delegate viewPager:self colorForComponent:ViewPagerIndicator withDefault:color];
        }
        self.indicatorColor = color;
    }
    return _indicatorColor;
}
- (UIColor *)tabBarBackgroundColor {
    
    if (!_tabBarBackgroundColor) {
        UIColor *color = ktabBarBackgroundColor;
        if ([self.delegate respondsToSelector:@selector(viewPager:colorForComponent:withDefault:)]) {
            color = [self.delegate viewPager:self colorForComponent:ViewPagerTabBar withDefault:color];
        }
        self.tabBarBackgroundColor = color;
    }
    return _tabBarBackgroundColor;
}
- (UIColor *)contentViewBackgroundColor {
    
    if (!_contentViewBackgroundColor) {
        UIColor *color = kContentViewBackgroundColor;
        if ([self.delegate respondsToSelector:@selector(viewPager:colorForComponent:withDefault:)]) {
            color = [self.delegate viewPager:self colorForComponent:ViewPagerContent withDefault:color];
        }
        self.contentViewBackgroundColor = color;
    }
    return _contentViewBackgroundColor;
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
        tabLocation = [tabLocation boolValue] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
    
    _tabLocation = tabLocation;
}
- (void)setStartFromSecondTab:(NSNumber *)startFromSecondTab {
    
    if ([startFromSecondTab floatValue] != 1.0 && [startFromSecondTab floatValue] != 0.0)
        startFromSecondTab = [startFromSecondTab boolValue] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
    
    _startFromSecondTab = startFromSecondTab;
}
- (void)setCenterCurrentTab:(NSNumber *)centerCurrentTab {
    
    if ([centerCurrentTab floatValue] != 1.0 && [centerCurrentTab floatValue] != 0.0)
        centerCurrentTab = [centerCurrentTab boolValue] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
    
    _centerCurrentTab = centerCurrentTab;
}
- (void)setFixFormerTabsPositions:(NSNumber *)fixFormerTabsPositions {
    
    if ([fixFormerTabsPositions floatValue] != 1.0 && [fixFormerTabsPositions floatValue] != 0.0)
        fixFormerTabsPositions = [fixFormerTabsPositions boolValue] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
    
    _fixFormerTabsPositions = fixFormerTabsPositions;
}
- (void)setFixLatterTabsPositions:(NSNumber *)fixLatterTabsPositions {
    
    if ([fixLatterTabsPositions floatValue] != 1.0 && [fixLatterTabsPositions floatValue] != 0.0)
        fixLatterTabsPositions = [fixLatterTabsPositions boolValue] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
    
    _fixLatterTabsPositions = fixLatterTabsPositions;
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
    
    // Bring tab to active position
    // Position the tab in center if centerCurrentTab option is provided as YES
    UIView *tabView = [self tabViewAtIndex:self.activeTabIndex];
    CGRect frame = tabView.frame;
    
    if ([self.centerCurrentTab boolValue]) {
        
        frame.origin.x += (CGRectGetWidth(frame) / 2);
        frame.origin.x -= CGRectGetWidth(self.tabBar.frame) / 2;
        frame.size.width = CGRectGetWidth(self.tabBar.frame);
        
        if (frame.origin.x < 0) {
            frame.origin.x = 0;
        }
        
        if ((frame.origin.x + CGRectGetWidth(frame)) > self.tabBar.contentSize.width) {
            frame.origin.x = (self.tabBar.contentSize.width - CGRectGetWidth(self.tabBar.frame));
        }
    } else {
        
        frame.origin.x -= [self.tabOffset floatValue];
        frame.size.width = CGRectGetWidth(self.tabBar.frame);
    }
    
    [self.tabBar scrollRectToVisible:frame animated:YES];
}
- (void)setActiveContentIndex:(NSUInteger)activeContentIndex {
    
    // Get the desired viewController
    UIViewController *viewController = [self viewControllerAtIndex:activeContentIndex];
    
    if (!viewController) {
        viewController = [[UIViewController alloc] init];
        viewController.view = [[UIView alloc] init];
        viewController.view.backgroundColor = [UIColor clearColor];
    }
    
    // __weak pageViewController to be used in blocks to prevent retaining strong reference to self
    __weak UIPageViewController *weakPageViewController = self.pageViewController;
    __weak ViewPagerController *weakSelf = self;
    
    if (activeContentIndex == self.activeContentIndex) {
        
        [self.pageViewController setViewControllers:@[viewController]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO
                                         completion:nil];
        
    } else if (!(activeContentIndex + 1 == self.activeContentIndex || activeContentIndex - 1 == self.activeContentIndex)) {
        
        [self.pageViewController setViewControllers:@[viewController]
                                          direction:(activeContentIndex < self.activeContentIndex) ? UIPageViewControllerNavigationDirectionReverse : UIPageViewControllerNavigationDirectionForward
                                           animated:YES
                                         completion:^(BOOL completed) {
                                             
                                             weakSelf.animatingToTab = NO;
                                             
                                             // Set the current page again to obtain synchronisation between tabs and content
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [weakPageViewController setViewControllers:@[viewController]
                                                                                  direction:(activeContentIndex < weakSelf.activeContentIndex) ? UIPageViewControllerNavigationDirectionReverse : UIPageViewControllerNavigationDirectionForward
                                                                                   animated:NO
                                                                                 completion:nil];
                                             });
                                         }];
        
    } else {
        
        [self.pageViewController setViewControllers:@[viewController]
                                          direction:(activeContentIndex < self.activeContentIndex) ? UIPageViewControllerNavigationDirectionReverse : UIPageViewControllerNavigationDirectionForward
                                           animated:YES
                                         completion:nil];
    }
    
    // Clean out of sight contents
    NSInteger index;
    index = self.activeContentIndex - 1;
    if (index >= 0 &&
        index != activeContentIndex &&
        index != activeContentIndex - 1)
    {
        [self.contents replaceObjectAtIndex:index withObject:[NSNull null]];
    }
    index = self.activeContentIndex;
    if (index != activeContentIndex - 1 &&
        index != activeContentIndex &&
        index != activeContentIndex + 1)
    {
        [self.contents replaceObjectAtIndex:index withObject:[NSNull null]];
    }
    index = self.activeContentIndex + 1;
    if (index < self.contents.count &&
        index != activeContentIndex &&
        index != activeContentIndex + 1)
    {
        [self.contents replaceObjectAtIndex:index withObject:[NSNull null]];
    }
    
    _activeContentIndex = activeContentIndex;
}

@end

