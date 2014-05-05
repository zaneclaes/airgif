//
//  NSImage+Hash.m
//  AirGif
//
//  Created by an Airbnb Engineer on 5/5/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "NSImage+Hash.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSImage (Hash)

+ (NSString*)hashImageData:(NSData*)imageData {
  if(!imageData.length) {
    return nil;
  }
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5([imageData bytes], (unsigned int)[imageData length], result);
  NSMutableString *imageHash = [NSMutableString new];
  for(NSInteger x=0; x<CC_MD5_DIGEST_LENGTH; x++) {
    [imageHash appendFormat:@"%02X",result[x]];
  }
  return [imageHash copy];
}

+ (NSString*)hashImagePath:(NSString*)fp {
  NSData *data = [NSData dataWithContentsOfFile:fp];
  return [self hashImageData:data];
}

@end
