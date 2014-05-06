//
//  NSImage+Manipulation.h
//  AirGif
//
//  Created by an Airbnb Engineer on 5/6/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Manipulation)

- (NSImage*)resize:(NSSize)size;
- (NSImage*)scale:(CGFloat)scale;

@end
