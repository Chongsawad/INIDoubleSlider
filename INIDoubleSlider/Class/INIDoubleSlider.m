//
//  INIDoubleSlider.m
//  INIDoubleSlider
//
//  Created by InICe on 12/21/13.
//  Copyright (c) 2013 Chongsawad. All rights reserved.
//
#import <FrameAccessor/ViewFrameAccessor.h>
#import "INIDoubleSlider.h"
#import "INIRangeView.h"
#import "INIRange.h"

static CGFloat const kBarSizeWidth = 280.f;
static CGFloat const kBarSizeHeight = 40.f;
static CGFloat const kHandleSizeWidth = 20.f;
static CGFloat const kHandleSizeHeight = kBarSizeHeight;

static inline CGRect kBarFrame() {
	return CGRectMake(0, 0, kBarSizeWidth, kBarSizeHeight);
};

@interface INIDoubleSlider() {
	UIView *barView;
	UIView *rangeView;
	UIImageView *barHighlightImageView;
	UIImageView *barBackgroundImageView;
	UIImageView *leftHandleView;
	UIImageView *rightHandleView;

	BOOL isTrackingLeftHandle;
	BOOL isTrackingRightHandle;

	NSMutableArray *rangeViews;
}

- (void)ini_updateValues;
- (void)ini_endUpdates;

- (UIView *)ini_trackingHandle;

@end

@implementation INIDoubleSlider (MultipleRanges)

- (UIView *)setupRangeView
{
	UIView *view = [[UIImageView alloc]
					initWithFrame:kBarFrame()];
	view.backgroundColor = [UIColor clearColor];
	return view;
}

- (void)ini_initializeRangeView
{
	rangeViews = [NSMutableArray new];

	__block CGFloat lastPositionOfRange = 0;
	[self.ranges enumerateObjectsUsingBlock:^(INIRange *range, NSUInteger idx, BOOL *stop) {
		INIRangeView *aRangeView = [[INIRangeView alloc] initWithRange:range];
		aRangeView.left = lastPositionOfRange;
		aRangeView.width = range.value * kBarSizeWidth;
		aRangeView.height = kBarSizeHeight;
		aRangeView.backgroundColor = [UIColor clearColor];
		[rangeViews addObject:aRangeView];
		[rangeView addSubview:aRangeView];

		lastPositionOfRange += aRangeView.width;
	}];
}

- (void)ini_resetRangeView
{
	[rangeViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[obj removeFromSuperview];
	}];

	[rangeViews removeAllObjects];
}

- (INIRangeView *)ini_nearestRangeViewFromHandle:(UIView *)handle
{
	CGFloat point; INIRangeView *currentRangeView;
	if ([handle isEqual:leftHandleView]) {
		point = handle.right;
		currentRangeView = [rangeViews lastObject];
		
	} else {
		point = handle.left;
		currentRangeView = [rangeViews firstObject];
	}

	for (INIRangeView *view in rangeViews) {
		if ([handle isEqual:leftHandleView]
			&& point >= view.left
			&& point < view.right) {
			currentRangeView = view;
			break;

		} else if ([handle isEqual:rightHandleView]
				   && point > view.left
				   && point <= view.right) {
			currentRangeView = view;
			break;
		}
	}

	return currentRangeView;
}

- (INIRange *)ini_nearestRangeFromHandle:(UIView *)handle
{
	return [self ini_nearestRangeViewFromHandle:handle].range;
}

- (id)minRepresentedValue
{
	id value = [self ini_nearestRangeFromHandle:leftHandleView];
	return value;
}

- (id)maxRepresentedValue
{
	id value = [self ini_nearestRangeFromHandle:rightHandleView];
	return value;
}

- (void)ini_moveHandleToNearestRangeWithUpdateValue:(BOOL)forceUpdate
{
	INIRangeView *aLeftRangeView = [self ini_nearestRangeViewFromHandle:leftHandleView];
	INIRangeView *aRightRangeView = [self ini_nearestRangeViewFromHandle:rightHandleView];

	CGFloat moveToMinValue = ((CGFloat)[aLeftRangeView left] / kBarSizeWidth);
	CGFloat moveToMaxValue = ((CGFloat)[aRightRangeView right] / kBarSizeWidth);

	/*
	 * Detect same range
	 */
	if (moveToMaxValue - moveToMinValue <= 0) {
		leftHandleView.right -= 0.001f;
		aLeftRangeView = [self ini_nearestRangeViewFromHandle:leftHandleView];
		moveToMinValue = ([aLeftRangeView left] / kBarSizeWidth);
	}

	[self ini_highlightRangeViewFrom:aLeftRangeView
							  toView:aRightRangeView];

	if (forceUpdate) {
		[UIView beginAnimations:@"Move" context:NULL];
		[UIView setAnimationDuration:0.1f];
		[self setMinValue:moveToMinValue];
		[self setMaxValue:moveToMaxValue];
		[UIView commitAnimations];
	}
}

- (void)ini_highlightRangeViewFrom:(INIRangeView *)leftView
							 toView:(INIRangeView *)rightView
{
	if (leftView.left > rightView.left) {
		return;
	}

	BOOL startHighlighted = NO;
	for (INIRangeView *r in rangeViews) {
		if ([r isEqual:leftView]) {
			startHighlighted = YES;

		}

		[r setHighlighted:startHighlighted];

		if ([r isEqual:rightView]) {
			startHighlighted = NO;
		}
	}
}

@end

@implementation INIDoubleSlider (AllViewStyles)

- (UIView *)setupBarView
{
	UIView *view = [[UIImageView alloc]
							initWithFrame:kBarFrame()];
	view.backgroundColor = [UIColor yellowColor];
	return view;
}

- (UIImageView *)setupBarBackgroundImageView
{
	UIImageView *imageView = [[UIImageView alloc]
								 initWithFrame:kBarFrame()];
	imageView.backgroundColor = [UIColor yellowColor];
	imageView.clipsToBounds = YES;
	return imageView;
}

- (UIImageView *)setupBarHighlightImageView
{
	UIImageView *imageView = [[UIImageView alloc]
							  initWithFrame:kBarFrame()];
	imageView.backgroundColor = [UIColor greenColor];
	imageView.clipsToBounds = YES;
	return imageView;
}

- (UIImageView *)setupHandleView
{
	UIImageView *handleView = [[UIImageView alloc] initWithFrame:
							  CGRectMake(0, 0, kHandleSizeWidth, kHandleSizeHeight)];
	handleView.backgroundColor = [UIColor colorWithWhite:0.78 alpha:0.6];
	return handleView;
}

@end

@implementation INIDoubleSlider (SliderTransition)

- (void)ini_moveHandle:(UIView *)handle toValue:(CGFloat)value
{
	CGPoint pos = CGPointMake(value * kBarSizeWidth, 0);
	[self ini_moveHandle:handle toPosition:pos];
}

- (void)ini_moveHandle:(UIView *)view toPosition:(CGPoint)pos
{
	CGPoint beforeChanged = view.origin;
	if (isTrackingLeftHandle) {
		view.right = pos.x;

	} else if (isTrackingRightHandle) {
		view.left = pos.x;

	} else {
		view.origin = beforeChanged;
	}

	[self ini_colisionMoveDetectAtPoint:pos
							 leftHandle:leftHandleView
						 andRightHandle:rightHandleView];

	[self ini_updateValues];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)ini_colisionMoveDetectAtPoint:(CGPoint)loc
						   leftHandle:(UIView *)aLeftHandle
							  andRightHandle:(UIView *)aRightHandle;
{
	if (aLeftHandle.right > aRightHandle.left) {
		if (isTrackingLeftHandle) {
			aLeftHandle.right = aRightHandle.left;
		} else {
			aRightHandle.left = aLeftHandle.right;
		}
	}
}

@end

@implementation INIDoubleSlider (Tracking)

- (UIView *)ini_willTrackNearestHandleWithLocation:(CGPoint)loc
										leftHandle:(UIView *)aLeftHandle
									andRightHandle:(UIView *)aRightHandle;
{
	UIView *handle = [self ini_calculateNearestDistanceWithLocation:loc
												   leftHandle:aLeftHandle
											   andRightHandle:aRightHandle];
	if ([handle isEqual:aLeftHandle]) {
		isTrackingLeftHandle = YES;
		
	} else {
		isTrackingRightHandle = YES;
	}

	return handle;
}

- (UIView *)ini_calculateNearestDistanceWithLocation:(CGPoint)loc
										  leftHandle:(UIView *)aLeftHandle
									  andRightHandle:(UIView *)aRightHandle
{
	CGFloat distanceFromLeftHandle = loc.x - aLeftHandle.right;
	CGFloat distanceFromRightHandle = aRightHandle.left - loc.x;
	if (distanceFromLeftHandle < distanceFromRightHandle) {
		return aLeftHandle;
	} else {
		return aRightHandle;
	}
}

- (CGPoint)locationForTouch:(UITouch *)touch
{
	CGPoint loc = [touch locationInView:barView];
	[self init_normalizeLocation:&loc inView:barView];
	return loc;
}

- (void)init_normalizeLocation:(CGPoint *)loc inView:(UIView *)view
{
	if (loc->x < 0) {
		loc->x = 0;
	}

	if (loc->x > view.width) {
		loc->x = view.width;
	}

	if (loc->y < view.top) {
		loc->y = view.top;
	}

	if (loc->y > view.bottom) {
		loc->y = view.bottom;
	}
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint loc = [self locationForTouch:touch];
	[self ini_willTrackNearestHandleWithLocation:loc
									  leftHandle:leftHandleView
								  andRightHandle:rightHandleView];
	return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint loc = [self locationForTouch:touch];
	UIView *handle = [self ini_trackingHandle];
	[self ini_moveHandle:handle toPosition:loc];
	[self ini_moveHandleToNearestRangeWithUpdateValue:NO];
	return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self ini_moveHandleToNearestRangeWithUpdateValue:YES];
	[self ini_endUpdates];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
	[self ini_endUpdates];
}

@end

@implementation INIDoubleSlider

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		/*
		 * Bar
		 */
		barView = [self setupBarView];
		barView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
		[self addSubview:barView];

		/*
		 * Bar BackgroundImageView
		 */
		barBackgroundImageView = [self setupBarBackgroundImageView];
		[barView addSubview:barBackgroundImageView];

		/*
		 * Bar Highlight ImageView
		 */
		barHighlightImageView = [self setupBarHighlightImageView];
		[barView insertSubview:barHighlightImageView
				  aboveSubview:barBackgroundImageView];

		rangeView = [self setupRangeView];
		[barView insertSubview:rangeView
				  aboveSubview:barHighlightImageView];
		/*
		 * Left Handle
		 */
		leftHandleView = [self setupHandleView];
		leftHandleView.centerY = leftHandleView.middleY;
		leftHandleView.right = 0;
		leftHandleView.backgroundColor = [UIColor redColor];
		[barView addSubview:leftHandleView];

		/*
		 * Right Handle
		 */
		rightHandleView = [self setupHandleView];
		rightHandleView.centerY = rightHandleView.middleY;
		rightHandleView.left = barView.width;
		rightHandleView.backgroundColor = [UIColor blueColor];
		[barView addSubview:rightHandleView];
	}

	return self;
}

- (void)setRanges:(NSArray *)ranges
{
	_ranges = ranges;
	[self ini_initializeRangeView];
}

- (UIView *)ini_trackingHandle
{
	if (isTrackingLeftHandle) {
		return leftHandleView;
	} else {
		return rightHandleView;
	}
}

- (void)ini_beginUpdateHandle:(UIView *)handle endUpdate:(void (^)(UIView *handle))endBlock
{
	if ([handle isEqual:leftHandleView]) {
		isTrackingLeftHandle = YES;

	} else {
		isTrackingRightHandle = YES;
	}

	if (endBlock) {
		endBlock(handle);
	}

	[self ini_endUpdates];
}

- (void)ini_updateValues
{
	_minValue = (leftHandleView.right / kBarSizeWidth);
	_maxValue = (rightHandleView.left / kBarSizeWidth);
	
	/*
	 * Hightlight
	 */
	barHighlightImageView.left = leftHandleView.centerX;
	barHighlightImageView.width = rightHandleView.centerX - leftHandleView.centerX;
}

- (void)ini_endUpdates
{
	isTrackingLeftHandle = NO;
	isTrackingRightHandle = NO;
	[self ini_moveHandleToNearestRangeWithUpdateValue:NO];
}

- (void)setMinValue:(CGFloat)minValue
{
	[self ini_beginUpdateHandle:leftHandleView endUpdate:^(UIView *handle) {
		[self ini_moveHandle:handle toValue:minValue];
	}];
}

- (void)setMaxValue:(CGFloat)maxValue
{
	[self ini_beginUpdateHandle:rightHandleView endUpdate:^(UIView *handle) {
		[self ini_moveHandle:handle toValue:maxValue];
	}];
}

@end