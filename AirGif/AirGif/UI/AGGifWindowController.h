//
//  AGGifWindowController.h
//  AirGif
//
//  Created by an Airbnb Engineer on 5/12/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AGGif;

@interface AGGifWindowController : NSWindowController

@property (nonatomic, strong) AGGif *gif;

- (id)initWithGif:(AGGif*)gif;

@end
