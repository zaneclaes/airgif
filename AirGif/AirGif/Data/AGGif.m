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

@implementation AGGif

@dynamic imageHash, name, type, uploadedAt, size, views, downloads, flags;

- (void)cache:(void (^)(NSError *))block {
  __block NSInteger downloading = 0;
  __block NSError *err = nil;
  
  if(![[NSFileManager defaultManager] fileExistsAtPath:self.cachedGifUrl.path]) {
    downloading++;
    [[HTTPRequest alloc] download:URL_GIF(self.imageHash) completion:^(HTTPRequest *req) {
      err = err ?: req.error;
      if(!req.error && req.data) {
        [req.data writeToURL:self.cachedGifUrl atomically:YES];
      }
      downloading--;
      if(block && downloading==0) {
        block(err);
      }
    }];
  }
  
  if(![[NSFileManager defaultManager] fileExistsAtPath:self.cachedThumbnailUrl.path]) {
    downloading++;
    [[HTTPRequest alloc] download:URL_THUMBNAIL(self.imageHash, kGifThumbnailSize) completion:^(HTTPRequest *req) {
      err = err ?: req.error;
      if(req.data.length) {
        [req.data writeToURL:self.cachedThumbnailUrl atomically:YES];
      }
      downloading--;
      if(block && downloading==0) {
        block(err);
      }
    }];
  }
  
  if(!downloading) {
    if(block) {
      block(nil);
      block = nil;
    }
    return;
  }
}

- (NSURL*)cachedGifUrl {
  return [[AGDataStore sharedStore].cacheDirectory URLByAppendingPathComponent:self.imageHash];
}

- (NSURL*)cachedThumbnailUrl {
  NSString *fn = [NSString stringWithFormat:@"%@_%lu",self.imageHash,kGifThumbnailSize];
  return [[AGDataStore sharedStore].cacheDirectory URLByAppendingPathComponent:fn];
}

+ (NSArray*)gifsWithPredicate:(NSPredicate*)pred {
  NSError *err;
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:[[self class] entityDescription]];
  if(pred) {
    [request setPredicate:pred];
  }
  return [[AGDataStore sharedStore].managedObjectContext executeFetchRequest:request error:&err];
}

+ (NSArray*)allGifs {
  return [self gifsWithPredicate:nil];
}

+ (AGGif*)gifWithImageHash:(NSString*)imageHash {
  if(!imageHash.length) {
    return nil;
  }
  NSArray *gifs = [self gifsWithPredicate:[NSPredicate predicateWithFormat:@"imageHash == %@",imageHash]];
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
