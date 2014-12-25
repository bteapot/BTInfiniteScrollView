//
//  BTSettingsVC.m
//  BTInfiniteScrollView
//
//  Created by Денис Либит on 22.12.2014.
//  Copyright (c) 2014 Денис Либит. All rights reserved.
//

#import "BTSettingsVC.h"
#import "BTPlaygroundVC.h"
#import "BTItemView.h"


@interface BTSettingsVC () <BTInfiniteScrollViewDelegate>

@property (nonatomic, weak) BTPlaygroundVC *playgroundVC;
@property (nonatomic, assign) BOOL variableThickness;
@property (nonatomic, assign) CGFloat baseThickness;

@end


@implementation BTSettingsVC

#pragma mark - Lifecycle

//
// -----------------------------------------------------------------------------
- (instancetype)initWithPlayground:(BTPlaygroundVC *)playgroundVC;
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	
	if (self) {
		self.playgroundVC = playgroundVC;
		self.playgroundVC.infiniteScrollView.delegate = self;
		self.title = @"Settings";
		
		self.variableThickness = YES;
		self.baseThickness = 0.5;
	}
	
	return self;
}


#pragma mark - User events

//
// -----------------------------------------------------------------------------
- (void)settingStepBy:(UIStepper *)sender
{
	NSInteger index = [self.playgroundVC.infiniteScrollView indexOfViewAtPosition:BTPositionMiddle];
	[self.playgroundVC.infiniteScrollView scrollToViewAtIndex:(index + sender.value) position:BTPositionMiddle animated:YES];
	sender.value = 0;
}

//
// -----------------------------------------------------------------------------
- (void)settingHorizontalChanged:(UISwitch *)sender
{
	self.playgroundVC.infiniteScrollView.horizontal = sender.on;
}

//
// -----------------------------------------------------------------------------
- (void)settingWidthChanged:(UISlider *)sender
{
	self.playgroundVC.width = sender.value;
}

//
// -----------------------------------------------------------------------------
- (void)settingHeightChanged:(UISlider *)sender
{
	self.playgroundVC.height = sender.value;
}

//
// -----------------------------------------------------------------------------
- (void)settingBorderChanged:(UISwitch *)sender
{
	if (sender.on) {
		self.playgroundVC.infiniteScrollView.layer.borderWidth = 1;
		self.playgroundVC.infiniteScrollView.layer.borderColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.3].CGColor;
	} else {
		self.playgroundVC.infiniteScrollView.layer.borderWidth = 0;
	}
}

//
// -----------------------------------------------------------------------------
- (void)settingClipChanged:(UISwitch *)sender
{
	self.playgroundVC.infiniteScrollView.clipsToBounds = sender.on;
}

//
// -----------------------------------------------------------------------------
- (void)settingVariableThicknessChanged:(UISwitch *)sender
{
	self.variableThickness = sender.on;
}

//
// -----------------------------------------------------------------------------
- (void)settingBaseThicknessChanged:(UISlider *)sender
{
	self.baseThickness = sender.value;
}


#pragma mark - UITableViewController delegate

//
// -----------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

//
// -----------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			// info
			return 4;
		case 1:
			// geometry
			return 5;
		case 2:
			// items
			return 2;
		default:
			return 0;
	}
}

//
// -----------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return @"Info";
		case 1:
			return @"Geometry";
		case 2:
			return @"Items";
		default:
			return nil;
	}
}

//
// -----------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	
	if (indexPath.section == 0 && indexPath.row == 0) {
		static NSString *cellValueID = @"cellValueID";
		cell = [tableView dequeueReusableCellWithIdentifier:cellValueID];
		
		if (!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellValueID];
		}
	} else {
		static NSString *cellDefaultID = @"cellDefaultID";
		cell = [tableView dequeueReusableCellWithIdentifier:cellDefaultID];
		
		if (!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellDefaultID];
		}
	}
	
	switch (indexPath.section) {
		case 0: {
			// info
			switch (indexPath.row) {
				case 0: {
					// index
					cell.textLabel.text = @"Current index";
					break;
				}
				case 1: {
					// 1
					cell.textLabel.text = @"Step by 1";
					UIStepper *stepperView = [[UIStepper alloc] init];
					stepperView.value = 0;
					stepperView.minimumValue = -1;
					stepperView.maximumValue = 1;
					stepperView.stepValue = 1;
					[stepperView addTarget:self action:@selector(settingStepBy:) forControlEvents:UIControlEventValueChanged];
					cell.accessoryView = stepperView;
					break;
				}
				case 2: {
					// 10
					cell.textLabel.text = @"Step by 10";
					UIStepper *stepperView = [[UIStepper alloc] init];
					stepperView.value = 0;
					stepperView.minimumValue = -10;
					stepperView.maximumValue = 10;
					stepperView.stepValue = 10;
					[stepperView addTarget:self action:@selector(settingStepBy:) forControlEvents:UIControlEventValueChanged];
					cell.accessoryView = stepperView;
					break;
				}
				case 3: {
					// 1000
					cell.textLabel.text = @"Step by 1000";
					UIStepper *stepperView = [[UIStepper alloc] init];
					stepperView.value = 0;
					stepperView.minimumValue = -1000;
					stepperView.maximumValue = 1000;
					stepperView.stepValue = 1000;
					[stepperView addTarget:self action:@selector(settingStepBy:) forControlEvents:UIControlEventValueChanged];
					cell.accessoryView = stepperView;
					break;
				}
				default:
					break;
			}
			break;
		}
		case 1: {
			// geometry
			switch (indexPath.row) {
				case 0: {
					// horizontal
					cell.textLabel.text = @"Horizontal";
					UISwitch *switchView = [[UISwitch alloc] init];
					switchView.on = self.playgroundVC.infiniteScrollView.horizontal;
					[switchView addTarget:self action:@selector(settingHorizontalChanged:) forControlEvents:UIControlEventValueChanged];
					cell.accessoryView = switchView;
					break;
				}
				case 1: {
					// width
					cell.textLabel.text = @"Width";
					UISlider *sliderView = [[UISlider alloc] init];
					sliderView.value = self.playgroundVC.width;
					[sliderView addTarget:self action:@selector(settingWidthChanged:) forControlEvents:UIControlEventValueChanged];
					cell.accessoryView = sliderView;
					break;
				}
				case 2: {
					// height
					cell.textLabel.text = @"Height";
					UISlider *sliderView = [[UISlider alloc] init];
					sliderView.value = self.playgroundVC.height;
					[sliderView addTarget:self action:@selector(settingHeightChanged:) forControlEvents:UIControlEventValueChanged];
					cell.accessoryView = sliderView;
					break;
				}
				case 3: {
					// border
					cell.textLabel.text = @"Border";
					UISwitch *switchView = [[UISwitch alloc] init];
					switchView.on = self.playgroundVC.infiniteScrollView.layer.borderWidth > 0;
					[switchView addTarget:self action:@selector(settingBorderChanged:) forControlEvents:UIControlEventValueChanged];
					cell.accessoryView = switchView;
					break;
				}
				case 4: {
					// clip
					cell.textLabel.text = @"Clip";
					UISwitch *switchView = [[UISwitch alloc] init];
					switchView.on = self.playgroundVC.infiniteScrollView.clipsToBounds;
					[switchView addTarget:self action:@selector(settingClipChanged:) forControlEvents:UIControlEventValueChanged];
					cell.accessoryView = switchView;
					break;
				}
				default:
					break;
			}
			break;
		}
		case 2: {
			// items
			switch (indexPath.row) {
				case 0: {
					// variable thickness
					cell.textLabel.text = @"Variable thickness";
					UISwitch *switchView = [[UISwitch alloc] init];
					switchView.on = self.variableThickness;
					[switchView addTarget:self action:@selector(settingVariableThicknessChanged:) forControlEvents:UIControlEventValueChanged];
					cell.accessoryView = switchView;
					break;
				}
				case 1: {
					// height
					cell.textLabel.text = @"Base thickness";
					UISlider *sliderView = [[UISlider alloc] init];
					sliderView.value = self.playgroundVC.height;
					[sliderView addTarget:self action:@selector(settingBaseThicknessChanged:) forControlEvents:UIControlEventValueChanged];
					cell.accessoryView = sliderView;
					break;
				}
				default:
					break;
			}
			break;
		}
		default:
			break;
	}
	
	return cell;
}


#pragma mark - BTInfiniteScrollView delegate

//
// -----------------------------------------------------------------------------
- (UIView *)infiniteScrollView:(BTInfiniteScrollView *)infiniteScrollView viewForIndex:(NSInteger)index thickness:(CGFloat *)thickness
{
	*thickness *= self.baseThickness + 0.5;
	
	if (self.variableThickness) {
		*thickness *= (CGFloat)(arc4random() % 100) / 100;
	}
	
	*thickness = MAX(*thickness, 40);
	
	return [[BTItemView alloc] initWithIndex:index];
}

//
// -----------------------------------------------------------------------------
- (void)infiniteScrollView:(BTInfiniteScrollView *)infiniteScrollView didShowView:(UIView *)view atIndex:(NSInteger)index
{
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)index];
}

@end
