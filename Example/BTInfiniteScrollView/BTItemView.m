//
//  BTItemView.m
//  BTInfiniteScrollView
//
//  Created by Денис Либит on 22.12.2014.
//  Copyright (c) 2014 Денис Либит. All rights reserved.
//

#import "BTItemView.h"


@interface BTItemView ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic, strong) UIColor *color;

@end


@implementation BTItemView

#pragma mark - Lifecycle

//
// -----------------------------------------------------------------------------
- (instancetype)initWithIndex:(NSInteger)index
{
	self = [super initWithFrame:CGRectZero];
	
	if (self) {
		self.title = [NSString stringWithFormat:@"%ld", (long)index];
		self.attributes = @{
			NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:24],
			NSForegroundColorAttributeName: [UIColor blackColor],
		};
		self.color = [UIColor colorWithHue:((CGFloat)(arc4random() % 100) / 100) saturation:0.2 brightness:1 alpha:1];
	}
	
	return self;
}

//
// -----------------------------------------------------------------------------
- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[self setNeedsDisplay];
}

//
// -----------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
{
	CGRect bounds = self.bounds;
	NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
	
	[self.color setFill];
	UIRectFill(bounds);
	
	CGRect textRect = [self.title boundingRectWithSize:bounds.size options:options attributes:self.attributes context:nil];
	CGRect textDrawRect =
		CGRectMake(bounds.origin.x + (bounds.size.width - textRect.size.width) / 2,
				   bounds.origin.y + (bounds.size.height - textRect.size.height) / 2,
				   textRect.size.width,
				   textRect.size.height);
	
	[self.title drawWithRect:textDrawRect options:options attributes:self.attributes context:nil];
}

@end
