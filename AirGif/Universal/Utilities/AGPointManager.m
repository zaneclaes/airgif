//
//  AGPointManager.m
//  AirGif
//
//  Created by Zane Claes on 5/17/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGPointManager.h"
#import "AGAnalytics.h"

static NSString * const kKeyPoints = @"points";

@implementation AGPointManager

- (NSInteger)points {
  return [[NSUserDefaults standardUserDefaults] integerForKey:kKeyPoints];
}

- (void)earn:(NSInteger)amount reason:(NSString*)reason {
  [[NSUserDefaults standardUserDefaults] setObject:@(self.points + amount) forKey:kKeyPoints];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [AGAnalytics trackTransaction:@"earn" label:reason value:@(amount)];
}

- (BOOL)spend:(NSInteger)amount reason:(NSString*)reason {
  if(self.points < amount) {
    return NO;
  }
  [[NSUserDefaults standardUserDefaults] setObject:@(self.points - amount) forKey:kKeyPoints];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [AGAnalytics trackTransaction:@"spend" label:reason value:@(-amount)];
  return YES;
}

+ (AGPointManager*)sharedManager {
  static AGPointManager *_point_manager = nil;
  static dispatch_once_t onceToken = 0;
  dispatch_once(&onceToken, ^{
    _point_manager = [[AGPointManager alloc] init];
  });
  return _point_manager;
}

@end
