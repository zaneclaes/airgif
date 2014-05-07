//
//  HTTPRequest.h
//  Airfare
//
//  Created by Zane Claes on 5/2/13.
//  Copyright (c) 2013 inZania LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTTPRequest;
typedef void (^HTTPRequestResponder)(HTTPRequest* req);

@interface HTTPRequest : NSOperation
{
  NSString*                                               _endpoint;
  NSString*                                               _method;
  NSDictionary*                                           _params;
  NSDictionary*                                           _files;

  HTTPRequestResponder                                    _completion;
  BOOL                                                    _unthread;

  NSMutableURLRequest*                                    _request;
  NSDictionary*                                           _headers_in;
  NSDictionary*                                           __strong _json;
  NSError*                                                __strong _error;
  NSMutableDictionary*                                    _headers;
  NSInteger                                               _status_code;
  NSStringEncoding                                        _encoding_out;
  NSStringEncoding                                        _encoding_in;
  BOOL                                                    _complete;
}
@property (readonly) NSString*                              endpoint;
@property (readonly) NSString*                              method;
@property (readonly) NSDictionary*                          params;
@property (nonatomic, strong) NSObject*                     storage;
@property (readwrite, assign) BOOL                          unthread;
@property (readwrite, assign) BOOL                          jsonDecode;

@property (readonly) BOOL                                   complete;
@property (readonly) NSInteger                              statusCode;
@property (strong, readonly) NSError*                       error;
@property (strong, readonly) NSDictionary*                  response;
@property (strong, readonly) NSData*                        data;
@property (strong, readonly) NSString*                      contents;
@property (readonly) NSDictionary*                          headers;

- (id) initWithEndpoint:(NSString*)endpoint
             httpMethod:(NSString*)method
                headers:(NSDictionary*)headers
                 params:(NSDictionary*)params
             completion:(HTTPRequestResponder)completion;
- (id) initWithEndpoint:(NSString*)endpoint
             httpMethod:(NSString*)method
                headers:(NSDictionary*)headers
                 params:(NSDictionary*)params
               unthread:(BOOL)unthread
             completion:(HTTPRequestResponder)completion;
- (id) connect;
- (void) parseJSON;

- (id) getThreaded:(NSString*)endpoint params:(NSDictionary*)params completion:(HTTPRequestResponder)completion;
- (id) postThreaded:(NSString*)endpoint params:(NSDictionary*)params completion:(HTTPRequestResponder)completion;
- (id) get:(NSString*)endpoint params:(NSDictionary*)params completion:(HTTPRequestResponder)completion;
- (id) post:(NSString*)endpoint params:(NSDictionary*)params completion:(HTTPRequestResponder)completion;
- (id) download:(NSString*)endpoint completion:(HTTPRequestResponder)completion;
+ (NSOperationQueue*) Queue;

@end