//
//  AGAppDelegate.h
//  AirGif
//
//  Created by an Airbnb Engineer on 2/19/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AGMainWindow;

@interface AGAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) AGMainWindow *window;

@end
