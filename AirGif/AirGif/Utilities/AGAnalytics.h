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

+ (void)trackGifAction:(NSString*)action label:(NSString*)label value:(NSNumber*)val;

+ (GAReporting*)tracker;

@end
