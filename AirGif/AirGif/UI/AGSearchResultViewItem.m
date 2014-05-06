//
//  AGSearchResultViewItem.m
//  AirGif
//
//  Created by an Airbnb Engineer on 5/6/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGSearchResultViewItem.h"
#import "NSImage+Manipulation.h"

@interface AGSearchResultViewItem ()

@end

@implementation AGSearchResultViewItem

- (void)loadView {
  CGSize size = [[self class] idealSize];
  NSImageView *iv = [[NSImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
  //iv.animates = YES;
  iv.imageScaling = NSImageScaleNone;
  [self setView:iv];
}

- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];
  CGSize idealSize = [[self class] idealSize];
  NSImage *image = [[NSImage alloc] initWithContentsOfURL:representedObject];
  CGFloat scaleX = image.size.width / idealSize.width;
  CGFloat scaleY = image.size.height / idealSize.height;
  CGFloat scale = MAX(scaleX, scaleY);
  if(scale != 1) {
    image = [image scale:scale];
  }
  ((NSImageView*)self.view).image = image;
}

+ (CGSize)idealSize {
  return CGSizeMake(150, 150);
}

@end
