//
//  AGGif.h
//  AirGif
//
//  Created by Zane Claes on 5/7/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSInteger const kGifThumbnailSize = 150;

@interface AGGif : NSManagedObject

@property (nonatomic, strong) NSString *imageHash;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDate *uploadedAt;
@property (nonatomic, strong) NSNumber *size;
@property (nonatomic, strong) NSNumber *views;
@property (nonatomic, strong) NSNumber *downloads;
@property (nonatomic, strong) NSNumber *flags;

@property (nonatomic, readonly) NSURL *cachedGifUrl;
@property (nonatomic, readonly) NSURL *cachedThumbnailUrl;

- (void)cache:(void (^)(NSError *))block;

+ (AGGif*)gifWithServerDictionary:(NSDictionary*)dict;
+ (AGGif*)gifWithImageHash:(NSString*)imageHash;
+ (NSArray*)gifsWithPredicate:(NSPredicate*)pred;
+ (NSArray*)allGifs;

@end
