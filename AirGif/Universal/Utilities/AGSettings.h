//
//  AGSettings.h
//  AirGif
//
//  Created by an Airbnb Engineer on 5/15/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGSettings : NSObject

@property (nonatomic, readonly) NSInteger pointsGifDownload;
@property (nonatomic, readonly) NSInteger pointsUploadGif;
@property (nonatomic, readonly) NSInteger pointsPerUSD;
@property (nonatomic, readonly) NSInteger maxFlags;
@property (nonatomic, readonly) NSTimeInterval scanFrequency;
@property (nonatomic, readonly) NSArray *products;

+ (AGSettings*)sharedSettings;

@end
