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
  self.image = [[NSImage alloc] initWithContentsOfURL:gif.cachedThumbnailUrl];;
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
@end

@implementation AGSearchResultViewItem

- (void)loadView {
  NSRect rect = CGRectMake(0, 0, kGifThumbnailSize, kGifThumbnailSize);
  AGSearchResultImage *iv = [[AGSearchResultImage alloc] initWithFrame:rect];
  //iv.animates = YES;
  iv.imageScaling = NSImageScaleProportionallyDown;
  [self setView:iv];
}

- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];
  ((AGSearchResultImage*)self.view).gif = representedObject;
}

@end
