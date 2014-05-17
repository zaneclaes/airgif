//
//  AGAnalytics.m
//  AirGif
//
//  Created by an Airbnb Engineer on 5/14/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGAnalytics.h"

@implementation AGAnalytics

+ (NSMutableDictionary*)trackedParams {
  NSDictionary * sv = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];

  NSMutableDictionary *p = [NSMutableDictionary new];
  p[@"udid"] = [AGAnalytics tracker].deviceIdentifier;
  p[@"osx"] = [sv objectForKey:@"ProductVersion"] ?: @"";
  p[@"version"] = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"";
  return p;
}

+ (void)trackGifAction:(NSString*)action label:(NSString*)label value:(NSNumber*)val {
  [[AGAnalytics tracker] sendEventWithCategory:@"gif" withAction:action withLabel:label withValue:val];
}
+ (void)trackSetupAction:(NSString*)action label:(NSString*)label value:(NSNumber*)val {
  [[AGAnalytics tracker] sendEventWithCategory:@"setup" withAction:action withLabel:label withValue:val];
}
+ (void)trackTransaction:(NSString*)action label:(NSString*)label value:(NSNumber*)val {
  [[AGAnalytics tracker] sendEventWithCategory:@"transaction" withAction:action withLabel:label withValue:val];
}
+ (void)view:(NSString*)screen {
  NSMutableString *str = [[screen lowercaseString] mutableCopy];
  [str replaceOccurrencesOfString:@" " withString:@"-" options:0 range:NSMakeRange(0, str.length)];
  [[AGAnalytics tracker] sendView:[NSString stringWithFormat:@"osx/%@",str]];
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
