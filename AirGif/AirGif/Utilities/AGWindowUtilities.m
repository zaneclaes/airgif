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

+ (void)activateMainWindow {
  AGAppDelegate *app = ((AGAppDelegate*)[NSApplication sharedApplication].delegate);
  [NSApp activateIgnoringOtherApps:YES];
  [app.window setCollectionBehavior: NSWindowCollectionBehaviorCanJoinAllSpaces];
  [app.window orderFront:nil];
}

@end
