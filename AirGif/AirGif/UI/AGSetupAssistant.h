//
//  AGSetupAssistant.h
//  AirGif
//
//  Created by an Airbnb Engineer on 5/12/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kKeyGifDirectory = @"dir_gifs";

@interface AGSetupAssistant : NSObject

@property (nonatomic, readonly) NSString *directory;

- (void)run;

@end
