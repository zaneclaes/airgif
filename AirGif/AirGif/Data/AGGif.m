//
//  AGGif.m
//  AirGif
//
//  Created by Zane Claes on 5/7/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGGif.h"
#import "AGDataStore.h"
#import "HTTPRequest.h"

static NSOperationQueue * _requests = nil;

@implementation AGGif

@dynamic imageHash, name, type, uploadedAt, size, views, downloads, flags;

/*******************************************************************************
 * Caching
 ******************************************************************************/

- (BOOL)_cacheImage:(NSURL*)urlFrom to:(NSURL*)urlTo {
  if([[NSFileManager defaultManager] fileExistsAtPath:urlTo.path]) {
    return YES;
  }
  for(NSInteger tries=0; tries<1; tries++) {
    NSData *data = [NSData dataWithContentsOfURL:urlFrom];
    [data writeToURL:urlTo atomically:YES];
    NSImage *test = [[NSImage alloc] initWithContentsOfURL:urlTo];
    if(test) {
      return YES;
    }
    else {
      DLog(@"Failed to cache from %@ to %@; downloaded %lu bytes => %@",urlFrom,urlTo,data.length,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }
  }
  [[NSFileManager defaultManager] removeItemAtURL:urlTo error:nil];
  return NO;
}

- (void)_cache:(void (^)(BOOL))block {
  NSInteger thumbSize = kGifThumbnailSize * 2;//[[NSScreen mainScreen] backingScaleFactor];
  BOOL cachedThumbnail = [self _cacheImage:[NSURL URLWithString:URL_THUMBNAIL(self.imageHash, thumbSize)] to:self.cachedThumbnailUrl];
  BOOL cachedGif = [self _cacheImage:[NSURL URLWithString:URL_GIF(self.imageHash)] to:self.cachedGifUrl];
  if(block) {
    dispatch_async(dispatch_get_main_queue(), ^{
      block(cachedThumbnail && cachedGif);
    });
  }
}

- (void)cache:(void (^)(BOOL))block {
  if(self.isCached) {
    if(block) {
      block(YES);
    }
    return;
  }

  static dispatch_once_t onceToken = 0;
  dispatch_once(&onceToken, ^{
    _requests = [[NSOperationQueue alloc] init];
    [_requests setMaxConcurrentOperationCount:2];// Don't overload the PHP script.
  });
  __weak typeof(self) wself = self;
  [_requests addOperationWithBlock:^{
    [wself _cache:block];
  }];
}

- (BOOL)isCached {
  return [[NSFileManager defaultManager] fileExistsAtPath:self.cachedGifUrl.path] &&
          [[NSFileManager defaultManager] fileExistsAtPath:self.cachedThumbnailUrl.path];
}

- (NSURL*)cachedGifUrl {
  return [[AGDataStore sharedStore].cacheDirectory URLByAppendingPathComponent:self.imageHash];
}

- (NSURL*)cachedThumbnailUrl {
  NSString *fn = [NSString stringWithFormat:@"t_%@_%lu.jpg",self.imageHash,kGifThumbnailSize];
  return [[AGDataStore sharedStore].cacheDirectory URLByAppendingPathComponent:fn];
}

/*******************************************************************************
 * Core Data
 ******************************************************************************/
+ (NSArray*)gifsWithPredicate:(NSPredicate*)pred sort:(NSArray*)sort range:(NSRange)range {
  NSError *err;
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:[[self class] entityDescription]];
  if(pred) {
    [request setPredicate:pred];
  }
  if(sort) {
    [request setSortDescriptors:sort];
  }
  if(range.length != 0) {
    [request setFetchLimit:range.length];
    [request setFetchOffset:range.location];
  }
  return [[AGDataStore sharedStore].managedObjectContext executeFetchRequest:request error:&err];
}

+ (NSArray*)allGifs {
  return [self gifsWithPredicate:nil sort:nil range:NSMakeRange(0, 0)];
}

+ (NSArray*)recentGifs:(NSInteger)limit {
  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"uploadedAt" ascending:NO];
  NSRange range = NSMakeRange(0, limit);
  return [self gifsWithPredicate:nil sort:@[sort] range:range];
}

+ (AGGif*)gifWithImageHash:(NSString*)imageHash {
  if(!imageHash.length) {
    return nil;
  }
  NSArray *gifs = [self gifsWithPredicate:[NSPredicate predicateWithFormat:@"imageHash == %@",imageHash] sort:nil range:NSMakeRange(0, 0)];
  return gifs.count ? gifs[0] : nil;
}

+ (AGGif*)gifWithServerDictionary:(NSDictionary*)dict {
  AGGif * gif = [AGGif gifWithImageHash:dict[@"hash"]] ?: [[AGGif alloc] initWithEntity:[[self class] entityDescription]
                                                         insertIntoManagedObjectContext:[AGDataStore sharedStore].managedObjectContext];
  gif.imageHash = dict[@"hash"];
  gif.name = dict[@"name"];
  gif.type = dict[@"type"];
  gif.uploadedAt = [NSDate dateWithTimeIntervalSince1970:[dict[@"uploaded_at"] doubleValue]];
  gif.size = @([dict[@"size"] integerValue]) ?: @(0);
  gif.flags = @([dict[@"flags"] integerValue]) ?: @(0);
  gif.downloads = @([dict[@"downloads"] integerValue]) ?: @(0);
  gif.views = @([dict[@"views"] integerValue]) ?: @(0);
  return gif;
}

+ (NSEntityDescription*)entityDescription {
  return [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:[AGDataStore sharedStore].managedObjectContext];
}

@end
