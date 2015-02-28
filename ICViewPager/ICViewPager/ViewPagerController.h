//
//  ViewPagerController.h
//  ICViewPager
//
//  Created by Ilter Cengiz on 28/08/2013.
//  Copyright (c) 2013 Ilter Cengiz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ViewPagerTabLocation)
{
	ViewPagerTabLocationTop = 0,
	ViewPagerTabLocationBottom = 1
};
typedef NS_ENUM(NSUInteger, ViewPagerIndicator)
{
	ViewPagerIndicatorAnimationNone = 0,
	ViewPagerIndicatorAnimationEnd = 1,
	ViewPagerIndicatorAnimationWhileScrolling = 2

};
@protocol ViewPagerDataSource;
@protocol ViewPagerDelegate;

@interface ViewPagerController : UIViewController

/**
* The object that acts as the data source of the receiving viewPager
* @discussion The data source must adopt the ViewPagerDataSource protocol. The data source is not retained.
*/
@property(weak) id <ViewPagerDataSource> dataSource;
/**
* The object that acts as the delegate of the receiving viewPager
* @discussion The delegate must adopt the ViewPagerDelegate protocol. The delegate is not retained.
*/
@property(weak) id <ViewPagerDelegate> delegate;
/**
* Tab bar's height, defaults to 44.0
*/
@property(nonatomic) CGFloat tabHeight;
/**
*  Tab bar's offset from left, defaults to 56.0
*/
@property(nonatomic) CGFloat tabOffset;
/**
* Any tab item's width, defaults to 128.0
*/
@property(nonatomic) CGFloat tabWidth;
/**
* Tab bar indicator stroke height, Defaults to 5;
*/
@property(nonatomic) CGFloat indicatorHeight;
/**
* ViewPagerTabLocationTop, ViewPagerTabLocationBottom, Defaults to ViewPagerTabLocationTop
*/
@property(nonatomic) ViewPagerTabLocation tabLocation;
/**
* Defines if the indicator should change during the pager change (ViewPagerIndicatorAnimationWhileScrolling) ,
* animated when it ends scrolling (ViewPagerIndicatorAnimationEnd)
* or doesn't animate at all (ViewPagerIndicatorAnimationNone);
* Default is ViewPagerIndicatorAnimationWhileScrolling
*/
@property(nonatomic) ViewPagerIndicator shouldAnimateIndicator;
/**
* Defines if view should appear with the 1st or 2nd tab. Defaults to NO
*/
@property(nonatomic) BOOL startFromSecondTab;
/**
* Defines if tabs should be centered, with the given tabWidth. Defaults to NO
*/
@property(nonatomic) BOOL centerCurrentTab;
/**
* Defines if the active tab should be placed margined by the offset amount to the left. Effects only the former tabs.
* If set YES, first tab will be placed at the same position with the second one, leaving space before itself.
* Defaults to NO
*/
@property(nonatomic) BOOL fixFormerTabsPositions;
/**
* Like ViewPagerOptionFixFormerTabsPositions, but effects the latter tabs,
* making them leave space after themselves. Defaults to NO
*/
@property(nonatomic) BOOL fixLatterTabsPositions;
/**
* The colored line in the view of the active tab
*/
@property(nonatomic) UIColor *indicatorColor;
/**
* The tabs view itself
*/
@property(nonatomic) UIColor *tabsViewBackgroundColor;
/**
* Provided views goes here as content
*/
@property(nonatomic) UIColor *contentViewBackgroundColor;

#pragma mark Methods
/**
* Reloads all tabs and contents with default configuration
*/
- (void)reloadData;
/**
* Selects the given tab and shows the content at this index
*
* @param index The index of the tab that will be selected
*/
- (void)selectTabAtIndex:(NSUInteger)index;
/**
* Reloads the appearance of the tabs view.
* Adjusts tabs' width, offset, the center, fix former/latter tabs cases.
* Without implementing the - viewPager:valueForOption:withDefault: delegate method,
* this method does nothing.
* Calling this method without changing any option will affect the performance.
*/
- (void)setNeedsReloadOptions;
/**
* Reloads the colors.
* You can make ViewPager to reload its components colors.
* Changing `ViewPagerTabsView` and `ViewPagerContent` color will have no effect to performance,
* but `ViewPagerIndicator`, as it will need to iterate through all tabs to update it.
* Calling this method without changing any color won't affect the performance,
* but will cause your delegate method (if you implemented it) to be called three times.
*/
- (void)setNeedsReloadColors;

@end

#pragma mark dataSource

@protocol ViewPagerDataSource <NSObject>
/**
* Asks dataSource how many tabs will there be.
*
* @param viewPager The viewPager that's subject to
* @return Number of tabs
*/
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager;
/**
* Asks dataSource to give a view to display as a tab item.
* It is suggested to return a view with a clearColor background.
* So that un/selected states can be clearly seen.
*
* @param viewPager The viewPager that's subject to
* @param index The index of the tab whose view is asked
*
* @return A view that will be shown as tab at the given index
*/
- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index;

@optional
/**
* The content for any tab. Return a view controller and ViewPager will use its view to show as content.
*
* @param viewPager The viewPager that's subject to
* @param index The index of the content whose view is asked
*
* @return A viewController whose view will be shown as content
*/
- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index;
/**
* The content for any tab. Return a view and ViewPager will use it to show as content.
*
* @param viewPager The viewPager that's subject to
* @param index The index of the content whose view is asked
*
* @return A view which will be shown as content
*/
- (UIView *)viewPager:(ViewPagerController *)viewPager contentViewForTabAtIndex:(NSUInteger)index;

@end

#pragma mark delegate

@protocol ViewPagerDelegate <NSObject>

@optional
/**
* delegate object must implement this method if wants to be informed when a tab changes
*
* @param viewPager The viewPager that's subject to
* @param index The index of the active tab
*/
- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index;
/**
* delegate object should implement this method if it wants to be informed when a tab changes and what its previous tab index was
*
* @param viewPager The viewPager that's subject to
* @param index The index of the active tab
* @param previousIndex The previous index of the active tab
*/
- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index fromIndex:(NSUInteger)previousIndex;
/**
* delegate object should implement this method if it wants to be informed when a tab changes and what its previous tab index was and whether the change action was caused by a swipe gesture or tab bar button press
*
* @param viewPager The viewPager that's subject to
* @param index The index of the active tab
* @param previousIndex The previous index of the active tab
* @param didSwipe Indicating if the change action was caused by a swipe gesture or a tab bar button press
*/
- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index fromIndex:(NSUInteger)previousIndex didSwipe:(BOOL)didSwipe;

@end
