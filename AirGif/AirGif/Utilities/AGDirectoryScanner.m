//
//  AGDirectoryScanner.m
//  AirGif
//
//  Created by an Airbnb Engineer on 5/5/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGDirectoryScanner.h"
#import "NSImage+AnimatedGif.h"

@implementation AGDirectoryScanner {
  NSMutableArray *_animatedGifPaths;
}

- (NSArray*)animatedGifUrls {
  return [_animatedGifPaths?:@[] copy];
}

- (NSError*)scan:(NSString*)dir {
  NSError *err = nil;
  NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:&err];
  for(NSString* fn in filenames) {
    NSString *fp = [dir stringByAppendingPathComponent:fn];
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:fp isDirectory:&isDir];
    if(exists && isDir) {
      [self scan:fp];
    }
    else {
      NSImage *img = [[NSImage alloc] initWithContentsOfFile:fp];
      if(img && img.isAnimatedGif) {
        [_animatedGifPaths addObject:[NSURL fileURLWithPath:fp]];
      }
    }
  }
  return err;
}

- (NSError*)scan {
  _animatedGifPaths = [NSMutableArray new];
  return [self scan:self.directory];
}

- (id)initWithDirectory:(NSString*)dir {
  if((self = [super init])) {
    _directory = dir;
  }
  return self;
}

@end
