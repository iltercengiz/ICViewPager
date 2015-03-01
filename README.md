ICViewPager
===========

You can create sliding tabs with ViewPager.

Slide through the contents or select from tabs or slide through tabs and select!

<img src="https://raw.githubusercontent.com/iltercengiz/ICViewPager/master/Resources/Screenshot.jpg" alt="ICViewPager" title="ICViewPager">

## Installation

Just copy ViewPagerController.m and ViewPagerController.h files to your project.

Or you can use CocoaPods (as this is the recommended way).

`pod 'ICViewPager'`

## Usage

Subclass ViewPagerController (as it's a `UIViewController` subclass) and implement dataSource and delegate methods in the subclass.

In the subclass assign self as dataSource and delegate,

```Objective-C
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
}
```

### Methods

Then implement dataSource and delegate methods.
```Objective-C
#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return 10;
}
```
Returns the number of tabs that will be present in ViewPager.

```Objective-C
#pragma mark - ViewPagerDataSource
- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {

    UILabel *label = [UILabel new];
    label.text = [NSString stringWithFormat:@"Tab #%i", index];
    [label sizeToFit];
    
    return label;
}
```
Returns the view that will be shown as tab. Create a `UIView` object (or any `UIView` subclass object) and give it to ViewPager and it will use it as tab view.

```Objective-C
#pragma mark - ViewPagerDataSource
- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    
    ContentViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"contentViewController"];
    
    return cvc;
}
```
Returns the view controller that will be shown as content. Create a `UIViewController` object (or any `UIViewController` subclass object) and give it to ViewPager and it will use the `view` property of the view controller as content view.

Alternatively, you can implement `- viewPager:contentViewForTabAtIndex:` method and return a `UIView` object (or any `UIView` subclass object) and ViewPager will use it as content view.

The `- viewPager:contentViewControllerForTabAtIndex:` and `- viewPager:contentViewForTabAtIndex:` dataSource methods are both defined optional. But, you should implement at least one of them! They are defined as optional to provide you an option.

All delegate methods are optional.

```Objective-C
#pragma mark - ViewPagerDelegate
- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index {
    
    // Do something useful
}
```
ViewPager will alert your delegate object via `- viewPager:didChangeTabToIndex:` method, so that you can do something useful.

```Objective-C
#pragma mark - ViewPagerDelegate
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
```
You can configurate view pager by changing the properties declared in the interface. All of them have a default value, if you wanna customize your ViewPager just have to change.

You can change some colors too. Just like options, return the interested component's color, and leave out all the rest! [Link](http://www.youtube.com/watch?v=LBTXNPZPfbE)

## Requirements

ViewPager supports minimum iOS 6 and uses ARC.

Supports both iPhone and iPad.

## Contact
[@iltercengiz](https://twitter.com/iltercengiz)

[Ilter Cengiz](mailto:me@iltercengiz.info)

Note (to everyone who is interested in `ViewPager`): I cannot have much time to improve `ViewPager` for a long time, but I have some cool plans for it. So if you encounter any problems, bugs or etc. please forgive me, and send some pull requests. Thank you for your interest and support.

## Licence
ICViewPager is MIT licensed. See the LICENCE file for more info.
