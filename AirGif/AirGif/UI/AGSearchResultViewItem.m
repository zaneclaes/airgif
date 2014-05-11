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

@interface AGSearchResultViewItem ()

@end

@implementation AGSearchResultViewItem

- (void)loadView {
  NSImageView *iv = [[NSImageView alloc] initWithFrame:CGRectMake(0, 0, kGifThumbnailSize, kGifThumbnailSize)];
  //iv.animates = YES;
  iv.imageScaling = NSImageScaleProportionallyDown;
  [self setView:iv];
}

- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];
  AGGif *gif = representedObject;
  ((NSImageView*)self.view).image = [[NSImage alloc] initWithContentsOfURL:gif.cachedThumbnailUrl];;
}

@end
