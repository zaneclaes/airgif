//
//  AGGifWindowController.h
//  AirGif
//
//  Created by an Airbnb Engineer on 5/12/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AGGif;
@class AGDraggableImageView;

@interface AGGifWindowController : NSWindowController

@property (nonatomic, strong) IBOutlet AGDraggableImageView *imageView;
@property (nonatomic, strong) IBOutlet NSImageView *iconView;
@property (nonatomic, strong) IBOutlet NSButton *helpButton;
@property (nonatomic, strong) IBOutlet NSButton *shareButton;
@property (nonatomic, strong) IBOutlet NSButton *nsfwButton;
@property (nonatomic, strong) IBOutlet NSButton *openButton;
@property (nonatomic, strong) IBOutlet NSButton *tagButton;
@property (nonatomic, strong) IBOutlet NSButton *captionButton;
@property (nonatomic, strong) IBOutlet NSButton *saveButton;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, strong) AGGif *gif;

- (id)initWithGif:(AGGif*)gif;

- (IBAction)onPressedSave:(NSButton*)sender;
- (IBAction)onPressedCaption:(NSButton*)sender;
- (IBAction)onPressedOpen:(NSButton*)sender;
- (IBAction)onPressedNSFW:(NSButton*)sender;
- (IBAction)onPressedTag:(NSButton*)sender;
- (IBAction)onPressedHelp:(NSButton*)sender;
- (IBAction)onPressedShare:(NSButton*)sender;

@end
