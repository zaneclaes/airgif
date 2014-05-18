//
//  AGWindowUtilities.h
//  AirGif
//
//  Created by an Airbnb Engineer on 5/15/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGMainWindow.h"

@interface AGWindowUtilities : NSObject

+ (AGMainWindow*)mainWindow;
+ (void)activateMainWindow;

@end
