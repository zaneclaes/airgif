//
//  AGGif.h
//  AirGif
//
//  Created by Zane Claes on 5/7/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGData.h"
#import "HTTPRequest.h"

static NSInteger const kGifThumbnailSize = 150;

static NSString * const kNotificationGifThumbnailCached     = @"NotificationGifThumbnailCached";
static NSString * const kNotificationGifCached              = @"NotificationGifCached";

@interface AGGif : AGData

@property (nonatomic, strong) NSString *imageHash;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDate *uploadedAt;
@property (nonatomic, strong) NSNumber *isThumbnailCached;
@property (nonatomic, strong) NSNumber *isGifCached;
@property (nonatomic, strong) NSNumber *size;
@property (nonatomic, strong) NSNumber *views;
@property (nonatomic, strong) NSNumber *downloads;
@property (nonatomic, strong) NSNumber *flags;
@property (nonatomic, strong) NSMutableOrderedSet *tags;
@property (nonatomic, strong) NSDate *purchaseDate;
@property (nonatomic, strong) NSNumber *wasImported;

@property (nonatomic, readonly) NSArray *tagNames;
@property (nonatomic, readonly) NSURL *cachedGifUrl;
@property (nonatomic, readonly) NSURL *cachedThumbnailUrl;

- (void)cache:(void (^)(BOOL))block;          // Thumnail and full image
- (void)cacheThumbnail:(void (^)(BOOL))block; // Just the thumbnail

- (void)flagNSFW:(NSWindow*)presenter completion:(HTTPRequestResponder)completion;

+ (AGGif*)gifWithServerDictionary:(NSDictionary*)dict;
+ (AGGif*)gifWithImageHash:(NSString*)imageHash;
+ (NSArray*)allGifs;
+ (NSArray*)recentGifs:(NSInteger)limit;
+ (NSArray*)searchGifs:(NSString*)query;

@end
