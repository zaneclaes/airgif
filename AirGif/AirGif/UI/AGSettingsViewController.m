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
#import "AGPointManager.h"
#import "AGAnalytics.h"
#import "AGTagViewController.h"
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
  [self.shareButton sendActionOn:NSLeftMouseDownMask];
  self.shortcutView.associatedUserDefaultsKey = MASPreferenceKeyShortcut;
  [self.shortcutView bind:@"enabled" toObject:self withKeyPath:@"shortcutEnabled" options:nil];
  [self updateFolderButton];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFolderButton)
                                               name:TESetupAssistantFinishedNotification object:nil];
}

- (void)viewDidAppear {
  [super viewDidAppear];
  self.pointsLabel.stringValue = [NSString stringWithFormat:NSLocalizedString(@"points.display", @""),[AGPointManager sharedManager].points];
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
  [AGAnalytics trackSetupAction:@"settings" label:@"folder" value:nil];
}

- (IBAction)onPressedHelp:(NSButton*)sender {
  OPEN_HELP(@"");
  [AGAnalytics trackSetupAction:@"game" label:@"help" value:@(0)];
}

- (void)_purchase:(NSAlert*)a code:(NSInteger)code context:(NSObject*)cxt {
  if(code == 0) {
    // Alternate button: earn
    [[NSNotificationCenter defaultCenter] postNotificationName:kTagGifNotification object:nil];
  }
  else {
    // Main button: purchase
    [[AGPointManager sharedManager] purchase];
  }
  [AGWindowUtilities activateMainWindow];
}

- (IBAction)onPressedPoints:(id)sender {
  if(![AGPointManager sharedManager].hasProducts) {
    [self _purchase:nil code:0 context:nil];
    return;
  }
  
  NSAlert* confirmAlert = [NSAlert alertWithMessageText:@"Points"
                                          defaultButton:NSLocalizedString(@"points.purchase.purchase",@"")
                                        alternateButton:NSLocalizedString(@"points.purchase.earn",@"")
                                            otherButton:nil
                              informativeTextWithFormat:NSLocalizedString(@"points.purchase.body", @"")];
  [confirmAlert beginSheetModalForWindow:nil
                           modalDelegate:self
                          didEndSelector:@selector(_purchase:code:context:)
                             contextInfo:nil];
  [AGAnalytics trackSetupAction:@"settings" label:@"points" value:nil];
}

- (IBAction)onPressedHomepage:(id)sender {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://AirGif.com"]];
  [AGAnalytics trackSetupAction:@"settings" label:@"homepage" value:nil];
}

- (IBAction)onPressedShare:(NSButton*)sender {
  NSArray *urls = @[[NSURL URLWithString:@"http://AirGif.com"]];
  NSSharingServicePicker *sharingServicePicker = [[NSSharingServicePicker alloc] initWithItems:urls];
  [sharingServicePicker showRelativeToRect:[sender bounds]
                                    ofView:sender
                             preferredEdge:NSMinYEdge];
  [AGAnalytics trackSetupAction:@"settings" label:@"share" value:nil];
}

#pragma mark - Launch controller

- (BOOL)launchAtLogin {
  return [[NSUserDefaults standardUserDefaults] boolForKey:AGLaunchAtStartupEnabled];
}

- (void)setLaunchAtLogin:(BOOL)launchAtLogin {
  Boolean res = SMLoginItemSetEnabled((__bridge CFStringRef)@"com.inzania.AirGifLauncher", launchAtLogin);
  [AGAnalytics trackSetupAction:@"launch" label:launchAtLogin ? @"enable" : @"disable" value:@(res ? 1 : 0)];
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
