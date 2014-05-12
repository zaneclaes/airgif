//
//  AGSetupDirectory.m
//  AirGif
//
//  Created by an Airbnb Engineer on 5/12/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGSetupDirectory.h"
#import "AGSetupAssistant.h"

@interface AGSetupDirectory ()

@end

@implementation AGSetupDirectory

- (IBAction)chooseDirectory:(id)sender {

  NSOpenPanel* openDlg = [NSOpenPanel openPanel];
  [openDlg setCanChooseFiles:NO];
  [openDlg setCanChooseDirectories:YES];
  if ( [openDlg runModal] == NSOKButton ) {
    NSArray* files = [openDlg URLs];

    // Loop through all the files and process them.
    for( int i = 0; i < [files count]; i++ )
    {
      NSURL* fp = [files objectAtIndex:i];
      self.pathLabel.stringValue = [fp path];
      break;
    }
  }
}

- (NSArray *)orderedSteps
{
  return @[NSLocalizedString(@"setup.directory", @"")];
}
- (void)start {
  [[controller nextButton] setTitle:NSLocalizedString(@"setup.done", @"")];
  self.pathLabel.stringValue = @"";
  self.titleLabel.stringValue = NSLocalizedString(@"setup.directory.subtext", @"");
}
- (void)nextPressed:(id)sender {
  NSString *path = self.pathLabel.stringValue;
  // Check write permissions...?
  if(!path.length || ![[NSFileManager defaultManager] isWritableFileAtPath:path]) {
    self.titleLabel.stringValue = NSLocalizedString(@"setup.directory.invalid", @"");
    return;
  }

  [[NSUserDefaults standardUserDefaults] setObject:path forKey:kKeyGifDirectory];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [super nextPressed:sender];
}

@end
