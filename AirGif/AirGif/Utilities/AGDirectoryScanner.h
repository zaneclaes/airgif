//
//  AGDirectoryScanner.h
//  AirGif
//
//  Created by Zane Claes on 5/5/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kKeyGifDirectory = @"dir_gif";
static NSString * const kKeyGifBookmark = @"dir_gif_bookmark";

@class AGDirectoryScanner;
@protocol AGDirectoryScannerDelegate <NSObject>
@required
- (void)directoryScannerDidFinishUploadingFiles:(AGDirectoryScanner*)scanner withError:(NSError*)error;
- (void)directoryScannerDidProgress:(AGDirectoryScanner*)scanner;
@end

@interface AGDirectoryScanner : NSObject

@property (nonatomic, weak) id<AGDirectoryScannerDelegate> delegate;
@property (nonatomic, readonly) NSURL *directory;
@property (nonatomic, readonly) NSArray *animatedGifs;// Populated at instantiation by the scan function
@property (nonatomic, readonly) NSOrderedSet *changeSet;// An array of hashes that the server does not contain; gets populated during [upload];
@property (nonatomic, readonly) NSInteger filesUploaded;// The index within the changeSet that is being uploaded

- (void)upload;
- (NSError*)scan;

+ (NSTimeInterval)timeSinceLastScan;

- (id)initWithBookmark;

@end
