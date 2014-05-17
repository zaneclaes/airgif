//
//  AGSearchResultViewItem.m
//  AirGif
//
//  Created by Zane Claes on 5/6/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGSearchResultViewItem.h"
#import "NSImage+Manipulation.h"
#import "AGGif.h"
#import "AGAppDelegate.h"
#import "AGGifWindowController.h"
#import "AGMainWindow.h"

@interface AGSearchResultImage : NSImageView
@property (nonatomic, strong) AGGif *gif;
@end

@implementation AGSearchResultImage

- (void)setGif:(AGGif *)gif {
  _gif = gif;
  self.image = [[NSImage alloc] initWithContentsOfURL:gif.cachedThumbnailUrl];
}

- (void)mouseDown:(NSEvent *)theEvent
{
  NSInteger clickCount = [theEvent clickCount];
  if(clickCount == 1) {
    NSWindowController* mycontroller = [[AGGifWindowController alloc] initWithGif:self.gif];
    [[NSApplication sharedApplication] runModalForWindow:mycontroller.window];
  }
}

@end

@interface AGSearchResultViewItem ()
@property (nonatomic, strong) AGSearchResultImage *searchImageView;
@property (nonatomic, strong) NSImageView *iconView;
@end

@implementation AGSearchResultViewItem

- (void)loadView {
  NSRect rect = CGRectMake(0, 0, kGifThumbnailSize, kGifThumbnailSize);
  NSView *wrap = [[NSView alloc] initWithFrame:rect];
  [self setView:wrap];

  self.searchImageView = [[AGSearchResultImage alloc] initWithFrame:rect];
  //iv.animates = YES;
  [wrap addSubview:self.searchImageView];
  self.searchImageView.imageScaling = NSImageScaleProportionallyDown;
  
  self.iconView = [[NSImageView alloc] initWithFrame:NSMakeRect(0,0, 35, 35)];
  self.iconView.image = [NSImage imageNamed:@"cloud-import"];
  [wrap addSubview:self.iconView];
}

- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];
  AGGif *gif = representedObject;
  self.searchImageView.gif = representedObject;
  BOOL has = gif.purchaseDate || gif.wasImported.boolValue;
  [self.iconView setHidden:has];
}

@end
