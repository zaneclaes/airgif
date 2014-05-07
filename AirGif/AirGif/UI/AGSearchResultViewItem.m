//
//  AGSearchResultViewItem.m
//  AirGif
//
//  Created by an Airbnb Engineer on 5/6/14.
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
  iv.imageScaling = NSImageScaleNone;
  [self setView:iv];
}

- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];
  NSImage *image = [[NSImage alloc] initWithContentsOfURL:representedObject];
  /*CGFloat scaleX = image.size.width / idealSize.width;
  CGFloat scaleY = image.size.height / idealSize.height;
  CGFloat scale = MAX(scaleX, scaleY);
  if(scale != 1) {
    image = [image scale:scale];
  }*/
  ((NSImageView*)self.view).image = image;
}

@end
