//
//  AGGifWindowController.h
//  AirGif
//
//  Created by an Airbnb Engineer on 5/12/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AGGif;

@interface AGGifWindowController : NSWindowController

@property (nonatomic, weak) IBOutlet NSImageView *imageView;
@property (nonatomic, weak) IBOutlet NSButton *helpButton;
@property (nonatomic, weak) IBOutlet NSButton *shareButton;
@property (nonatomic, weak) IBOutlet NSButton *nsfwButton;
@property (nonatomic, weak) IBOutlet NSButton *tagButton;
@property (nonatomic, weak) IBOutlet NSButton *captionButton;
@property (nonatomic, weak) IBOutlet NSButton *saveButton;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, strong) AGGif *gif;

- (id)initWithGif:(AGGif*)gif;

- (IBAction)onPressedSave:(NSButton*)sender;
- (IBAction)onPressedCaption:(NSButton*)sender;
- (IBAction)onPressedNSFW:(NSButton*)sender;
- (IBAction)onPressedTag:(NSButton*)sender;
- (IBAction)onPressedHelp:(NSButton*)sender;
- (IBAction)onPressedShare:(NSButton*)sender;

@end
