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
#import "AGContentViewController.h"

@implementation AGWindowUtilities

+ (AGMainWindow*)mainWindow {
  AGAppDelegate *app = ((AGAppDelegate*)[NSApplication sharedApplication].delegate);
  return app.window;
}

+ (void)activateMainWindow {
  AGAppDelegate *app = ((AGAppDelegate*)[NSApplication sharedApplication].delegate);
  [app.window.currentViewController viewWillAppear];
  [NSApp stopModal];
  [NSApp activateIgnoringOtherApps:YES];
  [app.window setCollectionBehavior: NSWindowCollectionBehaviorCanJoinAllSpaces];
  [app.window makeKeyAndOrderFront:nil];
  [app.window.currentViewController viewDidAppear];
}

@end
