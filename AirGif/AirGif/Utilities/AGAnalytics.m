//
//  AGAnalytics.m
//  AirGif
//
//  Created by an Airbnb Engineer on 5/14/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGAnalytics.h"

@implementation AGAnalytics


+ (void)trackGifAction:(NSString*)action label:(NSString*)label value:(NSNumber*)val {
  [[AGAnalytics tracker] sendEventWithCategory:@"gif" withAction:action withLabel:label withValue:val];
}

+ (GAReporting*)tracker {
  static AGAnalytics *_analytics = nil;
  static dispatch_once_t onceToken = 0;
  dispatch_once(&onceToken, ^{
    _analytics = [[AGAnalytics alloc] init];
    _analytics.tracker = [[GAReporting alloc] initWithTrackingId:@"UA-3920215-17"];
  });
  return _analytics.tracker;
}

@end
