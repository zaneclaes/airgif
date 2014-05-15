//
//  AGMainWindow.m
//  AirGif
//
//  Created by Zane Claes on 5/6/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGMainWindow.h"
#import "ITSideBar.h"
#import "AGSearchViewController.h"
#import "AGTagViewController.h"
#import "AGSettingsViewController.h"
#import <QuartzCore/QuartzCore.h>

static NSInteger const kSideBarCellSize = 60;
static CGSize const kMainContentSize = {315,480};

@interface AGMainWindow ()
@property (nonatomic, strong) NSScrollView *sidebarWrapper;       // Scroll wrapper
@property (nonatomic, strong) ITSidebar *sidebar;                 // Left-side bar.
@property (nonatomic, strong) NSView *mainContentView;            // The wrapper for all content.
@property (nonatomic, readonly) AGContentViewController *currentViewController;
@property (nonatomic, strong) AGSearchViewController *searchViewController;
@property (nonatomic, strong) AGTagViewController *tagViewController;
@property (nonatomic, strong) AGSettingsViewController *settingsViewController;
@end

@implementation AGMainWindow

- (void)onSidebarChanged {
  NSArray *titles = @[NSLocalizedString(@"Search", @""),
                      NSLocalizedString(@"Tag Game", @""),
                      NSLocalizedString(@"Settings", @"")];
  self.title = [NSString stringWithFormat:@"%@ | AirGif",titles[self.sidebar.selectedIndex]];
  NSArray *viewControllers = @[self.searchViewController,self.tagViewController,self.settingsViewController];
  AGContentViewController *viewController = viewControllers[self.sidebar.selectedIndex];
  [self.currentViewController viewWillDisappear];
  [viewController viewWillAppear];

  [self.currentViewController.view removeFromSuperview];
  viewController.view.frame = self.mainContentView.bounds;
  [self.mainContentView addSubview:viewController.view];

  [self.currentViewController viewDidDisappear];
  _currentViewController = viewController;
  [viewController viewDidAppear];

  [AGAnalytics view:titles[self.sidebar.selectedIndex]];
}

- (void)awakeFromNib {
  [super awakeFromNib];
  self.mainContentView = [[NSView alloc] initWithFrame:NSMakeRect(kSideBarCellSize, 0, kMainContentSize.width, kMainContentSize.height)];
  CALayer *viewLayer = [CALayer layer];
  [viewLayer setBackgroundColor:CGColorCreateGenericRGB(1,1,1,1)]; //RGB plus Alpha Channel
  [self.mainContentView setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
  [self.mainContentView setLayer:viewLayer];
  [self.contentView addSubview:self.mainContentView];

  // Build the content views
  self.searchViewController = [[AGSearchViewController alloc] initWithNibName:@"AGSearchViewController" bundle:nil];
  self.tagViewController = [[AGTagViewController alloc] initWithNibName:@"AGTagViewController" bundle:nil];
  self.settingsViewController = [[AGSettingsViewController alloc] initWithNibName:@"AGSettingsViewController" bundle:nil];

  self.sidebarWrapper = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, kSideBarCellSize, kMainContentSize.height)];
  [self.sidebarWrapper setBorderType:NSNoBorder];
  self.sidebarWrapper.backgroundColor = [NSColor blackColor];
  [self.contentView addSubview:self.sidebarWrapper];

  self.sidebar = [[ITSidebar alloc] initWithFrame:CGRectZero];
  self.sidebar.backgroundColor = [NSColor greenColor];
  self.sidebar.cellSize = CGSizeMake(kSideBarCellSize,kSideBarCellSize);
  self.sidebar.allowsEmptySelection = NO;
  [self.sidebar addItemWithImage:[NSImage imageNamed:@"708-search"]
                  alternateImage:[NSImage imageNamed:@"708-search-selected"]
                          target:self action:@selector(onSidebarChanged)];
  [self.sidebar addItemWithImage:[NSImage imageNamed:@"909-tags"]
                  alternateImage:[NSImage imageNamed:@"909-tags-selected"]
                          target:self action:@selector(onSidebarChanged)];
  [self.sidebar addItemWithImage:[NSImage imageNamed:@"912-gears"]
                  alternateImage:[NSImage imageNamed:@"912-gears-selected"]
                          target:self action:@selector(onSidebarChanged)];
  self.sidebar.selectedIndex = 0;
  [self.sidebarWrapper addSubview:self.sidebar];
  [self.sidebar awakeFromNib];// Triggers setup manually...
  [self onSidebarChanged];
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
  contentRect = NSMakeRect(0, 0, kMainContentSize.width + kSideBarCellSize, kMainContentSize.height);
  if((self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag])) {
    self.hasMenuBarIcon = YES;
    self.menuBarIcon = [NSImage imageNamed:@"Status"];
    self.highlightedMenuBarIcon = [NSImage imageNamed:@"StatusHighlighted"];
    self.attachedToMenuBar = YES;
    self.isDetachable = NO;
    self.backgroundColor = [NSColor whiteColor];
  }
  return self;
}

@end
