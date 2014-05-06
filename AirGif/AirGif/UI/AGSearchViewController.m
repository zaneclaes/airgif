//
//  AGSearchViewController.m
//  AirGif
//
//  Created by an Airbnb Engineer on 5/6/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGSearchViewController.h"
#import "AGSearchResultViewItem.h"
#import "AGDirectoryScanner.h"

@interface AGSearchViewController ()

@end

@implementation AGSearchViewController

- (void)viewDidAppear {
  [super viewDidAppear];
  [self.searchField becomeFirstResponder];
}

- (void)awakeFromNib {
  [super awakeFromNib];
  [self.resultsGrid setItemPrototype:[AGSearchResultViewItem new]];

  AGDirectoryScanner *scanner = [[AGDirectoryScanner alloc] initWithDirectory:@"/Users/zane/Dropbox/Gifs/"];
  [scanner upload];
  [self.resultsGrid setContent:scanner.animatedGifs];
}

@end
