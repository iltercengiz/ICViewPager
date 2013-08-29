ICViewPager
===========

A tab view that mimics ActionBarSherlock's FragmentsTabsPager and Google Play app's tab management.

## Usage

Just copy ViewPagerController.m and ViewPagerController.h files to your project.
You can subclass it and implement dataSource and delegate methods in the subclass or just assign it to a view controller as file's owner and provide external dataSource and delegate objects.

## Requirements

ICViewController supports minimum iOS 6 and uses ARC.

## To-do
- Tabs don't play well with contents while scrolling
- Scrolling tabs and selecting a further tab then the active one, causes contents to misalign

## Contact
[@monsieurje](https://twitter.com/monsieurje)
[Ilter Cengiz](mailto:me@iltercengiz.info)

## Licence
ICViewPager is MIT licensed. See the LICENCE file for more info.
