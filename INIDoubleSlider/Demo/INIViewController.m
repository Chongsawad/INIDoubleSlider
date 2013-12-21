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
}

- (void)sliderValueChanged:(id)sender
{
	
}

@end
