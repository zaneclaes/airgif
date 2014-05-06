//
//  AGAppDelegate.m
//  AirGif
//
//  Created by an Airbnb Engineer on 2/19/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGAppDelegate.h"
#import "AGMainWindow.h"

@implementation AGAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  //[self.window setHidesOnDeactivate:YES];
  //[self.window orderOut:nil];
  self.window = [[AGMainWindow alloc] init];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
  return NSTerminateNow;
}


@end
