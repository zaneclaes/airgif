//
//  AGAppDelegate.m
//  AirGifLauncher
//
//  Created by Zane Claes on 5/17/14.
//  Copyright (c) 2014 inZania LLC. All rights reserved.
//

#import "AGAppDelegate.h"

@implementation AGAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  // Check if main app is already running; if yes, do nothing and terminate helper app
  BOOL alreadyRunning = NO;
  NSArray *running = [[NSWorkspace sharedWorkspace] runningApplications];
  for (NSRunningApplication *app in running) {
    if ([[app bundleIdentifier] isEqualToString:@"com.inzania.AirGif"]) {
      alreadyRunning = YES;
    }
  }
  
  if (!alreadyRunning) {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSArray *p = [path pathComponents];
    NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:p];
    [pathComponents removeLastObject];
    [pathComponents removeLastObject];
    [pathComponents removeLastObject];
    [pathComponents addObject:@"MacOS"];
    [pathComponents addObject:@"LaunchAtLoginApp"];
    NSString *newPath = [NSString pathWithComponents:pathComponents];
    [[NSWorkspace sharedWorkspace] launchApplication:newPath];
  }
  [NSApp terminate:nil];
}

@end
