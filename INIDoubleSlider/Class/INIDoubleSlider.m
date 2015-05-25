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

static CGFloat const kDefaultBarSizeWidth = 240.0f;
static CGFloat const kDefaultBarSizeHeight = 26.0f;

static CGFloat const kHandleSizeWidth = 20.f;
static CGFloat const kHandleSizeHeight = 40.f;

static CGFloat const kEpsilon = 0.0001f;

@interface INIDoubleSlider() {
	UIView *barView;
	UIView *rangeView;
	UIView *barHighlightImageView;
	UIImageView *barBackgroundImageView;
	UIImageView *leftHandleView;
	UIImageView *rightHandleView;

	BOOL isTrackingLeftHandle;
	BOOL isTrackingRightHandle;

	NSMutableArray *rangeViews;

	CGFloat kBarSizeWidth;
	CGFloat kBarSizeHeight;

	INIRangeView *currentMinRangeView;
	INIRangeView *currentMaxRangeView;
}

- (void)ini_updateValues;
- (void)ini_endUpdates;

- (UIView *)ini_trackingHandle;
- (CGRect)kBarFrame;

@end

@implementation INIDoubleSlider (MultipleRanges)

- (UIView *)setupRangeView
{
	UIView *view = [[UIImageView alloc]
					initWithFrame:[self kBarFrame]];
	view.backgroundColor = [UIColor clearColor];
	return view;
}

- (void)ini_initializeRangeView
{
	rangeViews = [NSMutableArray new];

	__block CGFloat lastPositionOfRange = 0;
	[self.ranges enumerateObjectsUsingBlock:^(id range, NSUInteger idx, BOOL *stop) {
		INIRangeView *aRangeView = [[INIRangeView alloc] initWithRange:range];
		aRangeView.left = lastPositionOfRange;
		aRangeView.width = [(INIRange *)range value] * kBarSizeWidth;
		aRangeView.height = kBarSizeHeight;
		aRangeView.backgroundColor = [UIColor clearColor];
		aRangeView.titleLabel.font = self.font;
		
		[rangeViews addObject:aRangeView];
		[rangeView addSubview:aRangeView];

		if (idx != self.ranges.count - 1) {
			UIImageView *separatorView = [[UIImageView alloc] initWithImage:self.separatorImage];
			separatorView.backgroundColor = self.separatorColor;
			separatorView.top = self.separatorInset.top;
			separatorView.left = aRangeView.width - 1;
			separatorView.width = 1;
			separatorView.height = aRangeView.height - self.separatorInset.top - self.separatorInset.bottom;

			[aRangeView addSubview:separatorView];
		}

		lastPositionOfRange += aRangeView.width;
	}];

	currentMinRangeView = currentMinRangeView ? currentMinRangeView : [rangeViews firstObject];
	currentMaxRangeView = currentMaxRangeView ? currentMaxRangeView : [rangeViews lastObject];

	[self ini_moveHandleToNearestRangeWithUpdateValue:YES];
	[self ini_endUpdates];
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
		
	} else {
		point = handle.left;
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
	INIRangeView *aLeftRangeView = [self ini_nearestRangeViewFromHandle:leftHandleView];
	if (!aLeftRangeView) {
		aLeftRangeView = currentMinRangeView;
	}

	id value = [aLeftRangeView.range title];
	return value;
}

- (id)minRepresentedRange
{
	INIRangeView *aLeftRangeView = [self ini_nearestRangeViewFromHandle:leftHandleView];
	if (!aLeftRangeView) {
		aLeftRangeView = currentMinRangeView;
	}
	return [aLeftRangeView range];
}

- (id)maxRepresentedValue
{
	INIRangeView *aRightRangeView = [self ini_nearestRangeViewFromHandle:rightHandleView];
	if (!aRightRangeView) {
		aRightRangeView = currentMaxRangeView;
	}
	id value = [aRightRangeView.range title];
	return value;
}

- (id)maxRepresentedRange
{
	INIRangeView *aRightRangeView = [self ini_nearestRangeViewFromHandle:rightHandleView];
	if (!aRightRangeView) {
		aRightRangeView = currentMaxRangeView;
	}
	return [aRightRangeView range];
}

- (void)ini_keepNearestRangeFromHandles
{
	INIRangeView *aLeftRangeView = [self ini_nearestRangeViewFromHandle:leftHandleView];
	INIRangeView *aRightRangeView = [self ini_nearestRangeViewFromHandle:rightHandleView];

	if (!aLeftRangeView) {
		aLeftRangeView = currentMinRangeView;
	}
	if (!aRightRangeView) {
		aRightRangeView = currentMaxRangeView;
	}

	currentMinRangeView = aLeftRangeView;
	currentMaxRangeView = aRightRangeView;
}

- (void)ini_moveHandleToNearestRangeWithUpdateValue:(BOOL)forceUpdate
{
	[self ini_keepNearestRangeFromHandles];
	CGFloat moveToMinValue = ((CGFloat)[currentMinRangeView left] / kBarSizeWidth) + kEpsilon;
	CGFloat moveToMaxValue = ((CGFloat)[currentMaxRangeView right] / kBarSizeWidth) - kEpsilon;
	if (!self.shouldSlideToNearestRange) {
		moveToMinValue = leftHandleView.right / kBarSizeWidth;
		moveToMaxValue = rightHandleView.left / kBarSizeWidth;
	}

	/*
	 * Detect same range
	 */
	if (moveToMaxValue - moveToMinValue <= 0) {
		leftHandleView.right -= kEpsilon;
		currentMinRangeView = [self ini_nearestRangeViewFromHandle:leftHandleView];
		moveToMinValue = ([currentMinRangeView left] / kBarSizeWidth);
	}

	[self ini_highlightRangeViewFrom:currentMinRangeView
							  toView:currentMaxRangeView];

	if (forceUpdate) {
		[UIView beginAnimations:@"Move" context:NULL];
		[UIView setAnimationDuration:0.2f];
		[UIView setAnimationBeginsFromCurrentState:YES];
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
							initWithFrame:[self kBarFrame]];
	view.backgroundColor = [UIColor yellowColor];
	return view;
}

- (UIImageView *)setupBarBackgroundImageView
{
	UIImageView *imageView = [[UIImageView alloc]
								 initWithFrame:[self kBarFrame]];
	imageView.backgroundColor = [UIColor clearColor];
	imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	imageView.clipsToBounds = YES;
	return imageView;
}

- (UIView *)setupBarHighlightImageView
{
	UIView *imageView = [[UIImageView alloc]
							  initWithFrame:[self kBarFrame]];
	imageView.backgroundColor = [UIColor greenColor];
	imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
	CGPoint beforeChanged = view.viewOrigin;
	if (isTrackingLeftHandle) {
		view.right = pos.x;

	} else if (isTrackingRightHandle) {
		view.left = pos.x;

	} else {
		view.viewOrigin = beforeChanged;
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

- (CGRect)kBarFrame
{
	return CGRectMake(0, 0, kBarSizeWidth, kBarSizeHeight);
}

- (void)updateFrameRect
{
	kBarSizeWidth = self.barSize.width > 0 ? self.barSize.width : kDefaultBarSizeWidth;;
	kBarSizeHeight = self.barSize.height > 0 ? self.barSize.height : kDefaultBarSizeHeight;

	barView.viewSize = self.barSize;
	barView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

	leftHandleView.centerY = barView.middleY;
	leftHandleView.right = 0;

	rightHandleView.centerY = barView.middleY;
	rightHandleView.left = barView.width;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		kBarSizeWidth = kDefaultBarSizeWidth;
		kBarSizeHeight = kDefaultBarSizeHeight;

		/*
		 * Bar
		 */
		barView = [self setupBarView];
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
		leftHandleView.backgroundColor = [UIColor redColor];
		[barView addSubview:leftHandleView];

		/*
		 * Right Handle
		 */
		rightHandleView = [self setupHandleView];
		rightHandleView.backgroundColor = [UIColor blueColor];
		[barView addSubview:rightHandleView];

		[self updateFrameRect];
	}

	return self;
}

- (void)setRanges:(NSArray *)ranges
{
	_ranges = ranges;
	[self ini_initializeRangeView];
}

- (void)setShouldSlideToNearestRange:(BOOL)shouldSlideToNearestRange
{
	_shouldSlideToNearestRange = shouldSlideToNearestRange;
	if (_ranges.count <= 1) {
		_shouldSlideToNearestRange = NO;
	}
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

+ (void)initialize
{
	if (self == [INIDoubleSlider class]) {
		INIDoubleSlider *appearance = [INIDoubleSlider appearance];
		[appearance setBackgroundColor:[UIColor clearColor]];
		[appearance setSeparatorColor:[UIColor whiteColor]];
		[appearance setBarSize:CGSizeMake(kDefaultBarSizeWidth, kDefaultBarSizeHeight)];
	}
}

- (void)setHandleColor:(UIColor *)handleColor
{
	leftHandleView.backgroundColor = [UIColor clearColor];
	rightHandleView.backgroundColor = [UIColor clearColor];
}

- (void)setHandleImage:(UIImage *)handleImage
{
	leftHandleView.image = handleImage;
	rightHandleView.image = handleImage;
}

- (void)setBarImage:(UIImage *)barImage
{
	barBackgroundImageView.image = barImage;
}

- (void)setBarHighlightedImage:(UIImage *)barHighlightedImage
{
	barHighlightImageView.backgroundColor = [UIColor colorWithPatternImage:barHighlightedImage];
}

- (void)setBarColor:(UIColor *)barColor
{
	barView.backgroundColor = barColor;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self ini_resetRangeView];
	[self updateFrameRect];
	[self ini_initializeRangeView];
}

@end
