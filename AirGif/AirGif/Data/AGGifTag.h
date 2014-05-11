//
//  AGGifTag.h
//  AirGif
//
//  Created by Zane Claes on 5/11/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGData.h"

@class AGGif;

@interface AGGifTag : AGData

@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSNumber *strength;
@property (nonatomic, strong) AGGif *gif;

+ (NSArray*)allTags; // Array of strings

@end
