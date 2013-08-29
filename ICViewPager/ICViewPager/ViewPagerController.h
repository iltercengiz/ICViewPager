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
    ViewPagerOptionTabLocation
} ViewPagerOption;

@protocol ViewPagerDataSource;
@protocol ViewPagerDelegate;

@interface ViewPagerController : UIViewController

@property id<ViewPagerDataSource> dataSource;
@property id<ViewPagerDelegate> delegate;

// ViewPagerOptions
@property CGFloat tabHeight;
@property CGFloat tabOffset;
@property CGFloat tabWidth;

@property CGFloat tabLocation;

- (void)reloadData;

@end

@protocol ViewPagerDataSource <NSObject>

- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager;
- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index;
- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentForTabAtIndex:(NSUInteger)index;

@end

@protocol ViewPagerDelegate <NSObject>

@optional
- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index;
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value;

@end
