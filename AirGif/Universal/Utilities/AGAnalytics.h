//
//  AGAnalytics.h
//  AirGif
//
//  Created by an Airbnb Engineer on 5/14/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAReporting.h"

@interface AGAnalytics : NSObject

@property (nonatomic, strong) GAReporting *tracker;

+ (NSMutableDictionary*)trackedParams;

+ (void)trackGifAction:(NSString*)action label:(NSString*)label value:(NSNumber*)val;
+ (void)trackSetupAction:(NSString*)action label:(NSString*)label value:(NSNumber*)val;
+ (void)trackTransaction:(NSString*)action label:(NSString*)label value:(NSNumber*)val;
+ (void)view:(NSString*)screen;

+ (GAReporting*)tracker;

@end
