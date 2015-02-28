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

static const CGFloat kTabHeight = 44.0f;
static const CGFloat kTabOffset = 56.0f;
static const CGFloat kTabWidth = 128.0;
static const BOOL kStartFromSecondTab = NO;
static const BOOL kCenterCurrentTab = NO;
static const BOOL kFixFormerTabsPositions = NO;
static const BOOL kFixLatterTabsPositions = NO;
static const ViewPagerTabLocation kTabLocation = ViewPagerTabLocationTop;

#define kIndicatorColor [UIColor colorWithRed:178.0/255.0 green:203.0/255.0 blue:57.0/255.0 alpha:0.75]
#define kTabsViewBackgroundColor [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:0.75]
#define kContentViewBackgroundColor [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:0.75]

#pragma mark - UIColor+Equality

@interface UIColor (Equality)
- (BOOL)isEqualToColor:(UIColor *)otherColor;
@end

@implementation UIColor (Equality)
// This method checks if two UIColors are the same
// Thanks to @samvermette for this method: http://stackoverflow.com/a/8899384/1931781
- (BOOL)isEqualToColor:(UIColor *)otherColor
{

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
@property(nonatomic, getter = isSelected) BOOL selected;
@property(nonatomic) UIColor *indicatorColor;
@end

@implementation TabView
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}


- (void)setSelected:(BOOL)selected
{
	_selected = selected;
	// Update view as state changed
	[self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{

	UIBezierPath *bezierPath;

	// Draw top line
	bezierPath = [UIBezierPath bezierPath];
	[bezierPath moveToPoint:CGPointMake(0.0, 0.0)];
	[bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), 0.0)];
	[[UIColor colorWithWhite:197.0f / 255.0f alpha:0.75] setStroke];
	[bezierPath setLineWidth:1.0];
	[bezierPath stroke];

	// Draw bottom line
	bezierPath = [UIBezierPath bezierPath];
	[bezierPath moveToPoint:CGPointMake(0.0, CGRectGetHeight(rect))];
	[bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect))];
	[[UIColor colorWithWhite:197.0f / 255.0f alpha:0.75] setStroke];
	[bezierPath setLineWidth:1.0];
	[bezierPath stroke];

	// Draw an indicator line if tab is selected
	if (self.selected) {

		bezierPath = [UIBezierPath bezierPath];

		// Draw the indicator
		[bezierPath moveToPoint:CGPointMake(0.0, CGRectGetHeight(rect) - 1.0f)];
		[bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect) - 1.0f)];
		[bezierPath setLineWidth:5.0];
		[self.indicatorColor setStroke];
		[bezierPath stroke];
	}
}
@end

#pragma mark - ViewPagerController

@interface ViewPagerController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

// Tab and content stuff
@property UIScrollView *tabsView;
@property UIView *contentView;
@property UIPageViewController *pageViewController;
@property(assign) id <UIScrollViewDelegate> actualDelegate;
// Tab and content cache
@property NSMutableArray *tabs;
@property NSMutableArray *contents;
@property(nonatomic) NSUInteger tabCount;
@property(nonatomic) NSUInteger activeTabIndex;
@property(nonatomic) NSUInteger activeContentIndex;
@property(getter = isAnimatingToTab, assign) BOOL animatingToTab;
@property(getter = isDefaultSetupDone, assign) BOOL defaultSetupDone;


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


- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self defaultSettings];
	}
	return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		[self defaultSettings];
	}
	return self;
}


#pragma mark - View life cycle


- (void)viewDidLoad
{
	[super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
{

	[super viewWillAppear:animated];

	// Do setup if it's not done yet
	if (![self isDefaultSetupDone]) {
		[self defaultSetup];
	}
}


- (void)viewWillLayoutSubviews
{

	// Re-layout sub views
	[self layoutSubviews];
}


- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}


- (void)layoutSubviews
{

	CGFloat topLayoutGuide = 0.0;
	if (IOS_VERSION_7) {
		topLayoutGuide = 20.0;
		if (self.navigationController && !self.navigationController.navigationBarHidden) {
			topLayoutGuide += self.navigationController.navigationBar.frame.size.height;
		}
	}

	CGRect frame = self.tabsView.frame;
	frame.origin.x = 0.0;
	frame.origin.y = self.tabLocation == ViewPagerTabLocationTop ? topLayoutGuide : CGRectGetHeight(self.view.frame) - self.tabHeight;
	frame.size.width = CGRectGetWidth(self.view.frame);
	frame.size.height = self.tabHeight;
	self.tabsView.frame = frame;

	frame = self.contentView.frame;
	frame.origin.x = 0.0;
	frame.origin.y = self.tabLocation == ViewPagerTabLocationTop ? topLayoutGuide + CGRectGetHeight(self.tabsView.frame) : topLayoutGuide;
	frame.size.width = CGRectGetWidth(self.view.frame);
	frame.size.height = CGRectGetHeight(self.view.frame) - (topLayoutGuide + CGRectGetHeight(self.tabsView.frame)) - (self.tabBarController.tabBar.hidden ? 0 : CGRectGetHeight(self.tabBarController.tabBar.frame));
	self.contentView.frame = frame;
}


#pragma mark - IBAction


- (IBAction)handleTapGesture:(id)sender
{

	// Get the desired page's index
	UITapGestureRecognizer *tapGestureRecognizer = (UITapGestureRecognizer *) sender;
	UIView *tabView = tapGestureRecognizer.view;
	__block NSUInteger index = [self.tabs indexOfObject:tabView];

	//if Tap is not selected Tab(new Tab)
	if (self.activeTabIndex != index) {
		// Select the tab
		[self selectTabAtIndex:index didSwipe:NO];
	}
}


#pragma mark - Interface rotation


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

	// Re-layout sub views
	[self layoutSubviews];

	// Re-align tabs if needed
	self.activeTabIndex = self.activeTabIndex;
}


#pragma mark - Setters


- (void)setTabHeight:(CGFloat)tabHeight
{
	if (tabHeight < 4.0)
		tabHeight = 4.0f;
	else if (tabHeight > CGRectGetHeight(self.view.frame))
		tabHeight = CGRectGetHeight(self.view.frame);

	_tabHeight = tabHeight;
}


- (void)setTabOffset:(CGFloat)tabOffset
{

	if (tabOffset < 0.0)
		tabOffset = 0.0F;
	else if (tabOffset > CGRectGetWidth(self.view.frame) - self.tabWidth)
		tabOffset = CGRectGetWidth(self.view.frame) - self.tabWidth;

	_tabOffset = tabOffset;
}


- (void)setTabWidth:(CGFloat)tabWidth
{

	if (tabWidth < 4.0)
		tabWidth = 4.0F;
	else if (tabWidth > CGRectGetWidth(self.view.frame))
		tabWidth = CGRectGetWidth(self.view.frame);

	_tabWidth = tabWidth;
}


- (void)setActiveTabIndex:(NSUInteger)activeTabIndex
{

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


- (void)setActiveContentIndex:(NSUInteger)activeContentIndex
{

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
										 completion:^(BOOL completed) {
											 weakSelf.animatingToTab = NO;
										 }];

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
										 completion:^(BOOL completed) {
											 weakSelf.animatingToTab = NO;
										 }];
	}

	// Clean out of sight contents
	NSInteger index;
	NSLog(@"1. index: %d", index);
	index = self.activeContentIndex - 1;
	NSLog(@"2. index: %d", index);
	if (index >= 0 &&
			index != activeContentIndex &&
			index != activeContentIndex - 1) {
		self.contents[index] = NSNull.null;
	}
	index = self.activeContentIndex;
	if (index != activeContentIndex - 1 &&
			index != activeContentIndex &&
			index != activeContentIndex + 1) {
		self.contents[index] = [NSNull null];
	}
	index = self.activeContentIndex + 1;
	if (index < self.contents.count &&
			index != activeContentIndex &&
			index != activeContentIndex + 1) {
		self.contents[index] = [NSNull null];
	}

	_activeContentIndex = activeContentIndex;
}


#pragma mark - Getters


- (CGFloat)tabHeight
{
	if (!_tabHeight) _tabHeight = kTabHeight;
	return _tabHeight;
}


- (CGFloat)tabOffset
{

	if (!_tabOffset) _tabOffset = kTabOffset;

	return _tabOffset;
}


- (CGFloat)tabWidth
{
	if (!_tabWidth) _tabOffset = kTabWidth;
	return _tabWidth;
}


- (ViewPagerTabLocation)tabLocation
{
	if (!_tabLocation) _tabLocation = kTabLocation;
	return _tabLocation;
}


- (BOOL)startFromSecondTab
{
	if (!_startFromSecondTab) _startFromSecondTab = kStartFromSecondTab;
	return _startFromSecondTab;
}


- (BOOL)centerCurrentTab
{
	if (!_centerCurrentTab) _centerCurrentTab = kCenterCurrentTab;
	return _centerCurrentTab;
}


- (BOOL)fixFormerTabsPositions
{
	if (!_fixFormerTabsPositions) _fixFormerTabsPositions = kFixFormerTabsPositions;
	return _fixFormerTabsPositions;
}


- (BOOL)fixLatterTabsPositions
{
	if (!_fixLatterTabsPositions) _fixLatterTabsPositions = kFixLatterTabsPositions;
	return _fixLatterTabsPositions;
}


- (UIColor *)indicatorColor
{
	if (!_indicatorColor) _indicatorColor = kIndicatorColor;
	return _indicatorColor;
}


- (UIColor *)tabsViewBackgroundColor
{
	if (!_tabsViewBackgroundColor) _tabsViewBackgroundColor = kTabsViewBackgroundColor;
	return _tabsViewBackgroundColor;
}


- (UIColor *)contentViewBackgroundColor
{
	if (!_contentViewBackgroundColor) _contentViewBackgroundColor = kContentViewBackgroundColor;
	return _contentViewBackgroundColor;
}


#pragma mark - Public methods


- (void)reloadData
{
	// Call to setup again with the updated data
	[self defaultSetup];
}


- (void)selectTabAtIndex:(NSUInteger)index
{
	[self selectTabAtIndex:index didSwipe:NO];
}


- (void)selectTabAtIndex:(NSUInteger)index didSwipe:(BOOL)didSwipe
{
	if (index >= self.tabCount) {
		return;
	}

	self.animatingToTab = YES;

	// Keep a reference to previousIndex in case it is needed for the delegate
	NSUInteger previousIndex = self.activeTabIndex;

	// Set activeTabIndex
	self.activeTabIndex = index;

	// Set activeContentIndex
	self.activeContentIndex = index;

	// Inform delegate about the change
	if ([self.delegate respondsToSelector:@selector(viewPager:didChangeTabToIndex:)]) {
		[self.delegate viewPager:self didChangeTabToIndex:self.activeTabIndex];
	}
	else if ([self.delegate respondsToSelector:@selector(viewPager:didChangeTabToIndex:fromIndex:)]) {
		[self.delegate viewPager:self didChangeTabToIndex:self.activeTabIndex fromIndex:previousIndex];
	}
	else if ([self.delegate respondsToSelector:@selector(viewPager:didChangeTabToIndex:fromIndex:didSwipe:)]) {
		[self.delegate viewPager:self didChangeTabToIndex:self.activeTabIndex fromIndex:previousIndex didSwipe:didSwipe];
	}
}


- (void)setNeedsReloadOptions
{
	// We should update contentSize property of our tabsView, so we should recalculate it with the new values
	CGFloat contentSizeWidth = 0;

	// Give the standard offset if fixFormerTabsPositions is provided as YES
	if (self.fixFormerTabsPositions) {

		// And if the centerCurrentTab is provided as YES fine tune the offset according to it
		if (self.centerCurrentTab) {
			contentSizeWidth = (CGRectGetWidth(self.tabsView.frame) - self.tabWidth) / 2.0f;
		} else {
			contentSizeWidth = self.tabOffset;
		}
	}

	// Update every tab's frame
	for (NSUInteger i = 0; i < self.tabCount; i++) {

		UIView *tabView = [self tabViewAtIndex:i];
		CGRect frame = tabView.frame;
		frame.origin.x = contentSizeWidth;
		frame.size.width = self.tabWidth;
		tabView.frame = frame;

		contentSizeWidth += CGRectGetWidth(tabView.frame);
	}

	// Extend contentSizeWidth if fixLatterTabsPositions is provided YES
	if (self.fixLatterTabsPositions) {

		// And if the centerCurrentTab is provided as YES fine tune the content size according to it
		if (self.centerCurrentTab) {
			contentSizeWidth += (CGRectGetWidth(self.tabsView.frame) - self.tabWidth) / 2.0;
		} else {
			contentSizeWidth += CGRectGetWidth(self.tabsView.frame) - self.tabWidth - self.tabOffset;
		}
	}

	// Update tabsView's contentSize with the new width
	self.tabsView.contentSize = CGSizeMake(contentSizeWidth, self.tabHeight);

}


- (void)setNeedsReloadColors
{
	// We will iterate through all of the tabs to update its indicatorColor
	[self.tabs enumerateObjectsUsingBlock:^(TabView *tabView, NSUInteger index, BOOL *stop) {
		tabView.indicatorColor = self.indicatorColor;
	}];

	// Update indicatorColor to check again later
	self.indicatorColor = self.indicatorColor;

	// Update it
	self.tabsView.backgroundColor = self.tabsViewBackgroundColor;

	// Update tabsViewBackgroundColor to check again later
	self.tabsViewBackgroundColor = self.tabsViewBackgroundColor;


	// Yup, update
	self.contentView.backgroundColor = self.contentViewBackgroundColor;

	// Update this, too, to check again later
	self.contentViewBackgroundColor = self.contentViewBackgroundColor;
}


#pragma mark - Private methods


- (void)defaultSettings
{
	// pageViewController
	self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
															  navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
																			options:nil];
	[self addChildViewController:self.pageViewController];

	// Setup some forwarding events to hijack the scrollView
	// Keep a reference to the actual delegate
	self.actualDelegate = ((UIScrollView *) self.pageViewController.view.subviews[0]).delegate;
	// Set self as new delegate
	((UIScrollView *) self.pageViewController.view.subviews[0]).delegate = self;

	self.pageViewController.dataSource = self;
	self.pageViewController.delegate = self;

	self.animatingToTab = NO;
	self.defaultSetupDone = NO;
}


- (void)defaultSetup
{
	// Empty tabs and contents
	for (UIView *tabView in self.tabs) {
		[tabView removeFromSuperview];
	}
	self.tabsView.contentSize = CGSizeZero;

	[self.tabs removeAllObjects];
	[self.contents removeAllObjects];

	// Get tabCount from dataSource
	self.tabCount = [self.dataSource numberOfTabsForViewPager:self];

	// Populate arrays with [NSNull null];
	self.tabs = [NSMutableArray arrayWithCapacity:self.tabCount];
	for (NSUInteger i = 0; i < self.tabCount; i++) {
		[self.tabs addObject:[NSNull null]];
	}

	self.contents = [NSMutableArray arrayWithCapacity:self.tabCount];
	for (NSUInteger i = 0; i < self.tabCount; i++) {
		[self.contents addObject:[NSNull null]];
	}

	// Add tabsView
	self.tabsView = (UIScrollView *) [self.view viewWithTag:kTabViewTag];

	if (!self.tabsView) {

		self.tabsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), self.tabHeight)];
		self.tabsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.tabsView.backgroundColor = self.tabsViewBackgroundColor;
		self.tabsView.scrollsToTop = NO;
		self.tabsView.showsHorizontalScrollIndicator = NO;
		self.tabsView.showsVerticalScrollIndicator = NO;
		self.tabsView.tag = kTabViewTag;

		[self.view insertSubview:self.tabsView atIndex:0];
	}

	// Add tab views to _tabsView
	CGFloat contentSizeWidth = 0;

	// Give the standard offset if fixFormerTabsPositions is provided as YES
	if (self.fixFormerTabsPositions) {

		// And if the centerCurrentTab is provided as YES fine tune the offset according to it
		if (self.centerCurrentTab) {
			contentSizeWidth = (CGRectGetWidth(self.tabsView.frame) - self.tabWidth) / 2.0f;
		} else {
			contentSizeWidth = self.tabOffset;
		}
	}

	for (NSUInteger i = 0; i < self.tabCount; i++) {

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

	// Extend contentSizeWidth if fixLatterTabsPositions is provided YES
	if (self.fixLatterTabsPositions) {

		// And if the centerCurrentTab is provided as YES fine tune the content size according to it
		if (self.centerCurrentTab) {
			contentSizeWidth += (CGRectGetWidth(self.tabsView.frame) - self.tabWidth) / 2.0;
		} else {
			contentSizeWidth += CGRectGetWidth(self.tabsView.frame) - self.tabWidth - self.tabOffset;
		}
	}

	self.tabsView.contentSize = CGSizeMake(contentSizeWidth, self.tabHeight);

	// Add contentView
	self.contentView = [self.view viewWithTag:kContentViewTag];

	if (!self.contentView) {

		self.contentView = self.pageViewController.view;
		self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		self.contentView.backgroundColor = self.contentViewBackgroundColor;
		self.contentView.bounds = self.view.bounds;
		self.contentView.tag = kContentViewTag;

		[self.view insertSubview:self.contentView atIndex:0];
	}

	// Select starting tab
	NSUInteger index = self.startFromSecondTab ? 1 : 0;
	[self selectTabAtIndex:index didSwipe:NO];

	// Set setup done
	self.defaultSetupDone = YES;
}


- (TabView *)tabViewAtIndex:(NSUInteger)index
{
	if (index >= self.tabCount) {
		return nil;
	}

	if ([self.tabs[index] isEqual:[NSNull null]]) {

		// Get view from dataSource
		UIView *tabViewContent = [self.dataSource viewPager:self viewForTabAtIndex:index];
		tabViewContent.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

		// Create TabView and subview the content
		TabView *tabView = [[TabView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tabWidth, self.tabHeight)];
		[tabView addSubview:tabViewContent];
		[tabView setClipsToBounds:YES];
		[tabView setIndicatorColor:self.indicatorColor];

		tabViewContent.center = tabView.center;

		// Replace the null object with tabView
		self.tabs[index] = tabView;
	}

	return self.tabs[index];
}


- (NSUInteger)indexForTabView:(UIView *)tabView
{
	return [self.tabs indexOfObject:tabView];
}


- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
	if (index >= self.tabCount) {
		return nil;
	}

	if ([self.contents[index] isEqual:[NSNull null]]) {

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

		self.contents[index] = viewController;
	}

	return self.contents[index];
}


- (NSUInteger)indexForViewController:(UIViewController *)viewController
{
	return [self.contents indexOfObject:viewController];
}


#pragma mark - UIPageViewControllerDataSource


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
	NSUInteger index = [self indexForViewController:viewController];
	index++;
	return [self viewControllerAtIndex:index];
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
	NSUInteger index = [self indexForViewController:viewController];
	index--;
	return [self viewControllerAtIndex:index];
}


#pragma mark - UIPageViewControllerDelegate


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
	UIViewController *viewController = self.pageViewController.viewControllers[0];

	NSLog(@"Content Count: %d", self.contents.count);
	// Select tab
	NSUInteger index = [self indexForViewController:viewController];
	[self selectTabAtIndex:index didSwipe:YES];
}


#pragma mark - UIScrollViewDelegate, Responding to Scrolling and Dragging


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
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


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	if ([self.actualDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
		[self.actualDelegate scrollViewWillBeginDragging:scrollView];
	}
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
	if ([self.actualDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
		[self.actualDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
	}
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if ([self.actualDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
		[self.actualDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
	}
}


- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
	if ([self.actualDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
		return [self.actualDelegate scrollViewShouldScrollToTop:scrollView];
	}
	return NO;
}


- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
	if ([self.actualDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
		[self.actualDelegate scrollViewDidScrollToTop:scrollView];
	}
}


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
	if ([self.actualDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
		[self.actualDelegate scrollViewWillBeginDecelerating:scrollView];
	}
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if ([self.actualDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
		[self.actualDelegate scrollViewDidEndDecelerating:scrollView];
	}
}


#pragma mark - UIScrollViewDelegate, Managing Zooming


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	if ([self.actualDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
		return [self.actualDelegate viewForZoomingInScrollView:scrollView];
	}
	return nil;
}


- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
	if ([self.actualDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
		[self.actualDelegate scrollViewWillBeginZooming:scrollView withView:view];
	}
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
	if ([self.actualDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
		[self.actualDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
	}
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	if ([self.actualDelegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
		[self.actualDelegate scrollViewDidZoom:scrollView];
	}
}


#pragma mark - UIScrollViewDelegate, Responding to Scrolling Animations


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	if ([self.actualDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
		[self.actualDelegate scrollViewDidEndScrollingAnimation:scrollView];
	}
}

@end

