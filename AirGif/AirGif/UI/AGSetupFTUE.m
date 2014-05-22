//
//  AGSetupFTUE.m
//  AirGif
//
//  Created by an Airbnb Engineer on 5/22/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGSetupFTUE.h"

@implementation AGSetupFTUE

- (NSArray *)orderedSteps
{
  return @[NSLocalizedString(@"setup.ftue", @"")];
}
- (void)start {
  [[controller nextButton] setTitle:NSLocalizedString(@"setup.done", @"")];
  [AGAnalytics view:@"setup"];
  [AGAnalytics trackSetupAction:@"ftue" label:nil value:nil];
}


@end
