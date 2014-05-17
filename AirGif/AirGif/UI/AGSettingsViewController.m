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
#import "AGDirectoryScanner.h"
#import "AGSetupAssistant.h"
#import "TESetupAssistant.h"
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
  [self updateFolderButton];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFolderButton)
                                               name:TESetupAssistantFinishedNotification object:nil];
}

- (void)dealloc {
  [self.shortcutView unbind:@"enabled"];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateFolderButton {
  NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyGifDirectory];
  [self.folderButton setTitle:path.length ? path : NSLocalizedString(@"setup.directory", @"")];
  [AGWindowUtilities activateMainWindow];
}

- (IBAction)onPressedFolderButton:(id)sender {
  AGSetupAssistant *setupAssistant = [[AGSetupAssistant alloc] init];
  [setupAssistant run];
}

#pragma mark - Launch controller

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
