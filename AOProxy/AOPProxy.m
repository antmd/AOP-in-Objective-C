
/***  AOPProxy.m  InnoliFoundation  Created by Szilveszter Molnar on 1/7/11.  Copyright 2011 Innoli Kft. All rights reserved. */

#import "AOPProxy.h"

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

-           (id)           initWithObject:(id)obj     {
  return _proxiedObject = obj, methodInterceptors = @[].mutableCopy, self ?: nil;
}
+ (instancetype)          proxyWithObject:(id)obj     { return [self.class.alloc initWithObject:obj];   }
+ (instancetype)           proxyWithClass:(Class)cls  { return [self.class proxyWithObject:[cls new]];  }

- (BOOL)                    isKindOfClass:(Class)cls;     { return [_proxiedObject isKindOfClass:cls];      }
- (BOOL)               conformsToProtocol:(Protocol*)prt  { return [_proxiedObject conformsToProtocol:prt]; }
- (BOOL)               respondsToSelector:(SEL)sel        { return [_proxiedObject respondsToSelector:sel]; }

- (void)             invokeOriginalMethod:(NSInvocation*)inv { [inv invoke]; }
- (void)                forwardInvocation:(NSInvocation*)inv {

  SEL aSel = inv.selector;
  if (![_proxiedObject respondsToSelector:aSel]) return;   // check if the parent object responds to the selector ...
  inv.target = _proxiedObject;

  void (^invokeSelectors)(NSArray*) = ^(NSArray*interceptors){ @autoreleasepool {
    // Intercept the start/end of the method, depending on passed array.
    [interceptors enumerateObjectsUsingBlock:^(AOPInterceptorInfo *oneInfo, NSUInteger idx, BOOL *stop) {

      if (oneInfo.block) return oneInfo.block(inv,oneInfo.point);  // first search for this selector ...
//    if (oneInfo.interceptedSelector != aSelector) return;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

      [(NSObject*)oneInfo.interceptorTarget performSelector:oneInfo.interceptorSelector withObject:inv];

#pragma clang diagnostic pop
      }];
    }
  };

  NSArray *sameSelectors =  [methodInterceptors filteredArrayUsingPredicate: // Match only items with same selector!
                            [NSPredicate predicateWithBlock:^BOOL(AOPInterceptorInfo*info, NSDictionary *x) {
                              return info.interceptedSelector == aSel;  }]];

  invokeSelectors([sameSelectors filteredArrayUsingPredicate:    // Intercept the starting of the method.
                            [NSPredicate predicateWithFormat:@"point == %@", @(InterceptPointStart)]]);

  [self invokeOriginalMethod:inv];                               // Invoke the original method ...

  invokeSelectors([sameSelectors filteredArrayUsingPredicate:    // Intercept the ending of the method.
                            [NSPredicate predicateWithFormat:@"point == %@", @(InterceptPointEnd)]]);

  //	else { [super forwardInvocation:invocation]; }
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
