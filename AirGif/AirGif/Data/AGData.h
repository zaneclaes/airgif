//
//  AGData.h
//  AirGif
//
//  Created by Zane Claes on 5/11/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface AGData : NSManagedObject

- (id)initAndInsert;

+ (NSEntityDescription*)entityDescription;

@end
