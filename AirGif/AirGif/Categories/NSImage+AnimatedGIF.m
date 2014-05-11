//
//  NSImage+AnimatedGIF.m
//  AirGif
//
//  Created by Zane Claes on 5/5/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "NSImage+AnimatedGIF.h"

@implementation NSImage (AnimatedGif)

- (NSBitmapImageRep*)gifRep {
  return self.representations.count ? self.representations[0] : nil;
}

- (NSInteger)numberOfFrames {
  return [[self.gifRep valueForProperty: NSImageFrameCount] integerValue];
}

- (NSInteger)numberOfLoops {
  return [[self.gifRep valueForProperty: NSImageLoopCount] integerValue];
}

- (BOOL)isAnimatedGif {
  return self.numberOfFrames > 0;
}

@end
