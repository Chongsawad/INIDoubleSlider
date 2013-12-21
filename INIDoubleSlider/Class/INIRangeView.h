//
//  INIRangeView.h
//  INIDoubleSlider
//
//  Created by InICe on 12/21/13.
//  Copyright (c) 2013 Chongsawad. All rights reserved.
//

#import <UIKit/UIKit.h>
@class INIRange;
@interface INIRangeView : UIView
@property (nonatomic, strong) INIRange *range;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign, setter = setHighlighted:) BOOL isHighlighted;

- (id)initWithRange:(INIRange *)range;

@end
