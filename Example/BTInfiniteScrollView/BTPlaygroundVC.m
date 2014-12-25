//
//  BTPlaygroundVC.m
//  BTInfiniteScrollView
//
//  Created by Денис Либит on 22.12.2014.
//  Copyright (c) 2014 Денис Либит. All rights reserved.
//

#import "BTPlaygroundVC.h"


@implementation BTPlaygroundVC

#pragma mark - Lifecycle

//
// -----------------------------------------------------------------------------
- (instancetype)init
{
	self = [super init];
	
	if (self) {
		self.title = @"Playground";
		self.automaticallyAdjustsScrollViewInsets = NO;
		self.edgesForExtendedLayout = UIRectEdgeNone;
		
		_width = 0.5;
		_height = 0.3;
	}
	
	return self;
}

//
// -----------------------------------------------------------------------------
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.autoresizesSubviews = NO;
	self.view.backgroundColor = [UIColor whiteColor];
	
	[self.view addSubview:self.infiniteScrollView];
}

//
// -----------------------------------------------------------------------------
- (void)viewWillLayoutSubviews
{
	CGRect bounds = self.view.bounds;
	
	CGFloat width = bounds.size.width * self.width;
	CGFloat height = bounds.size.height * self.height;
	
	self.infiniteScrollView.frame =
		CGRectMake(bounds.origin.x + (bounds.size.width - width) / 2,
				   bounds.origin.y + (bounds.size.height - height) / 2,
				   width,
				   height);
}


#pragma mark - infiniteScrollView

//
// -----------------------------------------------------------------------------
- (BTInfiniteScrollView *)infiniteScrollView
{
	if (!_infiniteScrollView) {
		_infiniteScrollView = [[BTInfiniteScrollView alloc] initWithFrame:CGRectZero delegate:nil horizontal:YES position:BTPositionMiddle];
	}
	
	return _infiniteScrollView;
}


#pragma mark - Settings

//
// -----------------------------------------------------------------------------
- (void)setWidth:(CGFloat)width
{
	_width = width;
	[self.view setNeedsLayout];
}

//
// -----------------------------------------------------------------------------
- (void)setHeight:(CGFloat)height
{
	_height = height;
	[self.view setNeedsLayout];
}

@end
