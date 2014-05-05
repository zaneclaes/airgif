//
//  AGDirectoryScanner.h
//  AirGif
//
//  Created by an Airbnb Engineer on 5/5/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGDirectoryScanner : NSObject

@property (nonatomic, readonly) NSString *directory;
@property (nonatomic, readonly) NSArray *animatedGifUrls;

- (NSError*)scan;

- (id)initWithDirectory:(NSString*)dir;

@end
