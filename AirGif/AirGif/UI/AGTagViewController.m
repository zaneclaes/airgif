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

@interface AGTagViewController ()
@property (nonatomic, strong) NSMutableOrderedSet *allTags;
@property (nonatomic, strong) NSMutableDictionary *queue;
@property (nonatomic, strong) AGGif *currentGif;
@end

@implementation AGTagViewController

// Show the next gif. Turns off loader.
- (void)presentGif {
  if(!self.queue.allKeys.count) {
    [self.progressBar startAnimation:nil];
    return;
  }
  NSString *imageHash = self.queue.allKeys[0];
  self.currentGif = self.queue[imageHash];
  [self.queue removeObjectForKey:imageHash];
  self.imageView.image = [[NSImage alloc] initWithContentsOfURL:self.currentGif.cachedGifUrl];
  self.imageView.animates = YES;
  [self.progressBar stopAnimation:nil];
  [self.tagsField becomeFirstResponder];
}

// Refill the queue
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

// Send any tagging data to the server
- (void)_submit:(NSDictionary*)params {
  [self presentGif];
  __weak typeof(self) wself = self;
  [[HTTPRequest alloc] post:URL_API(@"tag") params:params completion:^(HTTPRequest *req) {
    NSArray *gifs = [req.response[@"gifs"] isKindOfClass:[NSArray class]] ? req.response[@"gifs"] : @[];
    for(NSDictionary *data in gifs) {
      AGGif *gif = [AGGif gifWithServerDictionary:data];
      [gif cache:^(BOOL success) {
        [wself saveToQueue:gif];
      }];
    }
    NSDictionary *saved = [req.response[@"tagged"] isKindOfClass:[NSDictionary class]] ? req.response[@"tagged"] : nil;
    if(saved) {
      [AGGif gifWithServerDictionary:saved];
    }
    [[AGDataStore sharedStore] saveContext];
    
    // Points?
    NSInteger points = [req.response[@"score"] integerValue];
    NSString *str = nil;
    if(points < 2) {
      str = NSLocalizedString(([NSString stringWithFormat:@"points.%lu",points]), @"");
    }
    else {
      str = [NSString stringWithFormat:NSLocalizedString(@"points.many", @""),points];
    }
    self.headerLabel.stringValue = str;
    
    // New tags from server?
    NSArray *tags = [req.response[@"tags"] isKindOfClass:[NSArray class]] ? req.response[@"tags"] :@[];
    [self.allTags addObjectsFromArray:tags];
  }];
  self.tagsField.objectValue = @[];
}

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

- (IBAction)onPressedNext:(NSButton*)sender {
  NSMutableDictionary *params = [NSMutableDictionary new];
  params[@"hash"] = self.currentGif.imageHash;
  params[@"tags"] = [self.tagsField objectValue];
  [self _submit:params];
}

- (IBAction)onPressedNSFW:(NSButton*)sender {
  NSMutableDictionary *params = [NSMutableDictionary new];
  params[@"flag"] = @(1);
  [self _submit:params];
}

- (IBAction)onPressedHelp:(NSButton*)sender {
  
}

// Return tokens (tags) for the given autocomplete
- (NSArray *)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring
           indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex {
  NSMutableSet *ret = [NSMutableSet new];
  substring = [substring lowercaseString];
  for(NSString *tag in self.allTags) {
    if([[tag lowercaseString] hasPrefix:substring]) {
      [ret addObject:tag];
    }
  }
  return [ret allObjects];
}

// Prevent adding the same token twice
- (NSArray *)tokenField:(NSTokenField *)tokenField shouldAddObjects:(NSArray *)tokens atIndex:(NSUInteger)index {
  NSMutableArray *filtered = [tokens mutableCopy];
  NSArray *existing = [tokenField objectValue];
  for(NSInteger x=0; x<filtered.count; x++) {
    NSString *token = [filtered[x] lowercaseString];
    NSInteger count = 0;
    for(NSString *e in existing) {
      if([token isEqualToString:[e lowercaseString]]) {
        count++;
      }
    }
    if(count > 1) {
      [filtered removeObject:filtered[x]];
      x--;
    }
  }
  return filtered;
}

- (void)viewDidAppear {
  [super viewDidAppear];
  self.allTags = [[AGGifTag allTags] mutableCopy];
  if(!self.queue.count) {
    [self _submit:@{}];
  }
}

- (void)awakeFromNib {
  [super awakeFromNib];
  self.queue = [NSMutableDictionary new];
}

@end
