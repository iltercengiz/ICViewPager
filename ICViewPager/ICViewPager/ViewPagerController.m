//
//  ViewPagerController.m
//  ICViewPager
//
//  Created by Ilter Cengiz on 28/08/2013.
//  Copyright (c) 2013 Ilter Cengiz. All rights reserved.
//

#import "ViewPagerController.h"

#define kDefaultTabHeight 49.0 // iOS's default tab height
#define kDefaultTabOffset 64.0 // Offset of the second and further tabs' from left
#define kDefaultTabWidth 96.0

#define kDefaultTabLocation 1.0 // 1.0: Top, 0.0: Bottom

#define kPageViewTag 34

@interface ViewPagerController () <UIGestureRecognizerDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property UIPageViewController *pageViewController;

@property UIScrollView *tabsView;

@property NSMutableArray *tabs;
@property NSMutableArray *contents;

@property NSUInteger tabCount;

@property NSUInteger activeTabIndex;

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
	
    [self reloadData];
    
    for (UIGestureRecognizer *gestureRecognizer in self.pageViewController.view.gestureRecognizers) {
        gestureRecognizer.delegate = self;
    }
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGestureRecognizer.delegate = self;
    [self.pageViewController.view addGestureRecognizer:panGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)handlePanGesture:(id)sender {
    
    UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)sender;
    
    CGPoint translation = [panGestureRecognizer translationInView:self.pageViewController.view];
//    NSLog(@"X: %f Y: %f", translation.x, translation.y);
}
- (IBAction)handleTapGesture:(id)sender {
    
    UITapGestureRecognizer *tapGestureRecognizer = (UITapGestureRecognizer *)sender;
    UIView *tabView = tapGestureRecognizer.view;
    NSUInteger index = [_tabs indexOfObject:tabView];
    
//    NSLog(@"Tab #%i tapped!", index);
        
    if (index < self.activeTabIndex) {
        [_pageViewController setViewControllers:@[[self viewControllerAtIndex:index]]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:YES
                                     completion:nil];
        NSLog(@"%@", self.pageViewController.viewControllers);
        for (UIViewController *viewController in self.pageViewController.viewControllers) {
            NSLog(@"Index: %i", [self indexForViewController:viewController]);
        }
    } else if (index > self.activeTabIndex) {
        [_pageViewController setViewControllers:@[[self viewControllerAtIndex:index]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
        NSLog(@"%@", self.pageViewController.viewControllers);
        for (UIViewController *viewController in self.pageViewController.viewControllers) {
            NSLog(@"Index: %i", [self indexForViewController:viewController]);
        }
    }
    
    self.activeTabIndex = index;
    [_tabsView scrollRectToVisible:tabView.frame animated:YES];
}

#pragma mark -
- (void)defaultSettings {
    
    _tabHeight = kDefaultTabHeight;
    _tabOffset = kDefaultTabOffset;
    _tabWidth = kDefaultTabWidth;
    
    _tabLocation = kDefaultTabLocation;
    
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
}
- (void)reloadData {
    
    // Get settings if provided
    _tabHeight = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabHeight withDefault:kDefaultTabHeight];
    _tabOffset = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabOffset withDefault:kDefaultTabOffset];
    _tabWidth = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabWidth withDefault:kDefaultTabWidth];
    
    _tabLocation = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabLocation withDefault:kDefaultTabLocation];
    
    // Empty tabs and contents
    [_tabs removeAllObjects];
    [_contents removeAllObjects];
    
    _tabCount = [self.dataSource numberOfTabsForViewPager:self];
    
    // Populate arrays with [NSNull null];
    _tabs = [NSMutableArray arrayWithCapacity:_tabCount];
    for (int i = 0; i < _tabCount; i++) {
        [_tabs addObject:[NSNull null]];
    }
    
    _contents = [NSMutableArray arrayWithCapacity:_tabCount];
    for (int i = 0; i < _tabCount; i++) {
        [_contents addObject:[NSNull null]];
    }
    
    // Set first viewController
    [_pageViewController setViewControllers:@[[self viewControllerAtIndex:0]]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
    _activeTabIndex = 0;
    
    // Add contentView
    UIView *pageView = [self.view viewWithTag:kPageViewTag];
    
    if (!pageView) {
        
        pageView = _pageViewController.view;
        pageView.bounds = self.view.bounds;
        pageView.tag = kPageViewTag;
        
        [self.view addSubview:pageView];
    }
    
    CGRect frame = pageView.frame;
    frame.size.height = self.view.frame.size.height - self.tabHeight;
    frame.origin.y = self.tabLocation ? self.tabHeight : 0.0;
    pageView.frame = frame;
    
    // Add tabsView
    _tabsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0,
                                                               self.tabLocation ? 0.0 : pageView.frame.size.height,
                                                               self.view.frame.size.width,
                                                               self.tabHeight)];
    _tabsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _tabsView.showsHorizontalScrollIndicator = NO;
    _tabsView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:_tabsView];
    
    // Add tab views to _tabsView
    CGFloat contentSizeWidth = 0;
    for (int i = 0; i < _tabCount; i++) {
        
        UIView *tabView = [self tabViewAtIndex:i];
        
        CGRect frame = tabView.frame;
        frame.origin.x = contentSizeWidth;
        tabView.frame = frame;
        
        [_tabsView addSubview:tabView];
        
        contentSizeWidth += tabView.frame.size.width;
        
        // To capture tap events
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [tabView addGestureRecognizer:tapGestureRecognizer];
    }
    
    _tabsView.contentSize = CGSizeMake(contentSizeWidth, self.tabHeight);
}

- (UIView *)tabViewAtIndex:(NSUInteger)index {
    
    if (index >= _tabCount) {
        return nil;
    }
    
    if ([[_tabs objectAtIndex:index] isEqual:[NSNull null]]) {
        [_tabs replaceObjectAtIndex:index withObject:[self.dataSource viewPager:self viewForTabAtIndex:index]];
    }
    
    return [_tabs objectAtIndex:index];
}
- (NSUInteger)indexForTabView:(UIView *)tabView {
    
    return [_tabs indexOfObject:tabView];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    if (index >= _tabCount) {
        return nil;
    }
    
    if ([[_contents objectAtIndex:index] isEqual:[NSNull null]]) {
        [_contents replaceObjectAtIndex:index withObject:[self.dataSource viewPager:self contentForTabAtIndex:index]];
    }
    
    return [_contents objectAtIndex:index];
}
- (NSUInteger)indexForViewController:(UIViewController *)viewController {
    
    return [_contents indexOfObject:viewController];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
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
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    NSLog(@"willTransitionToViewController: %i", [self indexForViewController:[pendingViewControllers objectAtIndex:0]]);
}
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    UIViewController *viewController = self.pageViewController.viewControllers[0];
    _activeTabIndex = [self indexForViewController:viewController];
}

@end
