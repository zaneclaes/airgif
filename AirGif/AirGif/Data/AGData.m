//
//  AGData.m
//  AirGif
//
//  Created by Zane Claes on 5/11/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGData.h"
#import "AGDataStore.h"

@implementation AGData

- (id)initAndInsert {
  return [self initWithEntity:[[self class] entityDescription] insertIntoManagedObjectContext:[AGDataStore sharedStore].managedObjectContext];
}

+ (NSEntityDescription*)entityDescription {
  return [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:[AGDataStore sharedStore].managedObjectContext];
}

@end
