//
//  AGGifWindowController.m
//  AirGif
//
//  Created by an Airbnb Engineer on 5/12/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGGifWindowController.h"
#import "AGWindowUtilities.h"
#import "AGDraggableImageView.h"
#import "AGTagViewController.h"
#import "AGPointManager.h"
#import "AGSettings.h"
#import "AGGif.h"
#import "AGDataStore.h"

@interface AGGifWindowController () <NSSharingServicePickerDelegate>

@end

@implementation AGGifWindowController


/*************************************************************************************************
 * Buttons
 ************************************************************************************************/
- (IBAction)onPressedSave:(NSButton*)sender {
  [self.imageView save];
  [AGAnalytics trackGifAction:@"window" label:@"save" value:nil];
}

- (IBAction)onPressedCaption:(NSButton*)sender {
  [AGAnalytics trackGifAction:@"window" label:@"caption" value:nil];
}

- (IBAction)onPressedNSFW:(NSButton*)sender {
  [self.progressIndicator startAnimation:nil];
  [self.imageView setHidden:YES];
  __weak typeof(self) wself = self;
  [self.gif flagNSFW:self.window completion:^(HTTPRequest *req) {
    [self.progressIndicator stopAnimation:nil];
    [wself close];
  }];
  [AGAnalytics trackGifAction:@"window" label:@"flag" value:@(1)];
}

- (IBAction)onPressedTag:(NSButton*)sender {
  [[NSNotificationCenter defaultCenter] postNotificationName:kTagGifNotification object:self.gif userInfo:nil];
  [self close];
  [AGAnalytics trackGifAction:@"window" label:@"tag" value:nil];
}

- (IBAction)onPressedHelp:(NSButton*)sender {
  OPEN_HELP(@"/gif");
  [AGAnalytics trackGifAction:@"window" label:@"help" value:nil];
}

- (IBAction)onPressedShare:(NSButton*)sender {
  NSArray *urls = @[[NSURL URLWithString:URL_SHARE_GIF(self.gif)]];
  NSSharingServicePicker *sharingServicePicker = [[NSSharingServicePicker alloc] initWithItems:urls];
  sharingServicePicker.delegate = self;

  [sharingServicePicker showRelativeToRect:[sender bounds]
                                    ofView:sender
                             preferredEdge:NSMinYEdge];
  [AGAnalytics trackGifAction:@"window" label:@"share" value:nil];
}
/*************************************************************************************************
 * Lifecycle
 ************************************************************************************************/

- (id)initWithWindow:(NSWindow *)window {
  if ((self = [super initWithWindow:window])) {
    self.windowFrameAutosaveName = @"GifPreview";
  }
  return self;
}

- (void)windowWillClose:(NSNotification *)notification {
  [AGWindowUtilities activateMainWindow];
}

static NSInteger const kPadding = 2;

- (CGFloat)repositionButtons {
  NSArray *buttons = @[self.helpButton, self.shareButton, self.nsfwButton, self.tagButton, self.captionButton, self.saveButton];
  NSInteger minWidth = kPadding;
  for(NSButton *button in buttons) {
    if(button.isHidden) {
      continue;
    }

    button.frame = NSMakeRect(minWidth, (32 - button.frame.size.height) / 2,
                              button.frame.size.width, button.frame.size.height);
    minWidth += button.frame.size.width + kPadding;
  }
  return minWidth;
}

- (void)reloadIcon {
  [self.iconView setHidden:self.gif.purchaseDate || self.gif.wasImported.boolValue];
}

- (void)windowDidLoad {
  [super windowDidLoad];
  [self.shareButton sendActionOn:NSLeftMouseDownMask];
  self.window.title = [self.gif.tagNames componentsJoinedByString:@", "];

  [self.progressIndicator startAnimation:nil];
  [self.gif cache:^(BOOL success) {
    [self.progressIndicator stopAnimation:nil];
    if(!success) {
      [self close];
      return;
    }
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:self.gif.cachedGifUrl];
    CGSize size = CGSizeMake(MAX(image.size.width, [self repositionButtons]), image.size.height);
    NSRect frame = self.window.frame;
    NSInteger bottomHeight = 32 + kPadding;
    frame.size = CGSizeMake(size.width, size.height + bottomHeight + 20);
    [self.window setFrame:frame display:YES];
    self.imageView.gif = self.gif;
    self.imageView.image = image;
    self.imageView.frame = NSMakeRect(0, bottomHeight, image.size.width, image.size.height);
    [self repositionButtons];
  }];
  [self reloadIcon];
  [AGAnalytics view:@"gif"];
}

- (id)initWithGif:(AGGif*)gif {
  if((self = [super initWithWindowNibName:@"AGGifWindowController"])) {
    self.gif = gif;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadIcon)
                                                 name:kGifPurchasedNotification object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
