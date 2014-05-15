//
//  AGSearchViewController.h
//  AirGif
//
//  Created by Zane Claes on 5/6/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGContentViewController.h"

@interface AGSearchViewController : AGContentViewController <NSTextFieldDelegate>

@property (nonatomic, weak) IBOutlet NSSearchField *searchField;
@property (nonatomic, weak) IBOutlet NSCollectionView *resultsGrid;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *searchStyleSegment;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (nonatomic, readonly) BOOL searchOnline;

- (IBAction)search:(id)sender;

@end
