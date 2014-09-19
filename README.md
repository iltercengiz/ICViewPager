ICViewPager
===========

You can create sliding tabs with ViewPager.

Slide through the contents or select from tabs or slide through tabs and select!

<img src="https://dl.dropboxusercontent.com/u/17948706/Resources/SS.jpg" alt="ICViewPager" title="ICViewPager">

## Installation

Just copy ViewPagerController.m and ViewPagerController.h files to your project.

Or you can use CocoaPods (as this is the recommended way).

`pod 'ICViewPager'`

## Usage

Subclass ViewPagerController (as it's a `UIViewController` subclass) and implement dataSource and delegate methods in the subclass.

In the subclass assign self as dataSource and delegate,

```
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
}
```

### Methods

Then implement dataSource and delegate methods.
```
#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return 10;
}
```
Returns the number of tabs that will be present in ViewPager.

```
#pragma mark - ViewPagerDataSource
- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {

    UILabel *label = [UILabel new];
    label.text = [NSString stringWithFormat:@"Tab #%i", index];
    [label sizeToFit];
    
    return label;
}
```
Returns the view that will be shown as tab. Create a `UIView` object (or any `UIView` subclass object) and give it to ViewPager and it will use it as tab view.

```
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

```
#pragma mark - ViewPagerDelegate
- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index {
    
    // Do something useful
}
```
ViewPager will alert your delegate object via `- viewPager:didChangeTabToIndex:` method, so that you can do something useful.

```
#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {
    
    switch (option) {
        case ViewPagerOptionStartFromSecondTab:
            return 0.0;
        case ViewPagerOptionCenterCurrentTab:
            return 0.0;
        case ViewPagerOptionTabLocation:
            return 0.0;
        default:
            return value;
    }
}
```
You can change ViewPager's options via `viewPager:valueForOption:withDefault:` delegate method. Just return the desired value for the given option. You don't have to return a value for every option. Only return values for the interested options and ViewPager will use the default values for the rest. Available options are defined in the `ViewPagerController.h` file and described below.

```
#pragma mark - ViewPagerDelegate
- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    
    switch (component) {
        case ViewPagerIndicator:
            return [[UIColor redColor] colorWithAlphaComponent:0.64];
        default:
            return color;
    }
}
```
You can change some colors too. Just like options, return the interested component's color, and leave out all the rest! [Link](http://www.youtube.com/watch?v=LBTXNPZPfbE)
    
### Options

Every option has a default value. So 

 * `ViewPagerOptionTabHeight`: Tab bar's height, defaults to 44.0
 * `ViewPagerOptionTabOffset`: Tab bar's offset from left, defaults to 56.0
 * `ViewPagerOptionTabWidth`: Any tab item's width, defaults to 128.0
 * `ViewPagerOptionTabLocation`: 1.0: Top, 0.0: Bottom, Defaults to Top
 * `ViewPagerOptionStartFromSecondTab`: 1.0: `YES`, 0.0: `NO`, defines if view should appear with the 1st or 2nd tab. Defaults to `NO`
 * `ViewPagerOptionCenterCurrentTab`: 1.0: `YES`, 0.0: `NO`, defines if tabs should be centered, with the given tabWidth. Defaults to `NO`
 * `ViewPagerOptionFixFormerTabsPositions`: 1.0: `YES`, 0.0: `NO`, defines if the active tab should be placed margined by the offset amount to the left. Effects only the former tabs. If set 1.0 (`YES`), first tab will be placed at the same position with the second one, leaving space before itself. Defaults to `NO`
 * `ViewPagerOptionFixLatterTabsPositions`: 1.0: `YES`, 0.0: `NO`, like `ViewPagerOptionFixFormerTabsPositions`, but effects the latter tabs, making them leave space after themselves. Defaults to `NO`

### Components

Main parts of the ViewPagerController

 * `ViewPagerIndicator`: The colored line in the view of the active tab.
 * `ViewPagerTabsView`: The tabs view itself. When used in `- viewPager:colorForComponent:withDefault:` method, the returned color will be used as background color for the tab view.
 * `ViewPagerContent`: Provided views goes here as content. When used in `- viewPager:colorForComponent:withDefault:` method, the returned color will be used as background color for the content view.

## Requirements

ViewPager supports minimum iOS 6 and uses ARC.

Supports both iPhone and iPad.

## Contact
[@iltercengiz](https://twitter.com/iltercengiz)

[Ilter Cengiz](mailto:me@iltercengiz.info)

Note (to everyone who is interested in `ViewPager`): I cannot have much time to improve `ViewPager` for a long time, but I have some cool plans for it. So if you encounter any problems, bugs or etc. please forgive me, and send some pull requests. Thank you for your interest and support.

## Licence
ICViewPager is MIT licensed. See the LICENCE file for more info.
