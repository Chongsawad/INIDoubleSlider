//
//  INIDoubleSlider.h
//  INIDoubleSlider
//
//  Created by InICe on 12/21/13.
//  Copyright (c) 2013 Chongsawad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INIRange.h"

@interface INIDoubleSlider : UIControl

/*
 * value from 0 to 1
 */
@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat maxValue;

@property (nonatomic, strong) NSArray *ranges;

@end

@interface INIDoubleSlider (RepresentedValue)
- (id)minRepresentedValue;
- (id)maxRepresentedValue;
@end