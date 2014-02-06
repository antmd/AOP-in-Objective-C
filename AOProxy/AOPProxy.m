
/***  AOPProxy.m  InnoliFoundation  Created by Szilveszter Molnar on 1/7/11.  Copyright 2011 Innoli Kft. All rights reserved. */

#import "AOPProxy.h"
#import <objc/message.h>

@interface       AOPInterceptorInfo : NSObject
@property (unsafe_unretained)    id   interceptorTarget;
@property (copy)  InterceptionBlock   block;
@property         InterceptionPoint   point;
@property                       SEL   interceptedSelector,
                                      interceptorSelector;
+ (instancetype) forSelector:(SEL)interceptedSel  target:(id)target
                withSelector:(SEL)interceptorSel atPoint:(InterceptionPoint)point
                                                   block:(InterceptionBlock)block;
@end

@implementation AOPProxy { NSMutableArray * methodInterceptors; } @synthesize proxiedObject = _proxiedObject;

-   (id)                   initWithObject:(id)obj     {

  return _proxiedObject = obj, methodInterceptors = @[].mutableCopy, self ?: nil;
}
+   (id)                  proxyWithObject:(id)obj     { return [self.alloc initWithObject:obj];   }
+   (id)                   proxyWithClass:(Class)cls  { return [self proxyWithObject:[cls new]];  }

- (BOOL)                    isKindOfClass:(Class)cls;     { return [_proxiedObject isKindOfClass:cls];      }
- (BOOL)               conformsToProtocol:(Protocol*)prt  { return [_proxiedObject conformsToProtocol:prt]; }
- (BOOL)               respondsToSelector:(SEL)sel        { return [_proxiedObject respondsToSelector:sel]; }

- (void)             invokeOriginalMethod:(NSInvocation*)inv { [inv invoke]; }
- (void)                forwardInvocation:(NSInvocation*)inv {

  if (![_proxiedObject respondsToSelector:inv.selector]) return;   // check if the parent object responds to the selector ...
  inv.target = _proxiedObject;

  void (^invokeSelectors)(NSArray*,InterceptionPoint) = ^(NSArray*interceptors,InterceptionPoint time){

    @autoreleasepool {  NSPredicate *pointPred = [NSPredicate predicateWithFormat:@"point == %@", @(time)];

      for (AOPInterceptorInfo *oneInfo in [interceptors filteredArrayUsingPredicate:pointPred])
        (oneInfo.block) ? oneInfo.block(inv,oneInfo.point)  // first search for this selector ...
                        : (void)objc_msgSend(oneInfo.interceptorTarget, oneInfo.interceptorSelector, inv);
    }
  };

  NSArray *sameSels = [methodInterceptors filteredArrayUsingPredicate: // Match only items with same selector!
                                      [NSPredicate predicateWithBlock:^BOOL(id info, NSDictionary *x) {
      return ((AOPInterceptorInfo*)info).interceptedSelector == inv.selector;
  }]];

  invokeSelectors (sameSels, InterceptPointStart);    // Intercept the starting of the method.

  [self invokeOriginalMethod:inv];                               // Invoke the original method ...

  invokeSelectors (sameSels, InterceptPointEnd);
}

- (NSMethodSignature*) methodSignatureForSelector:(SEL)sel   { return [_proxiedObject methodSignatureForSelector:sel]; }

- (void)       interceptMethodForSelector:(SEL)sel
                         interceptorPoint:(InterceptionPoint)time
                                    block:(InterceptionBlock)block {

  NSParameterAssert(block != NULL);                     // make sure the target is not nil
  [methodInterceptors addObject:[AOPInterceptorInfo forSelector:sel  target:NULL
                                                  withSelector:NULL atPoint:time block:block]];
}
- (void)  interceptMethodStartForSelector:(SEL)sel
                    withInterceptorTarget:(id)target
                      interceptorSelector:(SEL)selector            {

  NSParameterAssert(target != nil);                               // make sure the target is not nil
  [methodInterceptors addObject:
    [AOPInterceptorInfo forSelector:sel target:target             // create the interceptorInfo + add to our list
                       withSelector:selector atPoint:InterceptPointStart block:NULL]];

}
- (void)    interceptMethodEndForSelector:(SEL)sel
                    withInterceptorTarget:(id)target
                      interceptorSelector:(SEL)selector            {

  NSParameterAssert(target != nil);                   // make sure the target is not nil

  [methodInterceptors addObject:
    [AOPInterceptorInfo forSelector:sel target:target             // create the interceptorInfo + add to our list
                       withSelector:selector atPoint:InterceptPointEnd block:NULL]];
}
@end

@implementation AOPInterceptorInfo
+ (instancetype) forSelector:(SEL)interceptedSel  target:(id)target
                withSelector:(SEL)interceptorSel atPoint:(InterceptionPoint)point
                                                   block:(InterceptionBlock)block {
  AOPInterceptorInfo * x  = self.new;
  x.point                 = point;
  x.interceptedSelector   = interceptedSel;
  if (target)         x.interceptorTarget   = target;
  if (interceptorSel) x.interceptorSelector = interceptorSel;
  if (block)          x.block               = block;
  return x;
}
@end
