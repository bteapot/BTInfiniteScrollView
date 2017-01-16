//
//  BTInfiniteScrollView.m
//  BTInfiniteScrollView
//
//  Created by Денис Либит on 22.12.2014.
//  Copyright (c) 2014 Денис Либит. All rights reserved.
//

#import "BTInfiniteScrollView.h"


#pragma mark - BTItem

@interface BTItem : NSObject

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, assign) BOOL horizontal;
@property (nonatomic, readonly) CGFloat min;
@property (nonatomic, readonly) CGFloat max;
@property (nonatomic, readonly) CGFloat middle;
@property (nonatomic, readonly) CGFloat thickness;

@end


@implementation BTItem

//
// -----------------------------------------------------------------------------
- (CGFloat)min
{
	return self.horizontal ? CGRectGetMinX(self.view.frame) : CGRectGetMinY(self.view.frame);
}

//
// -----------------------------------------------------------------------------
- (CGFloat)max
{
	return self.horizontal ? CGRectGetMaxX(self.view.frame) : CGRectGetMaxY(self.view.frame);
}

//
// -----------------------------------------------------------------------------
- (CGFloat)middle
{
	return self.horizontal ? CGRectGetMidX(self.view.frame) : CGRectGetMidY(self.view.frame);
}

//
// -----------------------------------------------------------------------------
- (CGFloat)thickness
{
	return self.horizontal ? CGRectGetWidth(self.view.frame) : CGRectGetHeight(self.view.frame);
}

@end


#pragma mark - BTInfiniteScrollView

@interface BTInfiniteScrollView ()

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) NSUInteger scrolling;
@property (nonatomic, assign) BOOL dataSourceImplementsDidShowViewForIndex;
@property (nonatomic, assign) NSInteger lastReportedItemIndex;
@property (nonatomic, assign) NSInteger initialItemIndex;

@end


@implementation BTInfiniteScrollView

@dynamic delegate;
@synthesize thickness = _thickness;

#pragma mark - Жизненный цикл

//
// -----------------------------------------------------------------------------
- (instancetype)initWithFrame:(CGRect)frame delegate:(id <BTInfiniteScrollViewDelegate>)delegate horizontal:(BOOL)horizontal position:(BTPosition)position
{
	self = [super initWithFrame:CGRectZero];
	
	if (self) {
		_horizontal = horizontal;
		self.delegate = delegate;
		self.items = [NSMutableArray arrayWithCapacity:10];
		self.position = position;
		self.lastReportedItemIndex = NSIntegerMax;
		self.autoresizesSubviews = NO;
		self.bounces = NO;
		self.scrollsToTop = NO;
		
		if (self.horizontal) {
			self.showsHorizontalScrollIndicator = NO;
		} else {
			self.showsVerticalScrollIndicator = NO;
		}
		
		self.frame = frame;
	}
	
	return self;
}


#pragma mark - Геометрия

//
// -----------------------------------------------------------------------------
- (void)setFrame:(CGRect)frame
{
	if (CGRectIsEmpty(frame)) {
		[super setFrame:frame];
		return;
	}
	
	CGRect bounds = self.bounds;
	CGFloat oldVisibleCenterX = bounds.origin.x + bounds.size.width / 2;
	CGFloat oldVisibleCenterY = bounds.origin.y + bounds.size.height / 2;
	
	[super setFrame:frame];
	
	bounds = self.bounds;
	
	NSUInteger pages = 5;
	
	if (self.horizontal) {
		if (bounds.size.width * pages > self.contentSize.width || bounds.size.height < self.contentSize.height) {
			[super setContentSize:CGSizeMake(bounds.size.width * pages, bounds.size.height)];
		}
	} else {
		if (bounds.size.height * pages > self.contentSize.height || bounds.size.width < self.contentSize.width) {
			[super setContentSize:CGSizeMake(bounds.size.width, bounds.size.height * pages)];
		}
	}
	
	CGFloat newVisibleCenterX = bounds.origin.x + bounds.size.width / 2;
	CGFloat newVisibleCenterY = bounds.origin.y + bounds.size.height / 2;
	
	CGFloat deltaX = oldVisibleCenterX - newVisibleCenterX;
	CGFloat deltaY = oldVisibleCenterY - newVisibleCenterY;
	
	for (BTItem *item in self.items) {
		CGRect viewFrame = item.view.frame;
		
		if (self.horizontal) {
			item.view.frame = CGRectMake(viewFrame.origin.x - deltaX, 0, viewFrame.size.width, self.thickness);
		} else {
			item.view.frame = CGRectMake(0, viewFrame.origin.y - deltaY, self.thickness, viewFrame.size.height);
		}
	}
}

//
// -----------------------------------------------------------------------------
- (void)setContentSize:(CGSize)contentSize
{
	// ничего не делаем тут, ха-ха!
}


#pragma mark - Вёрстка

//
// -----------------------------------------------------------------------------
- (void)layoutSubviews
{
	if (!self.delegate) {
		return;
	}
	
	// сдвинем контент, если надо
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	
	CGRect bounds = self.bounds;
	CGFloat visible = self.horizontal ? bounds.size.width : bounds.size.height;
	
	if (self.scrolling == 0) {
		CGFloat delta = self.horizontal ? self.contentSize.width / 2 - CGRectGetMidX(bounds) : self.contentSize.height / 2 - CGRectGetMidY(bounds);
		
		if (fabs(delta) > visible) {
			delta = visible * (delta > 0 ? 1 : -1);
			
			if (self.horizontal) {
				bounds = CGRectMake(bounds.origin.x + delta, bounds.origin.y, bounds.size.width, bounds.size.height);
			} else {
				bounds = CGRectMake(bounds.origin.x, bounds.origin.y + delta, bounds.size.width, bounds.size.height);
			}
			
			self.bounds = bounds;
			
			for (BTItem *item in self.items) {
				CGRect viewFrame = item.view.frame;
				
				if (self.horizontal) {
					item.view.frame = CGRectMake(viewFrame.origin.x + delta, viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
				} else {
					item.view.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y + delta, viewFrame.size.width, viewFrame.size.height);
				}
			}
		}
	}
	
	[CATransaction commit];
	
	// синхронизируемся с текущей анимацией
	CAAnimation *animation = [self.layer animationForKey:self.layer.animationKeys.firstObject];
	
	if (animation) {
		[CATransaction begin];
		[CATransaction setAnimationDuration:animation.duration];
		[CATransaction setAnimationTimingFunction:animation.timingFunction];
	}
	
	// список вьюх на удаление
	NSMutableArray *viewsToRemove = [NSMutableArray array];
	
	// границы видимого
	CGFloat minVisible = self.horizontal ? CGRectGetMinX(bounds) : CGRectGetMinY(bounds);
	CGFloat maxVisible = self.horizontal ? CGRectGetMaxX(bounds) : CGRectGetMaxY(bounds);
	CGFloat padding = self.horizontal ? CGRectGetWidth(bounds) : CGRectGetHeight(bounds);
	
	BTItem *item;
	
	// добавим недостающие в конце вьюхи
	item = self.items.lastObject;
	
	NSInteger index = 0;
	CGFloat endEdge = 0;
	
	// уже есть вьюхи?
	if (item) {
		index = item.index;
		endEdge = item.max;
	} else {
		index = self.initialItemIndex;
		endEdge = [self placeFirstItemAtIndex:index];
	}
	
	while (endEdge < maxVisible + padding / 2) {
		index++;
		endEdge = [self placeNewItemAtPosition:BTPositionEnd edge:endEdge index:index];
	}
	
	// добавим недостающие в начале вьюхи
	item = self.items.firstObject;
	index = item.index;
	CGFloat startEdge = item.min;
	
	while (startEdge > minVisible - padding / 2) {
		index--;
		startEdge = [self placeNewItemAtPosition:BTPositionStart edge:startEdge index:index];
	}
	
	// удаляем вьюхи только если не в состоянии перехода и если вообще вьюхи есть
	if (self.scrolling == 0 && self.items.count > 0) {
		
		// удалим выпавшие справа вьюхи
		item = self.items.lastObject;
		while (item.min >= maxVisible + padding) {
			[viewsToRemove addObject:item.view];
			[self.items removeLastObject];
			item = self.items.lastObject;
		}
		
		// удалим выпавшие слева вьюхи
		item = self.items.firstObject;
		while (item.max <= minVisible - padding) {
			[viewsToRemove addObject:item.view];
			[self.items removeObjectAtIndex:0];
			item = self.items.firstObject;
		}
	}
	
	// запускаем анимацию
	if (animation) {
		[CATransaction commit];
	}
	
	// уберём выпавшие вьюхи
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animation.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[viewsToRemove makeObjectsPerformSelector:@selector(removeFromSuperview)];
	});
	
	// уведомим, если надо, источник данных
	if (self.dataSourceImplementsDidShowViewForIndex) {
		BTItem *item = [self itemAtPosition:self.position];
		
		if (item && item.index != self.lastReportedItemIndex) {
			[self.delegate infiniteScrollView:self didShowView:item.view atIndex:item.index];
			self.lastReportedItemIndex = item.index;
		}
	}
}


#pragma mark - Свойства

//
// -----------------------------------------------------------------------------
- (void)setDelegate:(id<BTInfiniteScrollViewDelegate>)delegate
{
	[super setDelegate:delegate];
	self.dataSourceImplementsDidShowViewForIndex = [delegate respondsToSelector:@selector(infiniteScrollView:didShowView:atIndex:)];
}

//
// -----------------------------------------------------------------------------
- (void)setHorizontal:(BOOL)horizontal
{
	if (_horizontal == horizontal) {
		return;
	}
	
	NSInteger index = [self indexOfViewAtPosition:BTPositionMiddle];
	
	for (BTItem *item in self.items) {
		[item.view removeFromSuperview];
	}
	
	[self.items removeAllObjects];
	
	_horizontal = horizontal;
	
	if (_horizontal) {
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = YES;
	} else {
		self.showsHorizontalScrollIndicator = YES;
		self.showsVerticalScrollIndicator = NO;
	}
	
	[self setFrame:self.frame];
	[self placeNewItemAtPosition:BTPositionMiddle edge:0 index:index];
	[self setNeedsLayout];
}

//
// -----------------------------------------------------------------------------
- (CGFloat)thickness
{
	if (_thickness == 0) {
		return self.horizontal ? self.bounds.size.height : self.bounds.size.width;
	} else {
		return _thickness;
	}
}

//
// -----------------------------------------------------------------------------
- (void)setThickness:(CGFloat)thickness
{
	_thickness = thickness;
	
	for (BTItem *item in self.items) {
		CGRect viewFrame = item.view.frame;
		
		if (self.horizontal) {
			item.view.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y, viewFrame.size.width, self.thickness);
		} else {
			item.view.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y, self.thickness, viewFrame.size.height);
		}
	}
	
	[self setNeedsLayout];
}


#pragma mark - Информация об объектах

//
// -----------------------------------------------------------------------------
- (NSArray *)views
{
	return [self.items valueForKeyPath:@"@unionOfObjects.view"];
}

//
// -----------------------------------------------------------------------------
- (BTItem *)itemAtIndex:(NSInteger)index
{
	for (BTItem *item in self.items) {
		if (index == item.index) {
			return item;
		}
	}
	
	return nil;
}

//
// -----------------------------------------------------------------------------
- (UIView *)viewAtIndex:(NSInteger)index
{
	BTItem *item = [self itemAtIndex:index];
	return item.view;
}

//
// -----------------------------------------------------------------------------
- (UIView *)viewAtPosition:(BTPosition)position
{
	BTItem *item = [self itemAtPosition:position];
	return item.view;
}

//
// -----------------------------------------------------------------------------
- (NSInteger)indexOfView:(UIView *)view
{
	for (BTItem *item in self.items) {
		if (view == item.view) {
			return item.index;
		}
	}
	
	return NSNotFound;
}

//
// -----------------------------------------------------------------------------
- (BTItem *)itemAtPosition:(BTPosition)position
{
	CGRect bounds = self.bounds;
	CGFloat mark;
	
	switch (position) {
		case BTPositionStart:
			mark = ceil(self.horizontal ? CGRectGetMinX(bounds) : CGRectGetMinY(bounds));
			
			for (BTItem *item in self.items) {
				if (item.min <= mark && item.max > mark) {
					return item;
				}
			}
			break;
			
		case BTPositionMiddle:
			mark = self.horizontal ? CGRectGetMidX(bounds) : CGRectGetMidY(bounds);
			
			for (BTItem *item in self.items) {
				if (item.min <= mark && item.max >= mark) {
					return item;
				}
			}
			break;
			
		case BTPositionEnd:
			mark = floor(self.horizontal ? CGRectGetMaxX(bounds) : CGRectGetMaxY(bounds));
			
			for (BTItem *item in self.items) {
				if (item.min < mark && item.max >= mark) {
					return item;
				}
			}
			break;
	}
	
	return nil;
}

//
// -----------------------------------------------------------------------------
- (NSInteger)indexOfViewAtPosition:(BTPosition)position
{
	BTItem *item = [self itemAtPosition:position];
	return item ? item.index : NSNotFound;
}


#pragma mark - Обновление вьюх

//
// -----------------------------------------------------------------------------
- (void)reloadViewForItem:(BTItem *)item place:(BTPosition)place edge:(CGFloat)edge
{
	// получим новую вьюху
	CGFloat thickness = item.thickness;
	UIView *view = [self.delegate infiniteScrollView:self viewForIndex:item.index thickness:&thickness];
	thickness = ceil(thickness);
	
	// поставим вьюху
	switch (place) {
		case BTPositionStart: {
			if (self.horizontal) {
				view.frame = CGRectMake(edge - thickness, 0, thickness, self.thickness);
			} else {
				view.frame = CGRectMake(0, edge - thickness, self.thickness, thickness);
			}
			break;
		}
		
		case BTPositionMiddle: {
			if (self.horizontal) {
				view.frame = CGRectMake(edge - thickness / 2, 0, thickness, self.thickness);
			} else {
				view.frame = CGRectMake(0, edge - thickness / 2, self.thickness, thickness);
			}
			break;
		}
		
		case BTPositionEnd: {
			if (self.horizontal) {
				view.frame = CGRectMake(edge, 0, thickness, self.thickness);
			} else {
				view.frame = CGRectMake(0, edge, self.thickness, thickness);
			}
			break;
		}
	}
	
	[item.view removeFromSuperview];
	[self addSubview:view];
	item.view = view;
}

//
// -----------------------------------------------------------------------------
- (void)reloadViews
{
	// определим начальную вьюху
	BTItem *targetItem = [self itemAtPosition:self.position];
	
	switch (self.position) {
		case BTPositionStart: {
			[self reloadViewForItem:targetItem place:BTPositionEnd edge:targetItem.min];
			break;
		}
			
		case BTPositionMiddle: {
			[self reloadViewForItem:targetItem place:BTPositionMiddle edge:targetItem.middle];
			break;
		}
			
		case BTPositionEnd: {
			[self reloadViewForItem:targetItem place:BTPositionStart edge:targetItem.max];
			break;
		}
	}
	
	BTItem *previousItem;
	BTItem *item;
	
	// перезагрузим вьюхи после начальной
	previousItem = targetItem;
	item = [self itemAtIndex:(previousItem.index + 1)];
	
	while (item) {
		[self reloadViewForItem:item place:BTPositionEnd edge:previousItem.max];
		previousItem = item;
		item = [self itemAtIndex:(previousItem.index + 1)];
	}
	
	// перезагрузим вьюхи до начальной
	previousItem = targetItem;
	item = [self itemAtIndex:(previousItem.index - 1)];
	
	while (item) {
		[self reloadViewForItem:item place:BTPositionStart edge:previousItem.min];
		previousItem = item;
		item = [self itemAtIndex:(previousItem.index - 1)];
	}
	
	[self setNeedsLayout];
}


#pragma mark - Сброс

//
// -----------------------------------------------------------------------------
- (void)resetWithIndex:(NSInteger)index
{
	if (CGRectIsEmpty(self.bounds)) {
		self.initialItemIndex = index;
		return;
	}
	
	for (BTItem *item in self.items) {
		[item.view removeFromSuperview];
	}
	
	[self.items removeAllObjects];
	
	[self placeFirstItemAtIndex:index];
	[self setNeedsLayout];
}


#pragma mark - Позиционирование

//
// -----------------------------------------------------------------------------
- (void)scrollToViewAtIndex:(NSInteger)index position:(BTPosition)position offset:(CGFloat)offset animated:(BOOL)animated
{
	CGRect bounds = UIEdgeInsetsInsetRect(self.bounds, self.contentInset);
	
	if (CGRectIsEmpty(bounds)) {
		return;
	}
	
	CGFloat visible = self.horizontal ? bounds.size.width * 3 : bounds.size.height * 3;
	
	// направление
	BTItem *firstItem = self.items.firstObject;
	BTItem *lastItem = self.items.lastObject;
	BOOL start = index < firstItem.index;
	
	// целевая вьюха уже есть?
	BTItem *targetItem = nil;
	
	for (BTItem *item in self.items) {
		if (item.index == index) {
			targetItem = item;
			break;
		}
	}
	
	// такой вьюхи ещё нет?
	if (!targetItem) {
		
		// массив добавляемых вьюх
		NSMutableArray *newItems = [NSMutableArray array];
		
		// получим целевую вьюху
		targetItem = [self getNewItemForIndex:index];
		[newItems addObject:targetItem];
		
		// общая ширина для заполнения между целевой и существующими вьюхами
		CGFloat gap;
		
		switch (position) {
			case BTPositionStart:
				gap = start ? visible - targetItem.thickness + offset : -offset;
				break;
				
			case BTPositionMiddle:
				gap = start ? (visible - targetItem.thickness) / 2 + offset : (visible - targetItem.thickness) / 2 - offset;
				break;
				
			case BTPositionEnd:
				gap = start ? -offset : visible - targetItem.thickness + offset;
				break;
		}
		
		// получим вьюхи между целевой и существующими
		NSInteger indexDelta = (start ? firstItem.index - index : index - lastItem.index) - 1;
		NSInteger gapItemIndex = index;
		
		while (indexDelta > 0 && gap >= 0) {
			gapItemIndex += start ? 1 : -1;
			BTItem *item = [self getNewItemForIndex:gapItemIndex];
			
			if (start) {
				[newItems addObject:item];
			} else {
				[newItems insertObject:item atIndex:0];
			}
			
			gap -= item.thickness;
			indexDelta--;
		}
		
		// поставим вьюхи
		if (start) {
			
			// ставим слева
			CGFloat startEdge = firstItem.min;
			
			for (NSInteger newItemIndex = newItems.count - 1; newItemIndex >= 0; newItemIndex--) {
				BTItem *item = newItems[newItemIndex];
				
				if (self.horizontal) {
					item.view.frame = CGRectMake(startEdge - item.thickness, 0, item.thickness, self.thickness);
				} else {
					item.view.frame = CGRectMake(0, startEdge - item.thickness, self.thickness, item.thickness);
				}
				
				startEdge = item.min;
				[self addSubview:item.view];
				[self.items insertObject:item atIndex:0];
			}
		} else {
			
			// ставим справа
			CGFloat endEdge = lastItem.max;
			
			for (NSInteger newItemIndex = 0; newItemIndex < newItems.count; newItemIndex++) {
				BTItem *item = newItems[newItemIndex];
				
				if (self.horizontal) {
					item.view.frame = CGRectMake(endEdge, 0, item.thickness, self.thickness);
				} else {
					item.view.frame = CGRectMake(0, endEdge, self.thickness, item.thickness);
				}
				
				endEdge = item.max;
				[self addSubview:item.view];
				[self.items addObject:item];
			}
		}
	}
	
	// позиция, к которой будем крутить
	switch (position) {
		case BTPositionStart:
			if (self.horizontal) {
				bounds = CGRectMake(targetItem.min + offset, bounds.origin.y, bounds.size.width, bounds.size.height);
			} else {
				bounds = CGRectMake(bounds.origin.x, targetItem.min + offset, bounds.size.width, bounds.size.height);
			}
			break;
			
		case BTPositionMiddle:
			if (self.horizontal) {
				bounds = CGRectMake(targetItem.min - (bounds.size.width - targetItem.thickness) / 2 + offset, bounds.origin.y, bounds.size.width, bounds.size.height);
			} else {
				bounds = CGRectMake(bounds.origin.x, targetItem.min - (bounds.size.height - targetItem.thickness) / 2 + offset, bounds.size.width, bounds.size.height);
			}
			break;
			
		case BTPositionEnd:
			if (self.horizontal) {
				bounds = CGRectMake(targetItem.max - bounds.size.width + offset, bounds.origin.y, bounds.size.width, bounds.size.height);
			} else {
				bounds = CGRectMake(bounds.origin.x, targetItem.max - bounds.size.height + offset, bounds.size.width, bounds.size.height);
			}
			break;
	}
	
	// готовимся к прокрутке
	self.scrolling++;
	NSTimeInterval duration = animated ? 0.25 : 0;
	UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
	
	// останавливаем текущие анимации
	[self setContentOffset:self.contentOffset animated:NO];
	
	// крутим
	[UIView animateWithDuration:duration delay:0 options:options animations:^{
		self.bounds = bounds;
	} completion:^(BOOL finished) {
		self.scrolling--;
		[self setNeedsLayout];
	}];
}

//
// -----------------------------------------------------------------------------
- (void)scrollToViewAtIndex:(NSInteger)index position:(BTPosition)position animated:(BOOL)animated
{
	[self scrollToViewAtIndex:index position:position offset:0 animated:YES];
}


#pragma mark - Инструменты

//
// -----------------------------------------------------------------------------
- (BTItem *)getNewItemForIndex:(NSInteger)index
{
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	
	CGRect bounds = UIEdgeInsetsInsetRect(self.bounds, self.contentInset);
	CGFloat thickness = self.horizontal ? bounds.size.width : bounds.size.height;
	UIView *view = [self.delegate infiniteScrollView:self viewForIndex:index thickness:&thickness];
	thickness = ceil(thickness);
	
	if (self.horizontal) {
		view.frame = CGRectMake(0, 0, thickness, self.thickness);
	} else {
		view.frame = CGRectMake(0, 0, self.thickness, thickness);
	}
	
	[CATransaction commit];
	
	BTItem *item = [[BTItem alloc] init];
	item.horizontal = self.horizontal;
	item.index = index;
	item.view = view;
	
	return item;
}

//
// -----------------------------------------------------------------------------
- (CGFloat)placeNewItemAtPosition:(BTPosition)position edge:(CGFloat)edge index:(NSInteger)index
{
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	
	CGRect bounds = UIEdgeInsetsInsetRect(self.bounds, self.contentInset);
	CGFloat thickness = self.horizontal ? bounds.size.width : bounds.size.height;
	UIView *view = [self.delegate infiniteScrollView:self viewForIndex:index thickness:&thickness];
	thickness = ceil(thickness);
	
	switch (position) {
		case BTPositionStart:
			if (self.horizontal) {
				view.frame = CGRectMake(edge - thickness, 0, thickness, self.thickness);
			} else {
				view.frame = CGRectMake(0, edge - thickness, self.thickness, thickness);
			}
			break;
			
		case BTPositionMiddle:
			if (self.horizontal) {
				view.frame = CGRectMake(bounds.origin.x + (bounds.size.width - thickness) / 2, 0, thickness, self.thickness);
			} else {
				view.frame = CGRectMake(0, bounds.origin.y + (bounds.size.height - thickness) / 2, self.thickness, thickness);
			}
			break;
			
		case BTPositionEnd:
			if (self.horizontal) {
				view.frame = CGRectMake(edge, 0, thickness, self.thickness);
			} else {
				view.frame = CGRectMake(0, edge, self.thickness, thickness);
			}
			break;
	}
	
	
	[self addSubview:view];
	
	[CATransaction commit];
	
	BTItem *item = [[BTItem alloc] init];
	item.horizontal = self.horizontal;
	item.index = index;
	item.view = view;
	
	switch (position) {
		case BTPositionStart:
			[self.items insertObject:item atIndex:0];
			return item.min;
			
		case BTPositionMiddle:
			[self.items addObject:item];
			return item.max;
			
		case BTPositionEnd:
			[self.items addObject:item];
			return item.max;
	}
}

//
// -----------------------------------------------------------------------------
- (CGFloat)placeFirstItemAtIndex:(NSInteger)index
{
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	
	CGRect bounds = UIEdgeInsetsInsetRect(self.bounds, self.contentInset);
	CGFloat thickness = self.horizontal ? bounds.size.width : bounds.size.height;
	UIView *view = [self.delegate infiniteScrollView:self viewForIndex:index thickness:&thickness];
	thickness = ceil(thickness);
	
	switch (self.position) {
		case BTPositionStart:
			if (self.horizontal) {
				view.frame = CGRectMake(bounds.origin.x, 0, thickness, self.thickness);
			} else {
				view.frame = CGRectMake(0, bounds.origin.y, self.thickness, thickness);
			}
			break;
			
		case BTPositionMiddle:
			if (self.horizontal) {
				view.frame = CGRectMake(bounds.origin.x + (bounds.size.width - thickness) / 2, 0, thickness, self.thickness);
			} else {
				view.frame = CGRectMake(0, bounds.origin.y + (bounds.size.height - thickness) / 2, self.thickness, thickness);
			}
			break;
			
		case BTPositionEnd:
			if (self.horizontal) {
				view.frame = CGRectMake(bounds.origin.x + bounds.size.width - thickness, 0, thickness, self.thickness);
			} else {
				view.frame = CGRectMake(0, bounds.origin.y + bounds.size.height - thickness, self.thickness, thickness);
			}
			break;
	}
	
	
	[self addSubview:view];
	
	[CATransaction commit];
	
	BTItem *item = [[BTItem alloc] init];
	item.horizontal = self.horizontal;
	item.index = index;
	item.view = view;
	
	[self.items addObject:item];
	
	return item.max;
}

@end
