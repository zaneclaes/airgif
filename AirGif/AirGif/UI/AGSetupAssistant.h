//
//  AGSetupAssistant.h
//  AirGif
//
//  Created by an Airbnb Engineer on 5/12/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGSetupAssistant : NSObject

@property (nonatomic, strong) NSString *directory;

- (void)run;

@end
