//
//  AGWindowUtilities.m
//  AirGif
//
//  Created by an Airbnb Engineer on 5/15/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGWindowUtilities.h"
#import "AGAppDelegate.h"
#import "AGMainWindow.h"

@implementation AGWindowUtilities

+ (NSWindow*)mainWindow {
  AGAppDelegate *app = ((AGAppDelegate*)[NSApplication sharedApplication].delegate);
  return app.window;
}

+ (void)activateMainWindow {
  [NSApp stopModal];
  AGAppDelegate *app = ((AGAppDelegate*)[NSApplication sharedApplication].delegate);
  [NSApp activateIgnoringOtherApps:YES];
  [app.window setCollectionBehavior: NSWindowCollectionBehaviorCanJoinAllSpaces];
  [app.window makeKeyAndOrderFront:nil];
}

@end
