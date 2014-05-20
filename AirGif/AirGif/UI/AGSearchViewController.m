//
//  AGSearchViewController.m
//  AirGif
//
//  Created by Zane Claes on 5/6/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGSearchViewController.h"
#import "AGSearchResultViewItem.h"
#import "AGDirectoryScanner.h"
#import "AGGif.h"
#import "HTTPRequest.h"
#import "AGDataStore.h"
#import "AGPointManager.h"

static CGFloat const kSearchDelay = 0.3;

@interface AGSearchViewController ()

@end

@implementation AGSearchViewController

- (BOOL)searchOnline {
  return self.searchStyleSegment.selectedSegment == 1;
}

- (void)delayedSetContent {

}

- (void)setContent:(NSSet*)gifs {
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setContent:) object:nil];
  //DLog(@"Content: %@",gifs);
  [self.resultsGrid setContent:[gifs allObjects]];
  [[AGDataStore sharedStore] saveContext];
}

- (IBAction)search:(id)sender {
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(search:) object:nil];
  NSString *q = self.searchField.stringValue ?: @"";

  // Search Local
  __block NSMutableSet *gifs = [NSMutableSet setWithArray:(q.length ? [AGGif searchGifs:q] : [AGGif recentGifs:1000])];
  [self setContent:gifs];
  [AGAnalytics trackGifAction:@"searchLocal" label:q value:@(gifs.count)];

  // Search Online
  if(self.searchOnline && q.length) {
    __block NSInteger downloading = 1;
    [self.progressIndicator startAnimation:nil];
    NSMutableDictionary *params = [AGAnalytics trackedParams];
    params[@"query"] = q?:@"";
    [[HTTPRequest alloc] post:URL_API(@"search") params:params completion:^(HTTPRequest *req) {
      NSArray *items = [req.response[@"items"] isKindOfClass:[NSArray class]] ? req.response[@"items"] : @[];
      for(NSDictionary *data in items) {
        AGGif *gif = [AGGif gifWithServerDictionary:data];
        downloading++;
        [gif cacheThumbnail:^(BOOL success) {
          downloading--;
          if(success) {
            [gifs addObject:gif];
          }
          if(downloading <= 0) {
            [self setContent:gifs];
            [self.progressIndicator stopAnimation:nil];
          }
          else {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setContent:) object:nil];
            [self performSelector:@selector(setContent:) withObject:gifs afterDelay:0.1];
          }
        }];
      }
      downloading--;
      if(downloading <= 0) {
        [self setContent:gifs];
        [self.progressIndicator stopAnimation:nil];
      }
      [AGAnalytics trackGifAction:@"searchOnlineEnd" label:q value:@(items.count)];
    }];
    [AGAnalytics trackGifAction:@"searchOnlineBegin" label:q value:@(0)];
  }
  else {
    [self.progressIndicator stopAnimation:nil];
  }
}

- (void)controlTextDidChange:(NSNotification *)obj {
  [self.progressIndicator startAnimation:nil];
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(search:) object:nil];
  [self performSelector:@selector(search:) withObject:nil afterDelay:kSearchDelay];
}

- (void)viewDidAppear {
  [super viewDidAppear];
  [self.searchField becomeFirstResponder];
}

- (void)awakeFromNib {
  [super awakeFromNib];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(search:)
                                               name:kNotificationGifThumbnailCached object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(search:)
                                               name:kPurchaseCompleteNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(search:)
                                               name:kGifPurchasedNotification object:nil];
  [self.resultsGrid setItemPrototype:[AGSearchResultViewItem new]];
  [self search:nil];
}

@end
