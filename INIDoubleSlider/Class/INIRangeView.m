//
//  INIRangeView.m
//  INIDoubleSlider
//
//  Created by InICe on 12/21/13.
//  Copyright (c) 2013 Chongsawad. All rights reserved.
//
#import <FrameAccessor/ViewFrameAccessor.h>
#import "INIRangeView.h"
#import "INIRange.h"

@implementation INIRangeView

- (id)initWithRange:(INIRange *)range
{
	if (self = [super init]) {
		_range = range;
		UILabel *titleLabel = [[UILabel alloc] init];
		titleLabel.numberOfLines = 1;
		titleLabel.text = _range.title;
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		titleLabel.minimumScaleFactor = 0;
		titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		titleLabel.highlightedTextColor = [UIColor whiteColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.adjustsFontSizeToFitWidth = YES;
		_titleLabel = titleLabel;
		[self addSubview:titleLabel];
		[self setBackgroundColor:[UIColor clearColor]];
	}
	return self;
}

- (void)setHighlighted:(BOOL)isHighlighted
{
	_isHighlighted = isHighlighted;
	[_titleLabel setHighlighted:isHighlighted];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	_titleLabel.frame = CGRectInset(self.bounds, 3, 2);
}

@end