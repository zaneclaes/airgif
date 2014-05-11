//
//  AGGifTag.m
//  AirGif
//
//  Created by Zane Claes on 5/11/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGGifTag.h"
#import "AGDataStore.h"

@implementation AGGifTag

@dynamic tag, strength, gif;

+ (NSOrderedSet*)allTags {
  NSError *err;
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:[[self class] entityDescription]];
  [request setPropertiesToFetch:@[@"tag",@"strength"]];
  [request setReturnsDistinctResults:YES];
  [request setResultType:NSDictionaryResultType];
  NSArray *objects = [[AGDataStore sharedStore].managedObjectContext executeFetchRequest:request error:&err];
  NSMutableDictionary *strengthMap = [NSMutableDictionary new];
  for(NSDictionary *tag in objects) {
    NSInteger strength = [strengthMap[tag[@"tag"]] integerValue];
    strengthMap[tag[@"tag"]] = @(strength + [tag[@"strength"] integerValue]);
  }
  NSArray *tags = [[objects valueForKeyPath:@"tag"] sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(NSString *t1, NSString *t2) {
    return [strengthMap[t1] compare:strengthMap[t2]];
  }];
  return [NSOrderedSet orderedSetWithArray:tags];
}

@end
