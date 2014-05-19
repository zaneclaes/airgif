//
//  AGTagViewController.m
//  AirGif
//
//  Created by Zane Claes on 5/6/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGTagViewController.h"
#import "HTTPRequest.h"
#import "AGDataStore.h"
#import "AGGif.h"
#import "AGGifTag.h"
#import "NSImage+AnimatedGif.h"
#import "ORImageView.h"
#import "AGWindowUtilities.h"
#import "AGAnalytics.h"
#import "AGPointManager.h"
#import <Quartz/Quartz.h>

@interface AGTagViewController () <NSSharingServicePickerDelegate>
@property (nonatomic, strong) NSMutableOrderedSet *allTags;
@property (nonatomic, strong) NSMutableDictionary *queue;
@property (nonatomic, strong) AGGif *currentGif;
@property (nonatomic, strong) ORImageView *orImageView;
@property (nonatomic, readwrite) CGFloat scale;
@end

@implementation AGTagViewController
//
// Show the next gif. Turns off loader.
//
- (void)presentGif:(AGGif*)gif {
  if(!gif || !gif.imageHash) {
    return;
  }
  if(!self.queue[gif.imageHash]) {
    self.queue[gif.imageHash] = gif;
  }
  self.currentGif = gif;
  [self.progressBar stopAnimation:nil];
  [self.tagsField becomeFirstResponder];
  
  NSImage *image = [[NSImage alloc] initWithContentsOfURL:self.currentGif.cachedGifUrl];
  if(image.size.width == 0 || image.size.height == 0) {
    [self.queue removeObjectForKey:gif.imageHash];
    [self presentGif];
    return;
  }
  
  [[[[[self.webView mainFrame] frameView] documentView] superview] scaleUnitSquareToSize:NSMakeSize(1.f / self.scale, 1.f / self.scale)];
  CGFloat scaleX = MIN(1, self.webView.frame.size.width / image.size.width);
  CGFloat scaleY = MIN(1, self.webView.frame.size.height / image.size.height);
  self.scale = MIN(scaleX, scaleY);
  [[[[[self.webView mainFrame] frameView] documentView] superview] scaleUnitSquareToSize:NSMakeSize(self.scale, self.scale)];
  [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:self.currentGif.cachedGifUrl]];
  
  [AGAnalytics view:@"tag-game"];
}

- (void)presentGif {
  if(!self.queue.allKeys.count) {
    [self.progressBar startAnimation:nil];
    return;
  }
  NSString *imageHash = self.queue.allKeys[0];
  [self presentGif:self.queue[imageHash]];
}
//
// Refill the queue
//
- (void)saveToQueue:(AGGif*)gif {
  if(!gif || !gif.imageHash.length) {
    return;
  }
  NSInteger wasEmpty = self.queue.count <= 0;
  self.queue[gif.imageHash] = gif;
  if(wasEmpty) {
    [self presentGif];
  }
}
//
// Send any tagging data to the server
//
- (void)_onGotResponse:(HTTPRequest *)req {
  NSArray *gifs = [req.response[@"gifs"] isKindOfClass:[NSArray class]] ? req.response[@"gifs"] : @[];
  for(NSDictionary *data in gifs) {
    AGGif *gif = [AGGif gifWithServerDictionary:data];
    [gif cache:^(BOOL success) {
      [self saveToQueue:gif];
    }];
  }
  NSDictionary *saved = [req.response[@"tagged"] isKindOfClass:[NSDictionary class]] ? req.response[@"tagged"] : nil;
  if(saved) {
    [AGGif gifWithServerDictionary:saved];
  }
  [[AGDataStore sharedStore] saveContext];

  // Points?
  if(req.params) {
    NSInteger points = [req.response[@"score"] integerValue];
    if(points > 0) {
      [[AGPointManager sharedManager] earn:points reason:@"tag"];
    }
    NSString *str = [req.response[@"message"] isKindOfClass:[NSString class]] ? req.response[@"message"] : nil;
    if(!str) {
      if(points < 2) {
        str = NSLocalizedString(([NSString stringWithFormat:@"points.%lu",points]), @"");
      }
      else {
        str = [NSString stringWithFormat:NSLocalizedString(@"points.many", @""),points];
      }
      if(points > 0) {
        NSString *amount = [NSString stringWithFormat:NSLocalizedString(@"points.display", @""),[AGPointManager sharedManager].points];
        str = [NSString stringWithFormat:@"%@ %@",str,amount];
      }
    }
    self.headerLabel.stringValue = str;
  }

  // New tags from server?
  NSArray *tags = [req.response[@"tags"] isKindOfClass:[NSArray class]] ? req.response[@"tags"] :@[];
  [self.allTags addObjectsFromArray:tags];
}
- (void)_submit:(NSDictionary*)params {
  [self presentGif];
  __weak typeof(self) wself = self;
  [[HTTPRequest alloc] post:URL_API(@"tag") params:params completion:^(HTTPRequest *req) {
    [wself _onGotResponse:req];
  }];
  self.tagsField.objectValue = @[];
}
//
// Hotkey
//
- (BOOL)isCommandEnterEvent:(NSEvent *)e {
  NSUInteger flags = (e.modifierFlags & NSDeviceIndependentModifierFlagsMask);
  BOOL isCommand = (flags & NSCommandKeyMask) == NSCommandKeyMask;
  BOOL isEnter = (e.keyCode == 0x24); // VK_RETURN
  return (isCommand && isEnter);
}
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
  if ((commandSelector == NSSelectorFromString(@"noop:")) && [self isCommandEnterEvent:[NSApp currentEvent]]) {
    [self onPressedNext:nil];
    return YES;
  }
  return NO;
}
/*************************************************************************************************
 * Buttons
 ************************************************************************************************/
- (IBAction)onPressedNext:(NSButton*)sender {
  if(!self.currentGif.imageHash.length) {
    return;
  }
  NSMutableArray *tags = [[self.tagsField objectValue] mutableCopy];
  for(NSInteger x=0; x<tags.count; x++) {
    [tags replaceObjectAtIndex:x withObject:[tags[x] lowercaseString]];
  }
  [self.allTags addObjectsFromArray:tags];
  [self.queue removeObjectForKey:self.currentGif.imageHash];

  NSMutableDictionary *params = [AGAnalytics trackedParams];
  params[@"hash"] = self.currentGif.imageHash;
  params[@"tags"] = tags;
  [self _submit:params];
  [AGAnalytics trackGifAction:@"game" label:@"tag" value:@(tags.count)];
}

- (IBAction)onPressedNSFW:(NSButton*)sender {
  __weak typeof(self) wself = self;
  [self presentGif];
  [self.currentGif flagNSFW:nil completion: ^(HTTPRequest *req) {
    [wself _onGotResponse:req];
  }];
  [AGAnalytics trackGifAction:@"game" label:@"flag" value:@(1)];
}

- (IBAction)onPressedHelp:(NSButton*)sender {
  OPEN_HELP(@"/tag");
  [AGAnalytics trackGifAction:@"game" label:@"help" value:@(0)];
}

- (IBAction)onPressedShare:(NSButton*)sender {
  NSArray *urls = @[[NSURL URLWithString:URL_SHARE_GIF(self.currentGif)]];
  NSSharingServicePicker *sharingServicePicker = [[NSSharingServicePicker alloc] initWithItems:urls];
  sharingServicePicker.delegate = self;
  
  [sharingServicePicker showRelativeToRect:[sender bounds]
                                    ofView:sender
                             preferredEdge:NSMinYEdge];
  [AGAnalytics trackGifAction:@"game" label:@"share" value:nil];
}

- (void)onTagGifNotification:(NSNotification*)n {
  [self presentGif:(AGGif*)[n object]];
}
/*************************************************************************************************
 * Tokens
 ************************************************************************************************/

// Return tokens (tags) for the given autocomplete
- (NSArray *)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring
           indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex {
  return [[self.allTags array] filteredArrayUsingPredicate:
                  [NSPredicate predicateWithFormat:@"SELF beginswith[cd] %@", substring]];
}

// Prevent adding the same token twice
- (NSArray *)tokenField:(NSTokenField *)tokenField shouldAddObjects:(NSArray *)tokens atIndex:(NSUInteger)index {
  NSMutableArray *filtered = [tokens mutableCopy];
  NSArray *existing = [tokenField objectValue];
  for(NSInteger x=0; x<filtered.count; x++) {
    NSString *token = [filtered[x] lowercaseString];
    NSInteger count = 0;
    for(NSString *e in existing) {
      if([token isEqualToString:e]) {
        count++;
      }
    }
    if(count > 1) {
      [filtered removeObject:filtered[x]];
      x--;
    }
    else if(![filtered[x] isEqualToString:token]) {
      [filtered replaceObjectAtIndex:x withObject:token];
    }
  }
  return filtered;
}

/*************************************************************************************************
 * Lifecycle
 ************************************************************************************************/
- (void)viewDidAppear {
  [super viewDidAppear];
  self.headerLabel.stringValue = NSLocalizedString(@"points.tag.instructions", @"");
  self.allTags = [[AGGifTag allTags] mutableCopy];
  [self.tagsField becomeFirstResponder];
  if(!self.queue.count) {
    [self _submit:nil];
  }
}

- (void)viewWillDisappear {
  [super viewWillDisappear];
  [[self.webView mainFrame] loadRequest:nil];
}

- (void)awakeFromNib {
  [super awakeFromNib];
  [self.shareButton sendActionOn:NSLeftMouseDownMask];
  self.scale = 1.f;
  self.queue = [NSMutableDictionary new];
}

@end
