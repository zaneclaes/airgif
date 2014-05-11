//
//  NSImage+Manipulation.m
//  AirGif
//
//  Created by Zane Claes on 5/6/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "NSImage+Manipulation.h"

@implementation NSImage (Manipulation)

- (NSImage*)resize:(NSSize)size {
  NSImage *sourceImage = self;
  NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);
  NSImage*  targetImage = [[NSImage alloc] initWithSize:size];

  NSSize sourceSize = [sourceImage size];
  NSRect cropRect = NSZeroRect;
  cropRect.size = size;
  cropRect.origin.x = floor( (sourceSize.width - cropRect.size.width)/2 );
  cropRect.origin.y = floor( (sourceSize.height - cropRect.size.height)/2 );

  [targetImage lockFocus];
  [sourceImage drawInRect:targetFrame
                 fromRect:cropRect       //portion of source image to draw
                operation:NSCompositeCopy  //compositing operation
                 fraction:1.0              //alpha (transparency) value
           respectFlipped:YES              //coordinate system
                    hints:@{NSImageHintInterpolation:
                              [NSNumber numberWithInt:NSImageInterpolationLow]}];
  
  [targetImage unlockFocus];
  
  return targetImage;
}

- (NSImage*)scale:(CGFloat)scale {
  return [self resize:NSMakeSize(self.size.width * scale, self.size.height * scale)];
}

@end
