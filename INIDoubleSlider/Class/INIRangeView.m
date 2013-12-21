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
		titleLabel.size = self.size;
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		titleLabel.text = _range.title;
		titleLabel.highlightedTextColor = [UIColor whiteColor];
		_titleLabel = titleLabel;
		[self addSubview:titleLabel];
	}
	return self;
}

- (void)setHighlighted:(BOOL)isHighlighted
{
	_isHighlighted = isHighlighted;
	[_titleLabel setHighlighted:isHighlighted];
}

@end