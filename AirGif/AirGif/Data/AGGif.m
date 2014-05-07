//
//  AGGif.m
//  AirGif
//
//  Created by Zane Claes on 5/7/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGGif.h"
#import "AGDataStore.h"

@implementation AGGif

@dynamic imageHash, name, type, uploadedAt, size, views, downloads, flags;

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
