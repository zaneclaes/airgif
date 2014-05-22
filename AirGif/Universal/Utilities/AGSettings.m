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
#import "AGPointManager.h"

@interface AGSettings ()
@property (nonatomic, readonly) NSMutableDictionary *settings;
@end

@implementation AGSettings

@synthesize settings = _settings;

- (NSInteger)integerValueForKey:(NSString*)key orDefault:(NSInteger)def {
  NSNumber *val = self.settings[key];
  return [val respondsToSelector:@selector(integerValue)] ? [val integerValue] : def;
}

- (NSInteger)doubleValueForKey:(NSString*)key orDefault:(NSInteger)def {
  NSNumber *val = self.settings[key];
  return [val respondsToSelector:@selector(doubleValue)] ? [val doubleValue] : def;
}

- (NSInteger)pointsPerUSD {
  return [self integerValueForKey:@"pointsPerUSD" orDefault:1000];
}

- (NSInteger)pointsGifDownload {
  return [self integerValueForKey:@"pointsGifDownload" orDefault:10];
}

- (NSInteger)pointsUploadGif {
  return [self integerValueForKey:@"pointsUploadGif" orDefault:10];
}

- (NSInteger)maxFlags {
  return [self integerValueForKey:@"maxFlags" orDefault:1];
}

- (NSTimeInterval)scanFrequency {
  return [self doubleValueForKey:@"scanFrequency" orDefault:(60 * 5)];
}

- (NSArray*)products {
  return self.settings[@"products"] ?: @[@"com.inzania.AirGif.points.2"];
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
  NSArray *oldProducts = [self.products copy];
  __weak typeof(self) wself = self;
  [[HTTPRequest alloc] post:URL_API(@"settings") params:params completion:^(HTTPRequest *req) {
    if([req.response[@"settings"] isKindOfClass:[NSDictionary class]]) {
      _settings = [req.response[@"settings"] mutableCopy];
      [wself save];
      if(![oldProducts isEqualTo:wself.products]) {
        [[AGPointManager sharedManager] loadProducts];
      }
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
