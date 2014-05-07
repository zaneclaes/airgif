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
#import "AGGif.h"

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
  [self.resultsGrid setContent:[AGGif recentGifs:100]];
}

@end
