//
//  AGMainWindow.h
//  AirGif
//
//  Created by Zane Claes on 5/6/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "OBMenuBarWindow.h"

@class AGContentViewController;

@interface AGMainWindow : OBMenuBarWindow

@property (nonatomic, readonly) AGContentViewController *currentViewController;

@end
