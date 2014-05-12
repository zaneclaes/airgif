//
//  AGSetupDirectory.h
//  AirGif
//
//  Created by an Airbnb Engineer on 5/12/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "TESetupAssistant.h"

@interface AGSetupDirectory : TEBaseAssistant

@property (nonatomic, weak) IBOutlet NSTextField *titleLabel;
@property (nonatomic, weak) IBOutlet NSTextField *pathLabel;

- (IBAction)chooseDirectory:(id)sender;

@end
