//
//  AGSetupDirectory.m
//  AirGif
//
//  Created by an Airbnb Engineer on 5/12/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGSetupDirectory.h"
#import "AGSetupAssistant.h"
#import "AGDirectoryScanner.h"

@interface AGSetupDirectory ()
@property (nonatomic, strong) NSURL *directoryURL;
@property (nonatomic, strong) NSData *directoryBookmark;
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

      self.directoryURL = fp;
      self.directoryBookmark = [self.directoryURL bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope
                                           includingResourceValuesForKeys:nil
                                                            relativeToURL:nil
                                                                    error:nil];

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
  [AGAnalytics view:@"setup"];
  [AGAnalytics trackSetupAction:@"start" label:nil value:nil];
}
- (void)nextPressed:(id)sender {
  NSString *path = self.pathLabel.stringValue;
  if(!path.length) {
    [super nextPressed:sender];
    return;
  }
  NSError *err = nil;
  [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&err];
  // Check write permissions...?
  if(!self.directoryBookmark || !path.length || err || ![[NSFileManager defaultManager] isWritableFileAtPath:path]) {
    self.titleLabel.stringValue = NSLocalizedString(@"setup.directory.invalid", @"");
    [AGAnalytics trackSetupAction:@"error" label:err.localizedDescription value:nil];
    return;
  }

  [[NSUserDefaults standardUserDefaults] setObject:path forKey:kKeyGifDirectory];
  [[NSUserDefaults standardUserDefaults] setObject:self.directoryBookmark forKey:kKeyGifBookmark];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [AGAnalytics trackSetupAction:@"stop" label:nil value:nil];
  [super nextPressed:sender];
}

@end
