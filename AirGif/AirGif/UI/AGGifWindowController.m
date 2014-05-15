//
//  AGGifWindowController.m
//  AirGif
//
//  Created by an Airbnb Engineer on 5/12/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGGifWindowController.h"
#import "AGWindowUtilities.h"
#import "AGGif.h"

@interface AGGifWindowController ()

@end

@implementation AGGifWindowController

- (id)initWithWindow:(NSWindow *)window {
  if ((self = [super initWithWindow:window])) {
    self.windowFrameAutosaveName = @"GifPreview";
  }
  return self;
}
- (void)windowWillClose:(NSNotification *)notification {
  [NSApp stopModal];
  [AGWindowUtilities activateMainWindow];
}

- (void)windowDidLoad {
  [super windowDidLoad];
  self.window.title = [self.gif.tagNames componentsJoinedByString:@", "];
}

- (id)initWithGif:(AGGif*)gif {
  if((self = [super initWithWindowNibName:@"AGGifWindowController"])) {
    self.gif = gif;
  }
  return self;
}

@end
