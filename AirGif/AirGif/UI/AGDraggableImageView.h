/*
 File: DragDropImageView.h
 Abstract: Custom subclass of NSImageView with support for drag and drop operations.
 Version: 1.1
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class AGGif;
@protocol AGDraggableImageViewDelegate;

@interface AGDraggableImageView : NSImageView <NSDraggingSource, NSDraggingDestination, NSPasteboardItemDataProvider>
{
  //highlight the drop zone
  BOOL highlight;
}

@property (assign) BOOL allowDrag;
@property (nonatomic, strong) AGGif *gif;
@property (assign) id<AGDraggableImageViewDelegate> delegate;

- (id)initWithCoder:(NSCoder *)coder;
- (void)save;

@end

@protocol AGDraggableImageViewDelegate <NSObject>

- (void)dropComplete:(NSString *)filePath;

@end