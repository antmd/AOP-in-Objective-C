AOPProxy
====

#### An _Aspect-Oriented proxy library_ written `Objective-C` (for iOS + OSX)

[![Build Status](https://travis-ci.org/mralexgray/AOP-in-Objective-C.png?branch=travis+coveralls)](https://travis-ci.org/mralexgray/AOP-in-Objective-C)  

[![Coverage Status](https://coveralls.io/repos/mralexgray/AOP-in-Objective-C/badge.png?branch=travis%2Bcoveralls)](https://coveralls.io/r/mralexgray/AOP-in-Objective-C?branch=travis%2Bcoveralls)

This library enables functionality similar to AOP or _Aspect Oriented Programming_ - for Objective-C.
Proxy classes can be created (by wrapping the original instances in an instance of AOPProxy) that
enable *intercepting the beginning and the end of method invocations*!

It also provides two other classes, `AOPMethodLogger` and `AOPThreadInvoker`.

• `AOPMethodLogger` will log automatically all method invocations for an object.

• `AOPThreadInvoker` will make sure that no matter what thread is used to invoke the methods on your object they will always be executed on a specified thread.

If you use this library I would be happy to hear about it :) – so please drop a mail to Szilveszter Molnar ( moszi@innoli.com ).

A simple example...

```objective-c
- (void) addInterceptor:   (NSInvocation*)i { NSLog(@"ADD intercepted.");        }

- (void) removeInterceptor:(NSInvocation*)i { NSLog(@"REMOVE END intercepted!"); }

- (void) testAOP {
 
    NSMutableArray* testArray = [AOPProxy proxyWithClass:NSMutableArray.class];
    
    [(id)testArray interceptMethodStartForSelector:@selector(addObject:)
                             withInterceptorTarget:self
                               interceptorSelector:@selector( addInterceptor: )];
    
    [(id)testArray interceptMethodEndForSelector:@selector(removeObjectAtIndex:)
                           withInterceptorTarget:self
                             interceptorSelector:@selector( removeInterceptor: )];
    
    [testArray addObject:@(1)];
    [testArray removeObjectAtIndex:0];
}
```
