//
//  main.m
//  AirGif
//
//  Created by an Airbnb Engineer on 2/19/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AGAppDelegate.h"

int main(int argc, const char * argv[])
{
  //return NSApplicationMain(argc, argv);
  
  @autoreleasepool {
    [NSApplication sharedApplication];
    
    AGAppDelegate *appDelegate = [[AGAppDelegate alloc] init];
    [NSApp setDelegate:appDelegate];
    [NSApp run];
    
  }
  return 0;
}
