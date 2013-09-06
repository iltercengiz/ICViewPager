ICViewPager
===========

A tab view that mimics ActionBarSherlock's FragmentsTabsPager and Google Play app's tab management.

<img src="https://dl.dropboxusercontent.com/u/17948706/Resources/SS.png" alt="ICViewPager" title="ICViewPager">

## Usage

Just copy ViewPagerController.m and ViewPagerController.h files to your project.
You can subclass it and implement dataSource and delegate methods in the subclass or just assign it to a view controller as file's owner and provide external dataSource and delegate objects.

## Requirements

ICViewController supports minimum iOS 6 and uses ARC.

## To-do
- Current version doesn't track pan gestures in content view. These should be tracked to scroll tabs synchronously
- iPad support

## Contact
[@monsieurje](https://twitter.com/monsieurje)
[Ilter Cengiz](mailto:me@iltercengiz.info)

## Licence
ICViewPager is MIT licensed. See the LICENCE file for more info.
