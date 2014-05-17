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
#import "AGWindowUtilities.h"
#import <ServiceManagement/ServiceManagement.h>

NSString *const MASPreferenceKeyShortcut = @"AGShortcut";
NSString *const MASPreferenceKeyShortcutEnabled = @"AGShortcutEnabled";
NSString *const AGLaunchAtStartupEnabled = @"AGLaunchAtStartupEnabled";

@interface AGSettingsViewController ()
@end

@implementation AGSettingsViewController

#pragma mark -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    [self resetShortcutRegistration];
  }
  return self;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  self.shortcutView.associatedUserDefaultsKey = MASPreferenceKeyShortcut;
  [self.shortcutView bind:@"enabled" toObject:self withKeyPath:@"shortcutEnabled" options:nil];
}

- (void)dealloc {
  [self.shortcutView unbind:@"enabled"];
}

#pragma mark - Launch conttroller

- (BOOL)launchAtLogin {
  return [[NSUserDefaults standardUserDefaults] boolForKey:AGLaunchAtStartupEnabled];
}

- (void)setLaunchAtLogin:(BOOL)launchAtLogin {
  Boolean res = SMLoginItemSetEnabled((__bridge CFStringRef)@"com.inzania.AirGifLauncher", launchAtLogin);
  launchAtLogin = launchAtLogin && res;
  [[NSUserDefaults standardUserDefaults] setBool:launchAtLogin forKey:AGLaunchAtStartupEnabled];
  [[NSUserDefaults standardUserDefaults] synchronize];
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
      [AGWindowUtilities activateMainWindow];
    }];
  }
  else {
    [MASShortcut unregisterGlobalShortcutWithUserDefaultsKey:MASPreferenceKeyShortcut];
  }
}

@end
