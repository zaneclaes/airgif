//
//  SKProduct+Pricing.m
//  SharedNotes
//
//  Created by Zane Claes on 4/25/14.
//  Copyright (c) 2014 inZania LLC. All rights reserved.
//

#import "SKProduct+Pricing.h"

@implementation SKProduct (Pricing)

- (NSString *) priceAsString
{
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
  [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [formatter setLocale:[self priceLocale]];

  NSString *str = [formatter stringFromNumber:[self price]];
  return str;
}

@end