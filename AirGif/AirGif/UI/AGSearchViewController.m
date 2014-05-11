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

static CGFloat const kSearchDelay = 0.3;

@interface AGSearchViewController ()

@end

@implementation AGSearchViewController

- (void)search {
  DLog(@"Search: %@",self.searchField.stringValue);
  NSString *q = self.searchField.stringValue;
  NSArray *gifs = q.length ? [AGGif searchGifs:q] : [AGGif recentGifs:1000];
  [self.resultsGrid setContent:gifs];
}

- (void)controlTextDidChange:(NSNotification *)obj {
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(search) object:nil];
  [self performSelector:@selector(search) withObject:nil afterDelay:kSearchDelay];
}

- (void)viewDidAppear {
  [super viewDidAppear];
  [self.searchField becomeFirstResponder];
}

- (void)awakeFromNib {
  [super awakeFromNib];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(search)
                                               name:kNotificationGifThumbnailCached object:nil];
  [self.resultsGrid setItemPrototype:[AGSearchResultViewItem new]];
  [self search];
}

@end
