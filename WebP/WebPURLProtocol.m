//
//  WebPURLProtocol.m
//  webpcnv
//
//  Created by Liang Jin on 3/29/15.
//  Copyright (c) 2015 Jin. All rights reserved.
//

#import "WebPURLProtocol.h"
#import "WebPConverter.h"


NSString * const KWebPProtocolKey = @"KWebPProtocolKey";

@interface WebPURLProtocol ()

@property (nonatomic,retain)NSURLConnection* connection;
@property (nonatomic,retain)WebPConverter*   webpcnv;

@end

@implementation WebPURLProtocol

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client
{
    NSMutableURLRequest* mRequest = [request mutableCopy];

    [NSURLProtocol setProperty:@"" forKey:KWebPProtocolKey inRequest:mRequest];
    
    if (self = [super initWithRequest:mRequest cachedResponse:cachedResponse client:client])
    {
        
    }
    return self;
}

- (void)dealloc
{
    self.connection = nil;
    self.webpcnv = nil;
    [super dealloc];
}
/*======================================================================
 Begin responsibilities for protocol implementors
 
 The methods between this set of begin-end markers must be
 implemented in order to create a working protocol.
 ======================================================================*/

/*!
 @method canInitWithRequest:
 @abstract This method determines whether this protocol can handle
 the given request.
 @discussion A concrete subclass should inspect the given request and
 determine whether or not the implementation can perform a load with
 that request. This is an abstract method. Sublasses must provide an
 implementation. The implementation in this class calls
 NSRequestConcreteImplementation.
 @param request A request to inspect.
 @result YES if the protocol can handle the given request, NO if not.
 */
+ (BOOL)canInitWithRequest:(NSURLRequest *)request;
{
    if ([NSURLProtocol propertyForKey:KWebPProtocolKey inRequest:request]) {
        return NO;
    }
    NSString* ua = [request valueForHTTPHeaderField:@"User-Agent"];
    if (![ua hasPrefix:@"Mozilla/5.0 "]) {
        return NO;
    }
    NSString* accept = [request valueForHTTPHeaderField:@"Accept"];
    if ([accept length] == 0) {
        return YES;
    }
    return NO;
}
/*!
 @method canonicalRequestForRequest:
 @abstract This method returns a canonical version of the given
 request.
 @discussion It is up to each concrete protocol implementation to
 define what "canonical" means. However, a protocol should
 guarantee that the same input request always yields the same
 canonical form. Special consideration should be given when
 implementing this method since the canonical form of a request is
 used to look up objects in the URL cache, a process which performs
 equality checks between NSURLRequest objects.
 <p>
 This is an abstract method; sublasses must provide an
 implementation. The implementation in this class calls
 NSRequestConcreteImplementation.
 @param request A request to make canonical.
 @result The canonical form of the given request.
 */
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request;
{
    return request;
}

/*!
 @method requestIsCacheEquivalent:toRequest:
 @abstract Compares two requests for equivalence with regard to caching.
 @discussion Requests are considered euqivalent for cache purposes
 if and only if they would be handled by the same protocol AND that
 protocol declares them equivalent after performing
 implementation-specific checks.
 @result YES if the two requests are cache-equivalent, NO otherwise.
 */
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b;
{
    return [[a URL] isEqual:[b URL]];
}
/*!
 @method startLoading
 @abstract Starts protocol-specific loading of a request.
 @discussion When this method is called, the protocol implementation
 should start loading a request.
 */
- (void)startLoading;
{
    self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
}
/*!
 @method stopLoading
 @abstract Stops protocol-specific loading of a request.
 @discussion When this method is called, the protocol implementation
 should end the work of loading a request. This could be in response
 to a cancel operation, so protocol implementations must be able to
 handle this call while a load is in progress.
 */
- (void)stopLoading;
{
    [self.connection cancel];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if (response)
    {
        
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
        return nil;
    }
    else
    {
        return request;
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSDictionary* responseHeaders = [httpResponse allHeaderFields];
        NSString* contentType = [responseHeaders objectForKey:@"Content-Type"];
        if ([contentType hasPrefix:@"image"]
            || [contentType isEqualToString:@"application/octet-stream"]
            ) {
            self.webpcnv = [[[WebPConverter alloc] initWithType:EWebPConverter_toPNG] autorelease];
        }
    }
    
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (self.webpcnv) {
        WebPConverterError error = WebPConverterError_None;
        NSData* resultdata = [self.webpcnv incrementalCovert:data withError:&error];
        if (error == WebPConverterError_None) {
            data = resultdata;
        } else {
            self.webpcnv = nil;
        }
    }
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.webpcnv) {
        NSData* data = [self.webpcnv finishPushData];
        if ([data length] > 0) {
            [[self client] URLProtocol:self didLoadData:data];
        }
    }
    
    [[self client] URLProtocolDidFinishLoading:self];
}


@end
