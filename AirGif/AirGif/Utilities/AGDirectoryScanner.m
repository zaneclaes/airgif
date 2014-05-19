//
//  AGDirectoryScanner.m
//  AirGif
//
//  Created by Zane Claes on 5/5/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGDirectoryScanner.h"
#import "NSImage+AnimatedGif.h"
#import "NSImage+Hash.h"
#import "HTTPRequest.h"
#import "AGGif.h"
#import "AGDataStore.h"
#import "AGAnalytics.h"
#import "AGPointManager.h"
#import "AGSettings.h"

@implementation AGDirectoryScanner {
  NSMutableDictionary *_animatedGifPaths;
}

- (NSArray*)animatedGifs {
  return [[_animatedGifPaths allValues]?:@[] copy];
}

- (void)uploadNextFile {
  if(self.filesUploaded >= _changeSet.count) {
    [_delegate directoryScannerDidFinishUploadingFiles:self withError:nil];
    [AGAnalytics trackGifAction:@"upload" label:@"end" value:@(self.filesUploaded)];
    [self.directory stopAccessingSecurityScopedResource];
    return;
  }
  [_delegate directoryScannerDidProgress:self];
  NSString *hash = _changeSet[self.filesUploaded];
  NSURL *url = _animatedGifPaths[hash];
  NSMutableDictionary *params = [AGAnalytics trackedParams];
  params[@"file"] = url;
  params[@"hash"] = hash;
  [[HTTPRequest alloc] post:URL_API(@"upload") params:params completion:^(HTTPRequest *req) {
    _filesUploaded++;
    [[AGPointManager sharedManager] earn:[AGSettings sharedSettings].pointsUploadGif reason:@"upload"];
    [self uploadNextFile];
  }];
}

- (void)upload {
  _filesUploaded = 0;
  _changeSet = nil;
  [AGAnalytics trackGifAction:@"upload" label:@"begin" value:@(_animatedGifPaths.allKeys.count)];
  if(!_animatedGifPaths.allKeys.count) {
    [_delegate directoryScannerDidFinishUploadingFiles:self withError:nil];
    return;
  }
  NSMutableDictionary *params = [AGAnalytics trackedParams];
  params[@"hashes"] = _animatedGifPaths.allKeys;
  [[HTTPRequest alloc] post:URL_API(@"upload") params:params completion:^(HTTPRequest *req) {
    if(req.error) {
      [_delegate directoryScannerDidFinishUploadingFiles:self withError:req.error];
      return;
    }
    NSArray *new_hashes = [req.response[@"new_hashes"] isKindOfClass:[NSArray class]] ? req.response[@"new_hashes"] : @[];
    NSArray *existing = [req.response[@"existing"] isKindOfClass:[NSArray class]] ? req.response[@"existing"] : @[];
    for(NSDictionary *data in existing) {
      AGGif *gif = [AGGif gifWithServerDictionary:data];
      gif.wasImported = @YES;
      // Copy the file, so we have a cached version which does not reqquire downloading...
      if(![[NSFileManager defaultManager] fileExistsAtPath:gif.cachedGifUrl.path]) {
        [[NSFileManager defaultManager] copyItemAtURL:_animatedGifPaths[gif.imageHash] toURL:gif.cachedGifUrl error:nil];
      }
      [gif cacheThumbnail:nil];
    }
    [[AGDataStore sharedStore] saveContext];
    _changeSet = [[NSOrderedSet alloc] initWithArray:new_hashes];
    DLog(@"Found %lu files; %lu are new; %lu exist in core data",_animatedGifPaths.allKeys.count,
                                                                 _changeSet.count,
                                                                 [AGGif allGifs].count);
    [self uploadNextFile];
  }];
}

- (NSError*)scan:(NSURL*)dir {
  NSError *err = nil;
  NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:dir includingPropertiesForKeys:nil  options:0 error:&err];
  for(NSURL* fp in filenames) {
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[fp path] isDirectory:&isDir];
    if(exists && isDir) {
      [self scan:fp];
    }
    else {
      NSImage *img = [[NSImage alloc] initWithContentsOfFile:[fp path]];
      if(img && img.isAnimatedGif) {
        NSString *hash = [NSImage hashImagePath:[fp path]];
        _animatedGifPaths[hash] = fp;
      }
    }
  }
  return err;
}

- (NSError*)scan {
  _animatedGifPaths = [NSMutableDictionary new];
  [self.directory startAccessingSecurityScopedResource];
  NSError *err = [self scan:self.directory];
  [self upload];
  return err;
}


- (id)initWithBookmark {
  if((self = [super init])) {
    NSData *data = [[NSUserDefaults standardUserDefaults] valueForKey:kKeyGifBookmark];
    if(!data) {
      return nil;
    }
    BOOL stale;
    NSError *err;
    _directory = [NSURL URLByResolvingBookmarkData:data
                                           options:NSURLBookmarkResolutionWithSecurityScope
                                     relativeToURL:nil
                               bookmarkDataIsStale:&stale
                                             error:&err];
    if(!self.directory) {
      return nil;
    }
    if(stale) {
      NSString *fp = [[NSUserDefaults standardUserDefaults] valueForKey:kKeyGifDirectory];
      NSURL *dir = [NSURL fileURLWithPath:fp];
      [dir startAccessingSecurityScopedResource];
      data = [dir bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope
                                  includingResourceValuesForKeys:nil
                                                   relativeToURL:nil
                                                           error:nil];
      [[NSUserDefaults standardUserDefaults] setObject:data forKey:kKeyGifBookmark];
      [[NSUserDefaults standardUserDefaults] synchronize];
      [dir stopAccessingSecurityScopedResource];
    }
  }
  return self;
}

@end
