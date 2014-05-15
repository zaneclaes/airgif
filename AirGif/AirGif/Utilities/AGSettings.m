//
//  AGSettings.m
//  AirGif
//
//  Created by an Airbnb Engineer on 5/15/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGSettings.h"

@implementation AGSettings

+ (AGSettings*)sharedSettings {
  static AGSettings *_settings = nil;
  static dispatch_once_t onceToken = 0;
  dispatch_once(&onceToken, ^{
    _settings = [[AGSettings alloc] init];
  });
  return _settings;
}

@end
