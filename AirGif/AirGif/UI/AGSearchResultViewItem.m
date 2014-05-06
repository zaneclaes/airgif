//
//  AGSearchResultViewItem.m
//  AirGif
//
//  Created by an Airbnb Engineer on 5/6/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGSearchResultViewItem.h"

@interface AGSearchResultViewItem ()

@end

@implementation AGSearchResultViewItem

- (void)loadView {
  CGSize size = [[self class] idealSize];
  NSImageView *iv = [[NSImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
  //iv.animates = YES;
  [self setView:iv];
}

- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];
  ((NSImageView*)self.view).image = [[NSImage alloc] initWithContentsOfURL:representedObject];
}

+ (CGSize)idealSize {
  return CGSizeMake(150, 150);
}

@end
