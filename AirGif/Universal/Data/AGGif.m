//
//  AGGif.m
//  AirGif
//
//  Created by Zane Claes on 5/7/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGGif.h"
#import "AGDataStore.h"
#import "AGGifTag.h"
#import "HTTPRequest.h"
#import "AGSettings.h"
#import "HTTPRequest.h"

static NSOperationQueue * _requests = nil;

@interface AGGif ()
@property (nonatomic, copy) HTTPRequestResponder nsfwBlock;
@end

@implementation AGGif

@dynamic imageHash, name, type, uploadedAt, size, views, downloads, flags, isGifCached, isThumbnailCached, tags, purchaseDate, wasImported;

@synthesize nsfwBlock = _nsfwBlock;

- (void)_flagNSFW:(NSAlert*)a code:(NSInteger)code context:(NSObject*)cxt {
  if(!code) {
    if(self.nsfwBlock) {
      self.nsfwBlock(nil);
      self.nsfwBlock = nil;
    }
    return;
  }
  NSMutableDictionary *params = [AGAnalytics trackedParams];
  params[@"hash"] = self.imageHash;
  params[@"flag"] = @(1);
  [[HTTPRequest alloc] post:URL_API(@"tag") params:params completion:self.nsfwBlock];
  self.nsfwBlock = nil;

  self.flags = @([self.flags integerValue] + 1);
  [[AGDataStore sharedStore] saveContext];
  [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGifThumbnailCached object:self.imageHash];
}

- (void)flagNSFW:(NSWindow*)presenter completion:(HTTPRequestResponder)completion {
  self.nsfwBlock = completion;
  if(!presenter) {
    [self _flagNSFW:nil code:1 context:nil];
    return;
  }
  NSAlert* confirmAlert = [NSAlert alertWithMessageText:@"NSFW?"
                  defaultButton:NSLocalizedString(@"Yes",@"")
                alternateButton:NSLocalizedString(@"No",@"")
                    otherButton:nil
      informativeTextWithFormat:NSLocalizedString(@"NSFWConfirm", @"")];
  [confirmAlert beginSheetModalForWindow:presenter
                           modalDelegate:self
                          didEndSelector:@selector(_flagNSFW:code:context:)
                             contextInfo:nil];

}

- (void)purchase {
  self.purchaseDate = [NSDate date];
  [[AGDataStore sharedStore] saveContext];
  [[NSNotificationCenter defaultCenter] postNotificationName:kGifPurchasedNotification object:self];
  [AGAnalytics trackGifAction:@"purchase" label:@"download" value:nil];
}

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

- (void)_cache:(BOOL)full block:(void (^)(BOOL))block {
  __block NSString *hash = self.imageHash;
  NSInteger thumbSize = kGifThumbnailSize * 2;//[[NSScreen mainScreen] backingScaleFactor];
  BOOL wasThumbnailCached = self.isThumbnailCached.boolValue;
  BOOL wasGifCached = self.isGifCached.boolValue;
  BOOL cached = [self _cacheImage:[NSURL URLWithString:URL_THUMBNAIL(self.imageHash, thumbSize)]
                                            to:self.cachedThumbnailUrl];
  __weak typeof(self) wself = self;
  if(cached && !wasThumbnailCached) {
    dispatch_async(dispatch_get_main_queue(), ^{
      wself.isThumbnailCached = @YES;
      [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGifThumbnailCached object:hash];
    });
  }
  if(full) {
    BOOL fullyCached = [self _cacheImage:[NSURL URLWithString:URL_GIF(self.imageHash)] to:self.cachedGifUrl];
    cached = cached && fullyCached;
    if(self.isGifCached.boolValue && !wasGifCached) {
      dispatch_async(dispatch_get_main_queue(), ^{
        wself.isGifCached = @YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGifCached object:hash];
      });
    }
  }

  dispatch_async(dispatch_get_main_queue(), ^{
    [[AGDataStore sharedStore] saveContext];
    if(block) {
      block(cached);
    }
  });
}

- (void)cache:(BOOL)full block:(void (^)(BOOL))block {
  if(self.isThumbnailCached.boolValue && self.isGifCached.boolValue) {
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
    __strong typeof(self) sself = wself;
    [sself _cache:full block:block];
  }];
}

- (void)cache:(void (^)(BOOL))block {
  [self cache:YES block:block];
}

- (void)cacheThumbnail:(void (^)(BOOL))block {
  [self cache:NO block:block];
}

- (NSURL*)cachedGifUrl {
  return [[AGDataStore sharedStore].cacheDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.gif",self.imageHash]];
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
  [request setReturnsDistinctResults:YES];
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
  NSArray *arr = [[AGDataStore sharedStore].managedObjectContext executeFetchRequest:request error:&err];
  NSMutableDictionary *dedupe = [NSMutableDictionary new];
  for(AGGif *gif in arr) {
    dedupe[gif.imageHash] = gif;
  }
  return dedupe.allValues;
}

+ (NSArray*)allGifs {
  return [self gifsWithPredicate:nil sort:nil range:NSMakeRange(0, 0)];
}

+ (NSArray*)recentGifs:(NSInteger)limit {
  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"uploadedAt" ascending:NO];
  NSRange range = NSMakeRange(0, limit);
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"(wasImported == YES OR purchaseDate != nil) AND \
                       flags < %d AND \
                       isThumbnailCached == YES",
                       [AGSettings sharedSettings].maxFlags];
  return [self gifsWithPredicate:pred sort:@[sort] range:range];
}

+ (NSArray*)searchGifs:(NSString*)query {
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"(wasImported == YES OR purchaseDate != nil) AND \
                       isThumbnailCached == YES AND \
                       flags < %d AND \
                       ((name CONTAINS[cd] %@) OR (SUBQUERY(tags, $x, $x.tag CONTAINS[cd] %@).@count > 0))",
                       [AGSettings sharedSettings].maxFlags, query,query];
  return [self gifsWithPredicate:pred sort:nil range:NSMakeRange(0, 0)];
}

- (NSArray*)tagNames {
  NSMutableArray *names = [NSMutableArray new];
  for(AGGifTag *tag in self.tags) {
    [names addObject:tag.tag];
  }
  return names;
}

+ (AGGif*)gifWithImageHash:(NSString*)imageHash {
  if(!imageHash.length) {
    return nil;
  }
  NSArray *gifs = [self gifsWithPredicate:[NSPredicate predicateWithFormat:@"imageHash == %@",imageHash] sort:nil range:NSMakeRange(0, 0)];
  return gifs.count ? gifs[0] : nil;
}

+ (AGGif*)gifWithServerDictionary:(NSDictionary*)dict {
  AGGif * gif = [AGGif gifWithImageHash:dict[@"hash"]] ?: [[AGGif alloc] initAndInsert];
  gif.imageHash = dict[@"hash"];
  gif.name = dict[@"name"];
  gif.type = dict[@"type"];
  gif.uploadedAt = [NSDate dateWithTimeIntervalSince1970:[dict[@"uploaded_at"] doubleValue]];
  gif.size = @([dict[@"size"] integerValue]) ?: @(0);
  gif.flags = @([dict[@"flags"] integerValue]) ?: @(0);
  gif.downloads = @([dict[@"downloads"] integerValue]) ?: @(0);
  gif.views = @([dict[@"views"] integerValue]) ?: @(0);
  
  // Tags.
  NSArray *existing = [gif tagNames];
  gif.tags = gif.tags ?: [NSMutableOrderedSet new];
  NSArray *tagDefs = [dict[@"tags"] isKindOfClass:[NSArray class]] ? dict[@"tags"] : @[];
  for(NSDictionary *tagData in tagDefs) {
    NSString *name = tagData[@"tag"];
    if([existing containsObject:name]) {
      continue;
    }
    AGGifTag *tag = [[AGGifTag alloc] initAndInsert];
    tag.tag = tagData[@"tag"];
    tag.strength = @([tagData[@"strength"] integerValue]);
    tag.gif = gif;
    [gif.tags addObject:tag];
  }
  
  return gif;
}

@end
