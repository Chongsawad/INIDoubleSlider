//
//  INISpecialRange.m
//  INIDoubleSlider
//
//  Created by InICe on 12/26/13.
//  Copyright (c) 2013 Chongsawad. All rights reserved.
//

#import "INISpecialRange.h"

static const CGFloat interval[5]     = {0, 0.01f, 0.05f, 0.1f, 0.5f};
static const CGFloat sectionWidth[5] = {0, 0.5f,  0.8f,  0.9f, 999.f};
static const CGFloat sectionPos[5]   = {0, 0.5f,  1.3f,  2.2f, 999.f};

static const CGFloat percentile[5]   = {0,    0.25f,  0.5f,  0.75f, 1.0f};
static const CGFloat realInterval[5] = {0.2f, 1.0f,  2.0f,  5.0f, 10.0f};

static NSUInteger criticalIntervalFunc(CGFloat s) {
	if (s <= percentile[1]) {
		return 0;
	} else if (s < percentile[2]) {
		return 1;
	} else if (s < percentile[3]) {
		return 2;
	} else if (s <= percentile[4]) {
		return 3;
	} else {
		return 0;
	}
}

static CGFloat calValueSection(NSUInteger inv, CGFloat s) {
	return realInterval[inv] + ((s - percentile[inv])/(percentile[inv+1]-percentile[inv])) * (realInterval[inv+1] - realInterval[inv]);
}

static CGFloat percentileFunc(CGFloat s) {
	NSUInteger inv = criticalIntervalFunc(s);
	return calValueSection(inv, s);
}

@implementation INISpecialRange

- (NSString *)intervalValue:(CGFloat)aValue
{
	return [NSString stringWithFormat:@"%1.2f", percentileFunc(aValue)];
}

@end
