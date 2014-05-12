//
//  AGTagViewController.h
//  AirGif
//
//  Created by Zane Claes on 5/6/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGContentViewController.h"
#import <WebKit/WebKit.h>

@interface AGTagViewController : AGContentViewController <NSTokenFieldDelegate>

@property (nonatomic, weak) IBOutlet NSTextField *headerLabel;
@property (nonatomic, weak) IBOutlet WebView *webView;
@property (nonatomic, weak) IBOutlet NSTokenField *tagsField;
@property (nonatomic, weak) IBOutlet NSButton *nextButton;
@property (nonatomic, weak) IBOutlet NSButton *shareButton;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressBar;

- (IBAction)onPressedNext:(NSButton*)sender;
- (IBAction)onPressedNSFW:(NSButton*)sender;
- (IBAction)onPressedHelp:(NSButton*)sender;
- (IBAction)onPressedShare:(NSButton*)sender;

@end
