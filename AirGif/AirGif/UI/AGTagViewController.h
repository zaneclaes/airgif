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

@property (nonatomic, strong) IBOutlet NSTextField *headerLabel;
@property (nonatomic, strong) IBOutlet WebView *webView;
@property (nonatomic, strong) IBOutlet NSTokenField *tagsField;
@property (nonatomic, strong) IBOutlet NSButton *nextButton;
@property (nonatomic, strong) IBOutlet NSButton *shareButton;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *progressBar;

- (IBAction)onPressedNext:(NSButton*)sender;
- (IBAction)onPressedNSFW:(NSButton*)sender;
- (IBAction)onPressedHelp:(NSButton*)sender;
- (IBAction)onPressedShare:(NSButton*)sender;

@end
