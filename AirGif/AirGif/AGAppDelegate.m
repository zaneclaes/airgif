//
//  AGAppDelegate.m
//  AirGif
//
//  Created by Zane Claes on 2/19/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGAppDelegate.h"
#import "AGMainWindow.h"
#import "AGDirectoryScanner.h"

@implementation AGAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  //[self.window setHidesOnDeactivate:YES];
  //[self.window orderOut:nil];
  [[[AGDirectoryScanner alloc] initWithDirectory:@"/Users/zane/Dropbox/Gifs/"] upload];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
  return NSTerminateNow;
}


@end
