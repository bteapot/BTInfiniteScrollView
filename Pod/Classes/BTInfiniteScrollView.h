//
//  BTInfiniteScrollView.h
//  BTInfiniteScrollView
//
//  Created by Денис Либит on 22.12.2014.
//  Copyright (c) 2014 Денис Либит. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 BTInfiniteScrollView's item position.
 */
typedef NS_ENUM(NSUInteger, BTPosition) {
	/**
	 Start position:
	 @discussion Left edge of BTInfiniteScrollView with horizontal scrolling mode and top edge with vertical scrolling mode.
	 */
	BTPositionStart,
	/**
	 Middle position:
	 @discussion Middle of BTInfiniteScrollView.
	 */
	BTPositionMiddle,
	/**
	 End position:
	 @discussion Right edge of BTInfiniteScrollView with horizontal scrolling mode and bottom edge with vertical scrolling mode.
	 */
	BTPositionEnd,
};


@class BTInfiniteScrollView;

/**
 Delegate protocol of BTInfiniteScrollView.
 @discussion BTInfiniteScrollViewDelegate protocol extends UIScrollViewDelegate protocol with two methods:
 - infiniteScrollView:viewForIndex:thickness: - asking delegate for views.
 - infiniteScrollView:didShowView:atIndex: - notifying delegate of items shown as a result of user scrolling.
 */
@protocol BTInfiniteScrollViewDelegate <UIScrollViewDelegate>

/**
 Asks delegate for view for specified index.
 @discussion The returned UIView object represents an item in infiniteScrollView at specified index. This view will be resized to height of infiniteScrollView's bounds for horizontal mode or width for vertical mode. The 'thickness' parameter will contain width of infiniteScrollView's bounds for horizontal mode or height for vertical mode, thus defaulting item size to full infiniteScrollView's bounds rect. Delegate can modify this parameter to alter returned item thickness.
 @param infiniteScrollView A BTInfiniteScrollView object requesting item view.
 @param index              An index locating item view in infiniteScrollView.
 @param thickness          Width of item view for horizontal mode, or height for vertical mode.
 @return An object inheriting from UIView that the infiniteScrollView will show at specified index.
 */
- (UIView *)infiniteScrollView:(BTInfiniteScrollView *)infiniteScrollView viewForIndex:(NSInteger)index thickness:(CGFloat *)thickness;

@optional

/**
 Notifies the delegate that the view of item at specific index was shown.
 @discussion Delegate can implement this method to receive notifications about items shown by infiniteScrollView when user scrolls its contents. The value of 'position' parameter of infiniteScrollView determines the location of detection point. For example, infiniteScrollView will report items appearing at the left edge when it's BTPositionStart and when in horizontal mode.
 @param infiniteScrollView A BTInfiniteScrollView object
 @param view               UIView's descendant object representing an item in infiniteScrollView.
 @param index              Index of shown item.
 */
- (void)infiniteScrollView:(BTInfiniteScrollView *)infiniteScrollView didShowView:(UIView *)view atIndex:(NSInteger)index;

@end

/**
 Subclass of UIScrollView implementing infinite scrolling.
 @discussion
 */
@interface BTInfiniteScrollView : UIScrollView

/**
 Delegate object of BTInfiniteScrollView.
 */
@property (nonatomic, weak) id <BTInfiniteScrollViewDelegate> delegate;
/**
 Default thickness of item views.
 @discussion In horizontal mode this attribute defines default width of item views, and height - in vertical mode.
 */
@property (nonatomic, assign) CGFloat thickness;
/**
 Scrolling mode.
 */
@property (nonatomic, assign) BOOL horizontal;
/**
 Position that used to place first item and to notify delegate of shown item views.
 */
@property (nonatomic, assign) BTPosition position;
/**
 Item views currently contained by BTInfiniteScrollView.
 */
@property (nonatomic, readonly) NSArray *views;

/**
 Initializes and returns an infinite scroll view object.
 @param frame      A rectangle specifying the initial location and size of the infinite scroll view in its superview's coordinates.
 @param delegate   Delegate implementing 'BTInfiniteScrollViewDelegate' protocol.
 @param horizontal Scrolling mode, 'YES' for horizontal, 'NO' for vertical.
 @param position   Position that used to place first item and to notify delegate of shown item views.
 @return Returns an initialized 'BTInfiniteScrollView' object or 'nil' if the object could not be successfully initialized.
 */
- (instancetype)initWithFrame:(CGRect)frame delegate:(id <BTInfiniteScrollViewDelegate>)delegate horizontal:(BOOL)horizontal position:(BTPosition)position;
/**
 Returns view of item at specified index.
 @param index The index of item's view.
 @return An object representing an item in the infinite scroll view or nil if the item does not exists in item stack.
 */
- (UIView *)viewAtIndex:(NSInteger)index;
/**
 Returns view of item at specified position.
 @param position Position relative to receiver's bounds rectangle.
 @return An object whose frame overlaps specified position in the infinite scroll view's bounds or nil if no such object found.
 */
- (UIView *)viewAtPosition:(BTPosition)position;
/**
 Returns an index of item for specified view.
 @param view View representing an item in infinite scroll view.
 @return Index of item with specified view or NSNotFound if such item does not exists in item stack.
 */
- (NSInteger)indexOfView:(UIView *)view;
/**
 Returns index of item whose view located at specified position.
 @param position Position relative to receiver's bounds rectangle.
 @return Index of item at specified position or NSNotFound if no such item exists.
 */
- (NSInteger)indexOfViewAtPosition:(BTPosition)position;
/**
 Scrolls infinite scroll view to item at specified index.
 @param index    Index of item.
 @param position Position at which specified item's view will be located when the scrolling ends.
 @param animated YES if the scrolling should be animated, NO if it should be immediate.
 */
- (void)scrollToViewAtIndex:(NSInteger)index position:(BTPosition)position animated:(BOOL)animated;
/**
 Scrolls infinite scroll view to item at specified index plus specified offset.
 @param index    Index of item.
 @param position Position at which specified item's view will be located when the scrolling ends.
 @param offset   Offset in points that will be added to final scroll position.
 @param animated YES if the scrolling should be animated, NO if it should be immediate.
 */
- (void)scrollToViewAtIndex:(NSInteger)index position:(BTPosition)position offset:(CGFloat)offset animated:(BOOL)animated;
/**
 Reloads the items of the receiver.
 */
- (void)reloadViews;
/**
 Removes all items from the receiver and asks delegate for the new items starting at specified index.
 @param index Index of the first new item.
 */
- (void)resetWithIndex:(NSInteger)index;

@end
