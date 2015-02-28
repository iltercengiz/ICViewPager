//
//  HostViewController.m
//  ICViewPager
//
//  Created by Ilter Cengiz on 28/08/2013.
//  Copyright (c) 2013 Ilter Cengiz. All rights reserved.
//

#import "HostViewController.h"
#import "ContentViewController.h"

@interface HostViewController () <ViewPagerDataSource, ViewPagerDelegate>

@property(nonatomic) NSUInteger numberOfTabs;

@end

@implementation HostViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.dataSource = self;
	self.delegate = self;

	self.title = @"View Pager";

	// Keeps tab bar below navigation bar on iOS 7.0+
	// if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
	//     self.edgesForExtendedLayout = UIRectEdgeNone;
	// }

	self.indicatorColor = [[UIColor redColor] colorWithAlphaComponent:0.64];
	self.tabsViewBackgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.32];
	self.contentViewBackgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.32];

	self.startFromSecondTab = NO;
	self.centerCurrentTab = NO;
	self.tabLocation = ViewPagerTabLocationTop;
	self.tabHeight = 49;
	self.tabOffset = 36;
	self.tabWidth = UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 128.0f : 96.0f;
	self.fixFormerTabsPositions = NO;
	self.fixLatterTabsPositions = NO;
	self.shouldAnimateIndicator = ViewPagerIndicatorAnimationWhileScrolling;

	self.numberOfTabs = 2;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tab #5" style:UIBarButtonItemStylePlain target:self action:@selector(selectTabWithNumberFive)];
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[self performSelector:@selector(loadContent) withObject:nil afterDelay:3.0];
}


- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


#pragma mark - Setters


- (void)setNumberOfTabs:(NSUInteger)numberOfTabs
{

	// Set numberOfTabs
	_numberOfTabs = numberOfTabs;

	// Reload data
	[self reloadData];

}


#pragma mark - Helpers


- (void)selectTabWithNumberFive
{
	[self selectTabAtIndex:5];
}


- (void)loadContent
{
	self.numberOfTabs = 10;
}


#pragma mark - Interface Orientation Changes


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

	// Update changes after screen rotates
	[self performSelector:@selector(setNeedsReloadOptions) withObject:nil afterDelay:duration];
}


#pragma mark - ViewPagerDataSource


- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager
{
	return self.numberOfTabs;
}


- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index
{

	UILabel *label = [UILabel new];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont systemFontOfSize:12.0];
	label.text = [NSString stringWithFormat:@"Tab #%i", index];
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor = [UIColor blackColor];
	[label sizeToFit];

	return label;
}


- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index
{

	ContentViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"contentViewController"];

	cvc.labelString = [NSString stringWithFormat:@"Content View #%i", index];

	return cvc;
}

@end
