# BTInfiniteScrollView CHANGELOG


## 1.1.0

Default item thickness now respects scroll view's edge insets.
Scroll view now maintains padding of extra items by asking its delegate for new items earlier, at extra half bounds length, and by disposing of items later, at full bounds length.

## 1.0.9

Item placements synchronized with ongoing animation.

## 1.0.8

Suspend layout with empty `delegate`.

## 1.0.7

Disable `scrollsToTop` functionality.

## 1.0.6

Use `weak` in `delegate` property declaration.

## 1.0.5

Corrected the wrong placement of views when using -reloadViews method. 
Fixes #2.

## 1.0.4

Improved internal bounds shift.
Added CHANGELOG.

## 1.0.3

Added method to scroll to view at specified index with offset in points.

## 1.0.2

Cleaned Podspec file.

## 1.0.1

Version bump.

## 1.0.0

Initial release.
