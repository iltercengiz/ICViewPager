//
//  ContentViewController.h
//  ICViewPager
//
//  Created by Ilter Cengiz on 28/08/2013.
//  Copyright (c) 2013 Ilter Cengiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#define NSLog(__FORMAT__, ...)

@interface ContentViewController : UIViewController

@property NSString *labelString;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
