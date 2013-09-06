//
//  ViewPagerController.h
//  ICViewPager
//
//  Created by Ilter Cengiz on 28/08/2013.
//  Copyright (c) 2013 Ilter Cengiz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ViewPagerOptionTabHeight = 0,
    ViewPagerOptionTabOffset,
    ViewPagerOptionTabWidth,
    ViewPagerOptionTabLocation,
    ViewPagerOptionStartFromSecondTab
} ViewPagerOption;

@protocol ViewPagerDataSource;
@protocol ViewPagerDelegate;

@interface ViewPagerController : UIViewController

@property id<ViewPagerDataSource> dataSource;
@property id<ViewPagerDelegate> delegate;

// ViewPagerOptions
// Tab bar's height, defaults to 49.0
@property CGFloat tabHeight;
// Tab bar's offset from left, defaults to 56.0
@property CGFloat tabOffset;
// Any tab item's width, defaults to 128.0. To-do: make this dynamic
@property CGFloat tabWidth;

// 1.0: Top, 0.0: Bottom, changes tab bar's location in the screen
@property CGFloat tabLocation;

// 1.0: YES, 0.0: NO, defines if view should appear with the second or the first tab
@property CGFloat startFromSecondTab;

// Reload all tabs and contents
- (void)reloadData;

@end

@protocol ViewPagerDataSource <NSObject>

// Asks dataSource how many tabs will be
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager;
// Asks dataSource to give a view to display as a tab item
// It is suggested to return a view with a clearColor background
// So that un/selected states can be clearly seen
- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index;
// The content for any tab. Return a view controller and ViewPager will use its view to show as content
- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentForTabAtIndex:(NSUInteger)index;

@end

@protocol ViewPagerDelegate <NSObject>

@optional
// delegate object must implement this method if wants to be informed when a tab changes
- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index;
// Every time - reloadData called, ViewPager will ask its delegate for option values
// So you don't have to set options from ViewPager itself
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value;

@end
