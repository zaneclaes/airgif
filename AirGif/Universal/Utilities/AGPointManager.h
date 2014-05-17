//
//  AGPointManager.h
//  AirGif
//
//  Created by Zane Claes on 5/17/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kPurchaseCompleteNotification = @"AGPurchaseCompleteNotification";

@interface AGPointManager : NSObject

@property (nonatomic, readonly) NSInteger points;
@property (nonatomic, readonly) BOOL hasProducts;

- (void)earn:(NSInteger)amount reason:(NSString*)reason;
- (BOOL)spend:(NSInteger)amount reason:(NSString*)reason;

- (void)loadProducts;
- (void)purchase;

+ (AGPointManager*)sharedManager;

@end
