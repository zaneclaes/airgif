/*
 File: DragDropImageView.m
 Abstract: Custom subclass of NSImageView with support for drag and drop operations.
 Version: 1.1
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import "AGDraggableImageView.h"
#import "AGGif.h"
#import "AGTagViewController.h"
#import "AGSettings.h"
#import "AGPointManager.h"
#import "AGDataStore.h"
#import "AGWindowUtilities.h"

@implementation AGDraggableImageView

@synthesize allowDrag;
@synthesize delegate;

NSString *kPrivateDragUTI = @"com.inzania.airgif";

- (id)initWithCoder:(NSCoder *)coder
{
  /*------------------------------------------------------
   Init method called for Interface Builder objects
   --------------------------------------------------------*/
  self=[super initWithCoder:coder];
  if ( self ) {
    self.allowDrag = YES;
  }
  return self;
}

- (void)_save {
  NSSavePanel *tvarNSSavePanelObj	= [NSSavePanel savePanel];
  NSInteger tvarInt	= [tvarNSSavePanelObj runModal];
  if(tvarInt == NSOKButton){
    [[NSFileManager defaultManager] copyItemAtURL:self.gif.cachedGifUrl toURL:[tvarNSSavePanelObj URL] error:nil];
  } else if(tvarInt == NSCancelButton) {
    return;
  } else {
    return;
  } // end if
}

- (void)purchase {
  [NSApp stopModal];
  NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"points.purchase.req",@""),[AGSettings sharedSettings].pointsGifDownload];
  NSAlert* confirmAlert = [NSAlert alertWithMessageText:msg
                                          defaultButton:[AGPointManager sharedManager].purchaseString
                                        alternateButton:NSLocalizedString(@"points.purchase.earn",@"")
                                            otherButton:nil
                              informativeTextWithFormat:NSLocalizedString(@"points.purchase.body", @"")];
  [confirmAlert beginSheetModalForWindow:nil
                           modalDelegate:[AGWindowUtilities mainWindow]
                          didEndSelector:@selector(purchase:code:context:)
                             contextInfo:nil];
  [AGAnalytics trackGifAction:@"purchase" label:@"prompt" value:nil];
  
  NSMutableDictionary *params = [AGAnalytics trackedParams];
  params[@"hash"] = self.gif.imageHash;
  [[HTTPRequest alloc] post:URL_API(@"download") params:params completion:nil];
}

- (BOOL)checkForSaveAction {
  if(self.gif.wasImported.boolValue || self.gif.purchaseDate) {
    return YES;
  }
  else {
    if([[AGPointManager sharedManager] spend:[AGSettings sharedSettings].pointsGifDownload reason:@"download"]) {
      [self.gif purchase];
      return YES;
    }
    else {
      [self purchase];
    }
  }
  return NO;
}

- (void)save {
  if([self checkForSaveAction]) {
    [self _save];
  }
}


#pragma mark - Source Operations

- (void)mouseDown:(NSEvent*)event
{
  if (self.allowDrag && [self checkForSaveAction]) {
    NSPoint dragPosition;
    NSRect imageLocation;
    
    dragPosition = [self convertPoint:[event locationInWindow] fromView:nil];
    dragPosition.x -= 16;
    dragPosition.y -= 16;
    imageLocation.origin = dragPosition;
    imageLocation.size = NSMakeSize(32,32);
    //[self dragPromisedFilesOfTypes:@[@"gif"] //NSPasteboardTypeTIFF
    //                      fromRect:imageLocation source:self slideBack:YES event:event];
    //[self dragImage:self.image at:self.frame.origin offset:NSMakeSize(0, 0) event:event
    //     pasteboard:[NSPasteboard generalPasteboard] source:self slideBack:YES];
    
    NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    [pasteboard clearContents];
    
    [pasteboard declareTypes:@[NSURLPboardType] owner:self];
    [pasteboard writeObjects:@[self.gif.cachedGifUrl]];
    
    dragPosition.x -= self.image.size.width/2;
    dragPosition.y -= self.image.size.height/2;
    [super dragImage:self.image at:dragPosition offset:NSZeroSize event:event
         pasteboard:pasteboard source:self slideBack:YES];
  }
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
  NSPasteboard *pboard = [sender draggingPasteboard];
  
  if ( [[pboard types] containsObject:NSFilesPromisePboardType] ) {
    //NSArray *filenames = [sender namesOfPromisedFilesDroppedAtDestination:dropLocation];
    // Perform operation using the files’ names, but without the
    // files actually existing yet
  }
  return YES;
}

- (void)dragImage:(NSImage *)anImage at:(NSPoint)viewLocation offset:(NSSize)initialOffset event:(NSEvent *)event pasteboard:(NSPasteboard *)pboard source:(id)sourceObj slideBack:(BOOL)slideFlag
{
  //create a new image for our semi-transparent drag image
  NSImage* dragImage=[[NSImage alloc] initWithSize:[[self image] size]];
  
  [dragImage lockFocus];//draw inside of our dragImage
  //draw our original image as 50% transparent
  [[self image] dissolveToPoint: NSZeroPoint fraction: .5];
  [dragImage unlockFocus];//finished drawing
  [dragImage setScalesWhenResized:NO];//we want the image to resize
  [dragImage setSize:[self bounds].size];//change to the size we are displaying
  
  [super dragImage:dragImage at:self.bounds.origin offset:NSZeroSize event:event pasteboard:pboard source:sourceObj slideBack:slideFlag];
}

- (NSArray *)namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination
{
  NSArray *representations;
  NSData *bitmapData;
  
  representations = [[self image] representations];
  
  if ([[[representations objectAtIndex:0] className] isEqualToString:@"NSBitmapImageRep"]) {
    bitmapData = [NSBitmapImageRep representationOfImageRepsInArray:representations
                                                          usingType:NSPNGFileType properties:nil];
  } else {
    NSLog(@"%@", [[[[self image] representations] objectAtIndex:0] className]);
    
    [[self image] lockFocus];
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0, 0.0, [self image].size.width, self.image.size.height)];
    [[self image] unlockFocus];
    
    bitmapData = [bitmapRep TIFFRepresentation];
  }
  
  [bitmapData writeToFile:[[dropDestination path] stringByAppendingPathComponent:@"test.png"]  atomically:YES];
  return [NSArray arrayWithObjects:@"test.png", nil];
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
  /*
   NSDragOperationNone		= 0,
   NSDragOperationCopy		= 1,
   NSDragOperationLink		= 2,
   NSDragOperationGeneric	= 4,
   NSDragOperationPrivate	= 8,
   NSDragOperationAll_Obsolete	= 15,
   NSDragOperationMove		= 16,*/
  /*------------------------------------------------------
   NSDraggingSource protocol method.  Returns the types of operations allowed in a certain context.
   --------------------------------------------------------*/
  switch (context) {
    case NSDraggingContextOutsideApplication:
      return NSDragOperationCopy;
      
      //by using this fall through pattern, we will remain compatible if the contexts get more precise in the future.
    case NSDraggingContextWithinApplication:
    default:
      return NSDragOperationNone;
      break;
  }
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
  /*------------------------------------------------------
   accept activation click as click in window
   --------------------------------------------------------*/
  //so source doesn't have to be the active window
  return YES;
}

- (void)pasteboard:(NSPasteboard *)sender item:(NSPasteboardItem *)item provideDataForType:(NSString *)type
{
  /*------------------------------------------------------
   method called by pasteboard to support promised
   drag types.
   --------------------------------------------------------*/
  //sender has accepted the drag and now we need to send the data for the type we promised
  if ( [type compare: NSPasteboardTypeTIFF] == NSOrderedSame ) {
    
    //set data for TIFF type on the pasteboard as requested
    [sender setData:[[self image] TIFFRepresentation] forType:NSPasteboardTypeTIFF];
    
  } else if ( [type compare: NSPasteboardTypePDF] == NSOrderedSame ) {
    
    //set data for PDF type on the pasteboard as requested
    [sender setData:[self dataWithPDFInsideRect:[self bounds]] forType:NSPasteboardTypePDF];
  }
  
}
@end