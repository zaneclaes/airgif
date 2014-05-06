//
//  AGMainWindow.m
//  AirGif
//
//  Created by an Airbnb Engineer on 5/6/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGMainWindow.h"
#import "ITSideBar.h"
#import <QuartzCore/QuartzCore.h>

static NSInteger const kSideBarCellSize = 60;
static CGSize const kMainContentSize = {300,400};

@interface AGMainWindow ()
@property (nonatomic, strong) NSScrollView *sidebarWrapper; // Scroll wrapper
@property (nonatomic, strong) ITSidebar *sidebar;           // Left-side bar.
@property (nonatomic, strong) NSView *mainContentView;      // The wrapper for all content.
@end

@implementation AGMainWindow

- (void)onSidebarChanged {
  NSArray *titles = @[NSLocalizedString(@"Search", @""),
                      NSLocalizedString(@"Tag Game", @""),
                      NSLocalizedString(@"Account", @""),
                      NSLocalizedString(@"Settings", @"")];
  self.title = [NSString stringWithFormat:@"%@ | AirGif",titles[self.sidebar.selectedIndex]];
}

- (id)init {
  NSRect frame = NSMakeRect(0, 0, kMainContentSize.width + kSideBarCellSize, kMainContentSize.height);
  if((self = [super initWithContentRect:frame styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:NO])) {
    self.hasMenuBarIcon = YES;
    self.menuBarIcon = [NSImage imageNamed:@"Status"];
    self.highlightedMenuBarIcon = [NSImage imageNamed:@"StatusHighlighted"];
    self.attachedToMenuBar = YES;
    self.isDetachable = NO;
    self.backgroundColor = [NSColor whiteColor];
    self.title = @"AirGif";

    self.mainContentView = [[NSView alloc] initWithFrame:NSMakeRect(kSideBarCellSize, 0, kMainContentSize.width, kMainContentSize.height)];
    CALayer *viewLayer = [CALayer layer];
    [viewLayer setBackgroundColor:CGColorCreateGenericRGB(1,1,1,1)]; //RGB plus Alpha Channel
    [self.mainContentView setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
    [self.mainContentView setLayer:viewLayer];
    [self.contentView addSubview:self.mainContentView];

    self.sidebarWrapper = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, kSideBarCellSize, kMainContentSize.height)];
    [self.sidebarWrapper setBorderType:NSNoBorder];
    [self.sidebarWrapper setHasVerticalScroller:YES];
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
    [self.sidebar addItemWithImage:[NSImage imageNamed:@"973-user"]
                    alternateImage:[NSImage imageNamed:@"973-user-selected"]
                            target:self action:@selector(onSidebarChanged)];
    [self.sidebar addItemWithImage:[NSImage imageNamed:@"912-gears"]
                    alternateImage:[NSImage imageNamed:@"912-gears-selected"]
                            target:self action:@selector(onSidebarChanged)];
    self.sidebar.selectedIndex = 0;
    [self.sidebarWrapper addSubview:self.sidebar];
    [self.sidebar awakeFromNib];// Triggers setup manually...
    [self onSidebarChanged];
  }
  return self;
}

@end
