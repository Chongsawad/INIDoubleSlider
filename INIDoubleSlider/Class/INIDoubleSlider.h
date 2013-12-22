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

@property (nonatomic, assign) BOOL shouldSlideToNearestRange;

/*
 * Appearance
 */
@property (nonatomic, strong) UIColor *handleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *barColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *barHighlightedColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIImage *handleImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIImage *barImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIImage *barHighlightedImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UIEdgeInsets barHilightedCapInset UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIImage *separatorImage;
@property (nonatomic, strong) UIColor *separatorColor;
@property (nonatomic, assign) UIEdgeInsets separatorInset;

@property (nonatomic, strong) UIFont *font UI_APPEARANCE_SELECTOR;

@end

@interface INIDoubleSlider (RepresentedValue)
- (id)minRepresentedValue;
- (id)maxRepresentedValue;
@end