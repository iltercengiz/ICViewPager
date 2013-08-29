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

@end

@implementation HostViewController

- (void)viewDidLoad {
    
    self.dataSource = self;
    self.delegate = self;
    
    // Keeps tab bar below navigation bar on iOS 7.0+
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return 10;
}
- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.text = [NSString stringWithFormat:@"Content View %i", index];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    
    UIView *tabView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, label.frame.size.width + 8.0, viewPager.tabHeight)];
    [tabView addSubview:label];
    [tabView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [tabView.layer setBorderWidth:1.0];
    tabView.backgroundColor = [UIColor lightGrayColor];
    
    label.center = [tabView convertPoint:tabView.center fromView:tabView.superview];
    
    return tabView;
}
- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentForTabAtIndex:(NSUInteger)index {
    
    ContentViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"contentViewController"];
    
    cvc.labelString = [NSString stringWithFormat:@"Content View #%i", index];
    
    return cvc;
}

#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {
    return value;
}

@end
