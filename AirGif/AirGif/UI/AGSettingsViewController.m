//
//  AGAccountViewController.m
//  AirGif
//
//  Created by Zane Claes on 5/6/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGSettingsViewController.h"
#import "MASShortcutView.h"
#import "AGSettings.h"
#import "MASShortcut.h"
#import "MASShortcutView+UserDefaults.h"
#import "MASShortcut+UserDefaults.h"
#import "MASShortcut+Monitoring.h"
#import "AGAppDelegate.h"
#import "AGMainWindow.h"

NSString *const MASPreferenceKeyShortcut = @"MASDemoShortcut";
NSString *const MASPreferenceKeyShortcutEnabled = @"MASDemoShortcutEnabled";

@interface AGSettingsViewController ()

@end

@implementation AGSettingsViewController

#pragma mark -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.shortcutView.associatedUserDefaultsKey = MASPreferenceKeyShortcut;
    [self resetShortcutRegistration];
  }
  return self;
}

- (void)awakeFromNib {
  [super awakeFromNib];

  // Checkbox will enable and disable the shortcut view
  [self.shortcutView bind:@"enabled" toObject:self withKeyPath:@"shortcutEnabled" options:nil];
}

- (void)dealloc {
  // Cleanup
  [self.shortcutView unbind:@"enabled"];
}
#pragma mark - Custom shortcut

- (BOOL)isShortcutEnabled
{
  return [[NSUserDefaults standardUserDefaults] boolForKey:MASPreferenceKeyShortcutEnabled];
}

- (void)setShortcutEnabled:(BOOL)enabled
{
  if (self.shortcutEnabled != enabled) {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:MASPreferenceKeyShortcutEnabled];
    [self resetShortcutRegistration];
    [AGAnalytics trackSetupAction:@"shortcut" label:enabled ? @"enable" : @"disable" value:nil];
  }
}

- (void)resetShortcutRegistration
{
  if (self.shortcutEnabled) {
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:MASPreferenceKeyShortcut handler:^{
      AGAppDelegate *app = [NSApplication sharedApplication].delegate;
      [NSApp activateIgnoringOtherApps:YES];
      [app.window setCollectionBehavior: NSWindowCollectionBehaviorCanJoinAllSpaces];
      [app.window orderFront:nil];
    }];
  }
  else {
    [MASShortcut unregisterGlobalShortcutWithUserDefaultsKey:MASPreferenceKeyShortcut];
  }
}

@end
