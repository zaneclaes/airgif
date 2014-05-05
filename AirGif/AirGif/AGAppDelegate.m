//
//  AGAppDelegate.m
//  AirGif
//
//  Created by an Airbnb Engineer on 2/19/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGAppDelegate.h"
#import "AGDirectoryScanner.h"

@implementation AGAppDelegate

@synthesize panelController = _panelController;
@synthesize menubarController = _menubarController;

#pragma mark -

- (void)dealloc
{
  [_panelController removeObserver:self forKeyPath:@"hasActivePanel"];
}

#pragma mark -

void *kContextActivePanel = &kContextActivePanel;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if (context == kContextActivePanel) {
    self.menubarController.hasActiveIcon = self.panelController.hasActivePanel;
  }
  else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
  // Install icon into the menu bar
  self.menubarController = [[MenubarController alloc] init];
  [self.window setHidesOnDeactivate:YES];
  [self.window orderOut:nil];

  AGDirectoryScanner *scanner = [[AGDirectoryScanner alloc] initWithDirectory:@"/Users/zane/Dropbox/Gifs/"];
  NSError *err = [scanner scan];
  DLog(@"Scan[%@]: %@",err,scanner.animatedGifUrls);
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
  // Explicitly remove the icon from the menu bar
  self.menubarController = nil;
  return NSTerminateNow;
}

#pragma mark - Actions

- (IBAction)togglePanel:(id)sender
{
  self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
  self.panelController.hasActivePanel = self.menubarController.hasActiveIcon;
}

#pragma mark - Public accessors

- (PanelController *)panelController
{
  if (_panelController == nil) {
    _panelController = [[PanelController alloc] initWithDelegate:self];
    [_panelController addObserver:self forKeyPath:@"hasActivePanel" options:0 context:kContextActivePanel];
  }
  return _panelController;
}

#pragma mark - PanelControllerDelegate

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller
{
  return self.menubarController.statusItemView;
}

@end
