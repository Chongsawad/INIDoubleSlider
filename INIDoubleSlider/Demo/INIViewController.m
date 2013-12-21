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
	[slider addTarget:self
			   action:@selector(sliderValueChanged:)
	 forControlEvents:UIControlEventValueChanged];

	[slider setMinValue:0.25f];
	[slider setMaxValue:0.75f];
}

- (void)sliderValueChanged:(id)sender
{
	NSLog(@"value %f | %f", slider.minValue, slider.maxValue);
}

@end
