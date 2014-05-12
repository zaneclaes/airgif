//
//  AGSetupAssistant.m
//  AirGif
//
//  Created by an Airbnb Engineer on 5/12/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGSetupAssistant.h"
#import "AGDirectoryScanner.h"
#import "TESetupAssistant.h"
#import "AGSetupDirectory.h"

@implementation AGSetupAssistant {
  TESetupAssistant *_setup;
}

- (void)run {
  _setup = [[TESetupAssistant alloc] initMini];
  [_setup setModal:YES];
  [_setup addAssistant:[AGSetupDirectory assistant]];
  [_setup run];
}

- (NSString*)directory {
  return [[NSUserDefaults standardUserDefaults] objectForKey:kKeyGifDirectory];;
}

@end
