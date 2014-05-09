//
//  AGDirectoryScanner.m
//  AirGif
//
//  Created by an Airbnb Engineer on 5/5/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGDirectoryScanner.h"
#import "NSImage+AnimatedGif.h"
#import "NSImage+Hash.h"
#import "HTTPRequest.h"
#import "AGGif.h"
#import "AGDataStore.h"

@implementation AGDirectoryScanner {
  NSMutableDictionary *_animatedGifPaths;
}

- (NSArray*)animatedGifs {
  return [[_animatedGifPaths allValues]?:@[] copy];
}

- (void)uploadNextFile {
  if(self.filesUploaded >= _changeSet.count) {
    [_delegate directoryScannerDidFinishUploadingFiles:self withError:nil];
    return;
  }
  [_delegate directoryScannerDidProgress:self];
  NSString *hash = _changeSet[self.filesUploaded];
  NSURL *url = _animatedGifPaths[hash];
  NSDictionary *params = @{@"file":url,@"hash":hash};
  [[HTTPRequest alloc] post:URL_API(@"upload") params:params completion:^(HTTPRequest *req) {
    _filesUploaded++;
    [self uploadNextFile];
  }];
}

- (void)upload {
  _filesUploaded = 0;
  _changeSet = nil;
  if(!_animatedGifPaths.allKeys.count) {
    [_delegate directoryScannerDidFinishUploadingFiles:self withError:nil];
    return;
  }
  NSDictionary *params = @{@"hashes":_animatedGifPaths.allKeys};
  [[HTTPRequest alloc] post:URL_API(@"upload") params:params completion:^(HTTPRequest *req) {
    if(req.error) {
      [_delegate directoryScannerDidFinishUploadingFiles:self withError:req.error];
      return;
    }
    NSArray *new_hashes = [req.response[@"new_hashes"] isKindOfClass:[NSArray class]] ? req.response[@"new_hashes"] : @[];
    NSArray *existing = [req.response[@"existing"] isKindOfClass:[NSArray class]] ? req.response[@"existing"] : @[];
    for(NSDictionary *data in existing) {
      AGGif *gif = [AGGif gifWithServerDictionary:data];
      // Copy the file, so we have a cached version which does not reqquire downloading...
      if(![[NSFileManager defaultManager] fileExistsAtPath:gif.cachedGifUrl.path]) {
        [[NSFileManager defaultManager] copyItemAtURL:_animatedGifPaths[gif.imageHash] toURL:gif.cachedGifUrl error:nil];
      }
      [gif cacheThumbnail:nil];
    }
    [[AGDataStore sharedStore] saveContext];
    _changeSet = [[NSOrderedSet alloc] initWithArray:new_hashes];
    DLog(@"Found %lu files; %lu are new; %lu exist in core data",_animatedGifPaths.allKeys.count,_changeSet.count,[AGGif allGifs].count);
    [self uploadNextFile];
  }];
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
        NSString *hash = [NSImage hashImagePath:fp];
        _animatedGifPaths[hash] = [NSURL fileURLWithPath:fp];
      }
    }
  }
  return err;
}

- (NSError*)scan {
  _animatedGifPaths = [NSMutableDictionary new];
  return [self scan:self.directory];
}

- (id)initWithDirectory:(NSString*)dir {
  if((self = [super init])) {
    _directory = dir;
    [self scan];
  }
  return self;
}

@end
