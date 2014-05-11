//
//  NSImage+Hash.h
//  AirGif
//
//  Created by Zane Claes on 5/5/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Hash)

+ (NSString*)hashImageData:(NSData*)imageData;
+ (NSString*)hashImagePath:(NSString*)fp;

@end
