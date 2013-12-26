//
//  INIViewController.m
//  INIDoubleSlider
//
//  Created by InICe on 12/21/13.
//  Copyright (c) 2013 Chongsawad. All rights reserved.
//

#import "INIViewController.h"
#import "INISpecialRange.h"

@interface INIViewController ()

@end

@implementation INIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSMutableArray *rr = [NSMutableArray new];
	NSUInteger numOfRange = 11;
	CGFloat valueSpan = 1.0f/(CGFloat)numOfRange;
	for (int i = 0; i < numOfRange; i++) {
		INIRange *rangeA = [[INIRange alloc] init];
		rangeA.title = [NSString stringWithFormat:@"%c", i+65];
		rangeA.value = valueSpan;
		[rr addObject:rangeA];
	}

	NSArray *d = @[@"IDEAL", @"EXCELLENT", @"VERY GOOD", @"GOOD", @"FAIR"];

	NSMutableArray *r = [NSMutableArray new];
	[d enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		INIRange *rangeA = [[INIRange alloc] init];
		rangeA.title = obj;
		rangeA.value = 1.0f/d.count;
		[r addObject:rangeA];
	}];

	//[slider setRanges:r];

	INISpecialRange *spRange = [[INISpecialRange alloc] init];
	spRange.value = 1;
	[slider setRanges:@[spRange]];

	[slider addTarget:self
			   action:@selector(sliderValueChanged:)
	 forControlEvents:UIControlEventValueChanged];

	[slider setMinValue:0.1];
	[slider setMaxValue:0.4];
	[slider setShouldSlideToNearestRange:YES];

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
	INISpecialRange *minRange = [slider minRepresentedRange];

	if ([minRange isKindOfClass:[INISpecialRange class]]) {
		minLabel.text = [minRange intervalValue:slider.minValue];
	}

	INISpecialRange *maxRange = [slider maxRepresentedRange];
	if ([maxRange isKindOfClass:[INISpecialRange class]]) {
		maxLabel.text = [maxRange intervalValue:slider.maxValue];
	}
	//minLabel.text = [slider minRepresentedValue];
	//maxLabel.text = [slider maxRepresentedValue];
}

@end
