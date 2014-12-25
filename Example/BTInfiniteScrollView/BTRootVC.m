//
//  BTRootVC.m
//  BTInfiniteScrollView
//
//  Created by Денис Либит on 12/22/2014.
//  Copyright (c) 2014 Денис Либит. All rights reserved.
//

#import "BTRootVC.h"
#import "BTSettingsVC.h"
#import "BTPlaygroundVC.h"


@interface BTRootVC () <UISplitViewControllerDelegate>

@property (nonatomic, strong) BTSettingsVC *settingsVC;
@property (nonatomic, strong) BTPlaygroundVC *playgroundVC;
@property (nonatomic, strong) UINavigationController *settingsNC;
@property (nonatomic, strong) UINavigationController *playgroundNC;

@end


@implementation BTRootVC

#pragma mark - Lifecycle

//
// -----------------------------------------------------------------------------
- (instancetype)init
{
	self = [super init];
	
	if (self) {
		self.playgroundVC = [[BTPlaygroundVC alloc] init];
		self.settingsVC = [[BTSettingsVC alloc] initWithPlayground:self.playgroundVC];
		
		self.settingsNC = [[UINavigationController alloc] initWithRootViewController:self.settingsVC];
		self.playgroundNC = [[UINavigationController alloc] initWithRootViewController:self.playgroundVC];
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			self.settingsVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(showPlayground)];
		}
		
		self.playgroundVC.navigationItem.leftBarButtonItem = self.displayModeButtonItem;
		self.playgroundVC.navigationItem.leftItemsSupplementBackButton = YES;
		
		self.viewControllers = @[self.settingsNC, self.playgroundNC];
		
		self.delegate = self;
	}
	
	return self;
}

#pragma mark - User events

//
// -----------------------------------------------------------------------------
- (void)showPlayground
{
	[self showDetailViewController:self.playgroundNC sender:self];
}


#pragma mark - UISplitViewControllerDelegate

//
// -----------------------------------------------------------------------------
- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
	if ([secondaryViewController isKindOfClass:[UINavigationController class]] &&
		[[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[BTPlaygroundVC class]]) {
		return YES;
	} else {
		return NO;
	}
}

@end
