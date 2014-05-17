//
//  AGSettings.m
//  AirGif
//
//  Created by an Airbnb Engineer on 5/15/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGSettings.h"
#import "AGDataStore.h"
#import "HTTPRequest.h"

@interface AGSettings ()
@property (nonatomic, readonly) NSMutableDictionary *settings;
@end

@implementation AGSettings

@synthesize settings = _settings;

- (NSInteger)integerValueForKey:(NSString*)key orDefault:(NSInteger)def {
  NSNumber *val = self.settings[key];
  return [val respondsToSelector:@selector(integerValue)] ? [val integerValue] : def;
}

- (NSInteger)pointsPerUSD {
  return [self integerValueForKey:@"pointsPerUSD" orDefault:10];
}

- (NSInteger)pointsGifDownload {
  return [self integerValueForKey:@"pointsGifDownload" orDefault:1];
}

- (NSInteger)maxFlags {
  return [self integerValueForKey:@"maxFlags" orDefault:1];
}

- (void)save {
  [[NSUserDefaults standardUserDefaults] setObject:_settings forKey:@"settings"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)valueForKey:(NSString *)key {
  return self.settings[key];
}

- (void)setValue:(id)value forKey:(NSString *)key {
  if(value) {
    self.settings[key] = value;
  }
  else {
    [self.settings removeObjectForKey:key];
  }
}

- (NSDictionary*)settings {
  if(!_settings) {
    _settings = [[NSUserDefaults standardUserDefaults] objectForKey:@"settings"];
  }
  return _settings;
}

- (void)reload {
  NSMutableDictionary *params = [AGAnalytics trackedParams];
  [[HTTPRequest alloc] post:URL_API(@"settings") params:params completion:^(HTTPRequest *req) {
    if([req.response[@"settings"] isKindOfClass:[NSDictionary class]]) {
      _settings = [req.response[@"settings"] mutableCopy];
      [self save];
    }
  }];
}

- (id)init {
  if((self = [super init])) {
    [self reload];
  }
  return self;
}

+ (AGSettings*)sharedSettings {
  static AGSettings *_settings = nil;
  static dispatch_once_t onceToken = 0;
  dispatch_once(&onceToken, ^{
    _settings = [[AGSettings alloc] init];
  });
  return _settings;
}

@end
