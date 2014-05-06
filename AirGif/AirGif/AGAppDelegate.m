//
//  AGAppDelegate.m
//  AirGif
//
//  Created by an Airbnb Engineer on 2/19/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGAppDelegate.h"
#import "OBMenuBarWindow.h"

@implementation AGAppDelegate

#pragma mark -

- (void)dealloc
{
}

#pragma mark -

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
  //[self.window setHidesOnDeactivate:YES];
  //[self.window orderOut:nil];
  NSRect frame = NSMakeRect(0, 0, 200, 200);
  OBMenuBarWindow* window  = [[OBMenuBarWindow alloc] initWithContentRect:frame
                                                   styleMask:NSBorderlessWindowMask
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
  window.hasMenuBarIcon = YES;
  window.menuBarIcon = [NSImage imageNamed:@"Status"];
  window.highlightedMenuBarIcon = [NSImage imageNamed:@"StatusHighlighted"];
  window.attachedToMenuBar = YES;
  window.isDetachable = NO;
  //[window setBackgroundColor:[NSColor blueColor]];
  //[window makeKeyAndOrderFront:NSApp];
  self.menuBarWindow = window;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
  return NSTerminateNow;
}


@end
