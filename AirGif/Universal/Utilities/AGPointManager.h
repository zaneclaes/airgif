//
//  AGPointManager.h
//  AirGif
//
//  Created by Zane Claes on 5/17/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGPointManager : NSObject

@property (nonatomic, readonly) NSInteger points;

- (void)earn:(NSInteger)amount reason:(NSString*)reason;
- (BOOL)spend:(NSInteger)amount reason:(NSString*)reason;

+ (AGPointManager*)sharedManager;

@end
