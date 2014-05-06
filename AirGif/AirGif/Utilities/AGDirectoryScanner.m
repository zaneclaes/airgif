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
    NSArray *arr = [req.response[@"hashes"] isKindOfClass:[NSArray class]] ? req.response[@"hashes"] : @[];
    _changeSet = [[NSOrderedSet alloc] initWithArray:arr];
    DLog(@"Found %lu files; %lu are new",_animatedGifPaths.allKeys.count,_changeSet.count);
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
