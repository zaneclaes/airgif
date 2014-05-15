//
//  AGAccountViewController.h
//  AirGif
//
//  Created by Zane Claes on 5/6/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGContentViewController.h"

@class MASShortcutView;

@interface AGSettingsViewController : AGContentViewController

@property (nonatomic, weak) IBOutlet MASShortcutView *shortcutView;
@property (nonatomic, getter = isShortcutEnabled) BOOL shortcutEnabled;

@end
