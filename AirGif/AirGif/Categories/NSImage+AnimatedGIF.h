//
//  NSImage+AnimatedGIF.h
//  AirGif
//
//  Created by an Airbnb Engineer on 5/5/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (AnimatedGif)

@property (nonatomic, readonly) NSBitmapImageRep *gifRep;
@property (nonatomic, readonly) NSInteger numberOfFrames;
@property (nonatomic, readonly) NSInteger numberOfLoops;
@property (nonatomic, readonly) BOOL isAnimatedGif;

@end
