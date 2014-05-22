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

@property (nonatomic, strong) IBOutlet MASShortcutView *shortcutView;
@property (nonatomic, strong) IBOutlet NSButton *folderButton;
@property (nonatomic, strong) IBOutlet NSButton *pointsButton;
@property (nonatomic, strong) IBOutlet NSButton *homepageButton;
@property (nonatomic, strong) IBOutlet NSButton *shareButton;
@property (nonatomic, strong) IBOutlet NSTextField *pointsLabel;
@property (nonatomic, strong) IBOutlet NSTextField *uploadingLabel;
@property (nonatomic, getter = isShortcutEnabled) BOOL shortcutEnabled;
@property (nonatomic, readwrite) BOOL launchAtLogin;

- (IBAction)onPressedFolderButton:(id)sender;
- (IBAction)onPressedPoints:(id)sender;
- (IBAction)onPressedHomepage:(id)sender;
- (IBAction)onPressedShare:(NSButton*)sender;
- (IBAction)onPressedHelp:(NSButton*)sender;
- (IBAction)onPressedImport:(NSButton*)sender;

@end
