
/***  AOPProxy.h  InnoliFoundation Created by Szilveszter Molnar on 1/7/11.  Copyright 2011 Innoli Kft. All rights reserved. */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, InterceptionPoint){ InterceptPointStart, InterceptPointEnd };
typedef void(^InterceptionBlock)(NSInvocation*inv,InterceptionPoint intPt);

/*!  	 @class AOPProxy
	  @abstract	The AOPProxy is a simple Aspect Oriented Programming-like proxy.
*/
@interface AOPProxy : NSProxy

@property (readonly) id proxiedObject;

/*!   @method initWithInstance:
  	@abstract Creates a new proxy that will act on the provided object instance.
*/
- (id) initWithObject:(id)obj;

+ (instancetype) proxyWithObject:(id)obj;

/*!   @method initWithNewInstanceOfClass:
    @abstract Creates a new proxy and forwards all calls to a new instance of the specified class
*/
+ (instancetype) proxyWithClass:(Class)cls;

/*!   @method interceptMethodStartForSelector:withInterceptorTarget:interceptorSelector:
	  @abstract This method will cause the proxy to invoke the interceptor selector
              on the interceptor target whenever the aSel selector is invoked on this proxy.
	@discussion The interceptor selector must take exactly one parameter, 
              which will be NSInvocation instance for the invocation that was intercepted.
*/
- (void) interceptMethodStartForSelector:(SEL)sel withInterceptorTarget:(id)target interceptorSelector:(SEL)selector;

/*!  @method interceptMethodEndForSelector:withInterceptorTarget:interceptorSelector:
   @abstract This method will cause the proxy to invoke the interceptor selector on the interceptor
             target after the aSel selector is invoked on this proxy.
 @discussion The interceptor selector must take exactly one parameter, 
             which will be NSInvocation instance for the invocation that was intercepted.
*/
- (void) interceptMethodEndForSelector:(SEL)sel withInterceptorTarget:(id)target interceptorSelector:(SEL)selector;

/*!  @method interceptMethodForSelector:interceptorPoint:block:
   @abstract This method will cause the proxy to invoke the block for the selector at the point indicated by the insertion point.
 @discussion The interceptor block must take exactly two parameters,
             which will be NSInvocation instance for the invocation that was intercepted, and the insertion point.
*/
- (void) interceptMethodForSelector:(SEL)sel interceptorPoint:(InterceptionPoint)time block:(InterceptionBlock)block;

/*!  @method invokeOriginalMethod:
   @abstract Override point for subclassers to implement different invoking behavior
*/
- (void) invokeOriginalMethod:(NSInvocation*)anInvocation;

@end

// Ready made cubclasses.

@interface  AOPMethodLogger : AOPProxy              @end
@interface AOPThreadInvoker : AOPProxy

- (id) initWithInstance:(id)x thread:(NSThread*)t;  @end

