//
//  INIViewController.m
//  INIDoubleSlider
//
//  Created by InICe on 12/21/13.
//  Copyright (c) 2013 Chongsawad. All rights reserved.
//

#import "INIViewController.h"

@interface INIViewController ()

@end

@implementation INIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSMutableArray *rr = [NSMutableArray new];
	NSUInteger numOfRange = 15;
	CGFloat valueSpan = 1.0f/(CGFloat)numOfRange;
	for (int i = 0; i < numOfRange; i++) {
		INIRange *rangeA = [[INIRange alloc] init];
		rangeA.title = [NSString stringWithFormat:@"%c", i+65];
		rangeA.value = valueSpan;
		[rr addObject:rangeA];
	}
	[slider setRanges:rr];

	[slider addTarget:self
			   action:@selector(sliderValueChanged:)
	 forControlEvents:UIControlEventValueChanged];

	[slider setMinValue:0.25f];
	[slider setMaxValue:0.75f];

	[[INIDoubleSlider appearance] setHandleColor:[UIColor clearColor]];
	[[INIDoubleSlider appearance] setBackgroundColor:[UIColor clearColor]];
	[[INIDoubleSlider appearance] setBarColor:[UIColor clearColor]];
	[[INIDoubleSlider appearance] setHandleImage:[UIImage imageNamed:@"bt-handle-button"]];

	[[INIDoubleSlider appearance] setBarImage:[UIImage imageNamed:@"bg-slide-bar"]];
	[[INIDoubleSlider appearance] setBarHighlightedImage:[UIImage imageNamed:@"bg-slide-bar-ac"]];
	[[INIDoubleSlider appearance] setBarHilightedCapInset:UIEdgeInsetsMake(2, 0, 2, 0)];
	
	[[INIDoubleSlider appearance] setSeparatorColor:[UIColor clearColor]];
	[[INIDoubleSlider appearance] setSeparatorImage:[UIImage imageNamed:@"separator"]];
	[[INIDoubleSlider appearance] setSeparatorInset:UIEdgeInsetsMake(2, 0, 2, 0)];

	[[INIDoubleSlider appearance] setFont:[UIFont systemFontOfSize:10]];
}

- (void)sliderValueChanged:(id)sender
{
	
}

@end
