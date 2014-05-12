//
//  AGAppDelegate.h
//  AirGif
//
//  Created by Zane Claes on 2/19/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AGMainWindow;
@class AGSetupAssistant;

@interface AGAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) IBOutlet AGMainWindow *window;
@property (nonatomic, strong) AGSetupAssistant *setupAssistant;

@end
