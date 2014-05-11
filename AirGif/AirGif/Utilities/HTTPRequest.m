//
//  HTTPRequest.m
//  Airfare
//
//  Created by Zane Claes on 5/2/13.
//  Copyright (c) 2013 inZania LLC. All rights reserved.
//

#import "HTTPRequest.h"

static NSString* const kBoundary = @"0xKhTmLbOuNdArY";
static NSTimeInterval const kTimeout = 30.f;
static NSOperationQueue * _requests = nil;

@implementation HTTPRequest

@synthesize endpoint = _endpoint,
headers = _headers,
method = _method,
params = _params,
complete = _complete,
error = _error,
response = _json,
statusCode = _status_code,
unthread = _unthread,
storage = _storage;

+ (NSOperationQueue*) Queue
{
  return _requests;
}

- (NSString*) getEndpointURL:(NSString*)endpoint withGETParams:(NSDictionary*)params_in
{
  NSMutableDictionary* params = params_in ? [NSMutableDictionary dictionaryWithDictionary:params_in] : [NSMutableDictionary dictionary];
  NSMutableString* payload = [NSMutableString string];
	for(NSString* key in [params allKeys])
	{
		NSString* val = [params valueForKey:key];
    if(![val isKindOfClass:[NSString class]])
    {
      if([val isKindOfClass:[NSNumber class]])
      {
        val = [((NSNumber*)val) stringValue];
      }
      else
      {
      }
    }

    if([payload length]>0)
      [payload appendString:@"&"];

    if([key length]>0)
    {
      [payload appendFormat:@"%@=",key];
    }
    [payload appendString:val];
	}

  return [NSString stringWithFormat:@"%@%@",endpoint, [payload length]>0?[NSString stringWithFormat:@"?%@",payload]:@""];
}
/*************************************************************************************
 * Main
 ************************************************************************************/

- (void) onDone
{
  if(self.unthread) {
    dispatch_async(dispatch_get_main_queue(), ^{
      _completion(self);
    });
    return;
  }
  if(_completion) {
    _completion(self);
  }
}
- (void) parseJSON
{
  NSError* json_error = nil;
  NSDictionary* json = nil;
  NSError* error = nil;
  NSMutableDictionary* ui = [NSMutableDictionary dictionary];
  if(_data && [_data length])
  {
    json = _data ? [NSJSONSerialization JSONObjectWithData:_data options:0 error:&json_error] : @{};
    if([json isKindOfClass:[NSArray class]]) {
      json = @{@"items":json};
    }

    if(json_error) {
      NSString *body = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
      DLog(@"JSON ERROR: %@ ; %@",json_error,body);
      _error = [NSError errorWithDomain:@"HTTP" code:3 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"JSON Error: %@",body]}];
    }
    if(json && !json_error)
    {
      error = nil;
    }
  }
  if(error || !json || ![json isKindOfClass:[NSDictionary class]])
  {
    if(!error)
    {
      NSString* res = [[NSMutableString alloc] initWithData:_data encoding:_encoding_in];
      if(!res)
      {
        _encoding_in = NSASCIIStringEncoding;
        res = [[NSMutableString alloc] initWithData:_data encoding:_encoding_in];
      }
      NSString* msg = @"the server returned empty results";
      if(res)
      {
        //[ui setObject:res forKey:@"results"];
        NSString* shrt = [res length] > 300 ? [res substringToIndex:300] : res;
        msg = [res length] ? [NSString stringWithFormat:@"the HTTP connection returned an error: %@",shrt] : @"the API did not return any data";
      }

      if(msg && [msg length] && ui) {
        _error = [NSError errorWithDomain:@"HTTP" code:4 userInfo:@{NSLocalizedDescriptionKey:msg?:@""}];
      }
      if(!error) {
        _error = [NSError errorWithDomain:@"HTTP" code:3 userInfo:@{NSLocalizedDescriptionKey:@"Unknown"}];
      }
      //if(error)
      //    DLog(@"Error: %@",res);

    }

    _error = error;
  }
  else
  {
    _json = json;

    if([_json objectForKey:@"error"])
    {
      NSDictionary* err = [_json objectForKey:@"error"];
      if([err isKindOfClass:[NSString class]]) {
        _error = [NSError errorWithDomain:@"HTTP" code:1 userInfo:@{NSLocalizedDescriptionKey:err}];
      }
      else if([err isKindOfClass:[NSDictionary class]]) {
        if([err objectForKey:@"stack"])
        {
          NSMutableString* stack = [NSMutableString stringWithString:[err objectForKey:@"stack"]];
          [stack replaceOccurrencesOfString:@"\\n" withString:@"\n" options:0 range:NSMakeRange(0, [stack length])];
          NSLog(@"*******STACK TRACE**********\n%@\n\n\n",stack);
        }
        NSDictionary* det = [err objectForKey:@"details"];
        NSMutableDictionary* details = [NSMutableDictionary dictionaryWithDictionary:det ? det : [NSDictionary dictionary]];
        NSString* message = [details objectForKey:@"message"];
        if(message)
        {
          //[details setObject:[details objectForKey:@"message"] forKey:NSLocalizedDescriptionKey];
          [details removeObjectForKey:@"message"];
        }
        _error = [NSError errorWithDomain:@"HTTP" code:2 userInfo:@{NSLocalizedDescriptionKey:message?:@""}];
      }
    }
    else if([_json objectForKey:@"response"]) {
      _json = [_json objectForKey:@"response"];
    }
  }

}
- (void) main
{
  [NSThread sleepForTimeInterval:0.1];
  NSHTTPURLResponse* response = nil;
  NSError* error = nil;
  NSData* data = [NSURLConnection sendSynchronousRequest:_request returningResponse:&response error:&error];

  _headers = [[response allHeaderFields] copy];
  _status_code = [response statusCode];

  //NSLog(@"%d [[%@]]: %@",_status_code, _headers, _results);

  if(!_encoding_in)
    _encoding_in = NSUTF8StringEncoding;
  _data = [data copy];
  _contents = [[NSMutableString alloc] initWithData:_data encoding:_encoding_in];
  if(error)
  {
    _error = error;
  }
  else if(!_data.length) {
    _error = [NSError errorWithDomain:@"HTTP" code:7 userInfo:@{NSLocalizedDescriptionKey:@"No Data"}];
  }
  else if([_contents rangeOfString:@"xe-fatal-error"].location!=NSNotFound)
  {
    _error = [NSError errorWithDomain:@"HTTP" code:6 userInfo:@{NSLocalizedDescriptionKey:_contents?:@""}];
  }
  else if(self.jsonDecode)
  {
    [self parseJSON];
  }
  else
  {// NOT JSON decoding
    if(!_data || ![_data length])
    {
      _error = [NSError errorWithDomain:@"HTTP" code:7 userInfo:@{NSLocalizedDescriptionKey:@"No Data"}];
    }
  }

  _complete = YES;
  [self onDone];
}

/*************************************************************************************************************
 * Execution
 ************************************************************************************************************/

- (NSData*) createPayload
{
  if(!_encoding_out)
    _encoding_out = NSUTF8StringEncoding;

  if([self.params isKindOfClass:[NSString class]])
  {
    NSString* body = (NSString*)self.params;
    return [body dataUsingEncoding:_encoding_out];
  }

  NSArray* myDictKeys = [self.params allKeys];
  if(myDictKeys && [myDictKeys count]==1 && [[myDictKeys objectAtIndex:0] isEqualToString:@""])
  {
    [_request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    return [[self.params objectForKey:@""] dataUsingEncoding:_encoding_out];
  }
  NSMutableData* myData = [NSMutableData dataWithCapacity:1];
  NSString* myBoundary = [NSString stringWithFormat:@"--%@\r\n", kBoundary];

  for(int i = 0;i < [myDictKeys count];i++) {
    id myValue = [self.params valueForKey:[myDictKeys objectAtIndex:i]];
    [myData appendData:[myBoundary dataUsingEncoding:_encoding_out]];
    if([myValue isKindOfClass:[NSNumber class]])
    {
      myValue = [((NSNumber*)myValue) stringValue];
    }

    if([myValue isKindOfClass:[NSArray class]] || [myValue isKindOfClass:[NSDictionary class]]) {
      NSData *data = [NSJSONSerialization dataWithJSONObject:myValue options:NSJSONWritingPrettyPrinted error:nil];
      myValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }

    //if ([myValue class] == [[[NSString]] class]) {
    if ([myValue isKindOfClass:[NSString class]]) {
      [myData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [myDictKeys objectAtIndex:i]] dataUsingEncoding:_encoding_out]];
      [myData appendData:[[NSString stringWithFormat:@"%@", myValue] dataUsingEncoding:_encoding_out]];
    } else if(([myValue isKindOfClass:[NSURL class]]) && ([myValue isFileURL])) {

      NSURLRequest* fileUrlRequest = [[NSURLRequest alloc] initWithURL:myValue cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:.1];

      NSError* error = nil;
      NSURLResponse* response = nil;
      [NSURLConnection sendSynchronousRequest:fileUrlRequest returningResponse:&response error:&error];
      NSString* mimeType = [response MIMEType];
      // mimeType => application/octet-stream (def.)

      [myData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [myDictKeys objectAtIndex:i], [[myValue path] lastPathComponent]] dataUsingEncoding:_encoding_out]];
      [myData appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n",mimeType] dataUsingEncoding:_encoding_out]];
      [myData appendData:[NSData dataWithContentsOfFile:[myValue path]]];
    } else if(([myValue isKindOfClass:[NSData class]])) {
      [myData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [myDictKeys objectAtIndex:i], [myDictKeys objectAtIndex:i]] dataUsingEncoding:_encoding_out]];
      [myData appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:_encoding_out]];
      [myData appendData:myValue];
    } else { // eof if()
      NSLog(@"Oops! Could not send the data because it was an unknown class...");
    }
    [myData appendData:[@"\r\n" dataUsingEncoding:_encoding_out]];
  } // eof for()
  if([myData length])
  {
    [myData appendData:[[NSString stringWithFormat:@"--%@--\r\n", kBoundary] dataUsingEncoding:_encoding_out]];
    [_request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",kBoundary] forHTTPHeaderField:@"Content-Type"];
  }

  return myData;
}
- (id) connect
{
  _json = nil;
  _error = nil;
  _headers = nil;
  _complete = NO;

  NSString* url_str = [self getEndpointURL:self.endpoint withGETParams:nil];
	if([[self.method uppercaseString] isEqualToString:@"POST"])
	{
    NSURL* url = [NSURL URLWithString:url_str];
    _request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:kTimeout];
    NSData* payload = [self createPayload];

		//Prepare the POST data:
		if(payload!=nil && [payload length]>0)
		{
      [_request setValue:[NSString stringWithFormat:@"%d",(int)[payload length]] forHTTPHeaderField:@"Content-Length"];
      [_request setHTTPBody:payload];
		}
	}
	else
	{
    NSString* url = [self getEndpointURL:self.endpoint withGETParams:self.params];
		_request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:kTimeout];
	}
  [_request setTimeoutInterval:kTimeout];
  [_request setHTTPMethod:self.method];
  if(_headers_in)
  {
    for(NSString* header in [_headers_in allKeys])
    {
      [_request setValue:[_headers_in valueForKey:header] forHTTPHeaderField:header];
    }
  }
  [_requests addOperation:self];
  return self;
}
/*************************************************************************************
 * Lifecycle
 ************************************************************************************/
- (id) initWithEndpoint:(NSString*)endpoint
             httpMethod:(NSString*)method
                headers:(NSDictionary*)headers
                 params:(NSDictionary*)params
               unthread:(BOOL)unthread
             completion:(HTTPRequestResponder)completion
{
  if((self = [super init]))
  {
    _endpoint = endpoint;
    _method = [method isKindOfClass:[NSString class]] ? method : @"GET";
    self.unthread = unthread;
    if([params isKindOfClass:[NSDictionary class]])
      _params = params;
    _completion = completion;
    if(headers && [headers isKindOfClass:[NSDictionary class]])
      _headers_in = headers;
    if(!_requests) {
      _requests = [[NSOperationQueue alloc] init];
      [_requests setMaxConcurrentOperationCount:3];
    }
  }
  return self;
}
- (id) initWithEndpoint:(NSString*)endpoint
             httpMethod:(NSString*)method
                headers:(NSDictionary*)headers
                 params:(NSDictionary*)params
             completion:(HTTPRequestResponder)completion
{
  return [self initWithEndpoint:endpoint httpMethod:method headers:headers params:params unthread:NO completion:completion];
}

- (id) getThreaded:(NSString*)endpoint params:(NSDictionary*)params completion:(HTTPRequestResponder)completion
{
  HTTPRequest* ret = [self initWithEndpoint:endpoint httpMethod:@"GET" headers:nil params:params completion:completion];
  ret.jsonDecode = YES;
  [ret connect];
  return ret;
}
- (id) postThreaded:(NSString*)endpoint params:(NSDictionary*)params completion:(HTTPRequestResponder)completion
{
  HTTPRequest* ret = [self initWithEndpoint:endpoint httpMethod:@"POST" headers:nil params:params completion:completion];
  ret.jsonDecode = YES;
  [ret connect];
  return ret;
}

- (id) get:(NSString*)endpoint params:(NSDictionary*)params completion:(HTTPRequestResponder)completion
{
  HTTPRequest* ret = [[self initWithEndpoint:endpoint httpMethod:@"GET" headers:nil params:params completion:completion] connect];
  ret.unthread = YES;
  ret.jsonDecode = YES;
  return ret;
}
- (id) post:(NSString*)endpoint params:(NSDictionary*)params completion:(HTTPRequestResponder)completion
{
  HTTPRequest* ret = [[self initWithEndpoint:endpoint httpMethod:@"POST" headers:nil params:params completion:completion] connect];
  ret.unthread = YES;
  ret.jsonDecode = YES;
  return ret;
}

- (id) download:(NSString*)endpoint completion:(HTTPRequestResponder)completion
{
  HTTPRequest* ret = [[self initWithEndpoint:endpoint httpMethod:@"GET" headers:nil params:nil completion:completion] connect];
  ret.unthread = YES;
  ret.jsonDecode = NO;
  return ret;
}
@end
