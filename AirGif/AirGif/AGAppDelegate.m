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
#import "AGSetupAssistant.h"
#import "TESetupAssistant.h"
#import "AGSettings.h"
#import "AGGif.h"

@implementation AGAppDelegate {
  __weak id _constantShortcutMonitor;
}

- (void)checkSetup:(NSNotification*)n {
  if(![AGGif recentGifs:1].count && !n) {
    [self.window orderOut:nil];
    [self.setupAssistant run];
  }
  else if(n && self.setupAssistant.directory.length) {
    AGDirectoryScanner *scanner = [[AGDirectoryScanner alloc] initWithDirectory:self.setupAssistant.directory];
    [scanner upload];
  }
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  [self.window setHidesOnDeactivate:YES];
  self.setupAssistant = [[AGSetupAssistant alloc] init];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkSetup:)
                                               name:TESetupAssistantFinishedNotification object:nil];
  [self checkSetup:nil];
  [AGSettings sharedSettings];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
  [[AGAnalytics tracker] sendShutdown:@"shutdown" callback:^(NSError *err) {
    [sender replyToApplicationShouldTerminate:YES];
  }];
  return NSTerminateLater;
}

@end
