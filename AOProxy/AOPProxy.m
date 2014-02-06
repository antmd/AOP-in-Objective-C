
/***  AOPProxy.m  InnoliFoundation  Created by Szilveszter Molnar on 1/7/11.  Copyright 2011 Innoli Kft. All rights reserved. */

#import "AOPProxy.h"

@interface AOPInterceptorInfo : NSObject
@property (unsafe_unretained) id interceptorTarget;
@property SEL interceptedSelector,
              interceptorSelector;
@property InterceptionPoint point;
@property (copy) InterceptionBlock block;
@end

@implementation AOPProxy { id parentObj;  NSMutableArray *methodInterceptors; }

-   (id) initWithObject:    (id)obj         {

  parentObj          = obj;
  methodInterceptors = @[].mutableCopy;
  return self;
}
+   (id) instanceOfClass:   (Class)cls      {   // create a new instance of the specified class

  return [self.alloc initWithObject:[cls new]] ?: nil;     // invoke my designated initializer
}
- (BOOL) isKindOfClass:     (Class)cls;     { return [parentObj isKindOfClass:cls];        }
- (BOOL) conformsToProtocol:(Protocol*)prt  { return [parentObj conformsToProtocol:prt]; }
- (BOOL) respondsToSelector:(SEL)sel        { return [parentObj respondsToSelector:sel];   }

- (void) interceptMethodForSelector:(SEL)sel interceptorPoint:(InterceptionPoint)time block:(InterceptionBlock)block {

  NSParameterAssert(block != NULL);                   // make sure the target is not nil

  AOPInterceptorInfo *info = AOPInterceptorInfo.new;  // create the interceptorInfo
  info.interceptedSelector = sel;
  info.interceptorTarget   = NULL;
  info.point               = time;
  info.block               = block;
  [methodInterceptors addObject:info];           // add to our list

}

- (void) interceptMethodStartForSelector:(SEL)sel withInterceptorTarget:(id)target interceptorSelector:(SEL)selector {

  NSParameterAssert(target != nil);                   // make sure the target is not nil

  AOPInterceptorInfo *info = AOPInterceptorInfo.new;  // create the interceptorInfo
  info.interceptedSelector = sel;
  info.interceptorTarget   = target;
  info.interceptorSelector = selector;
  info.point               = InterceptPointStart;
  [methodInterceptors addObject:info];           // add to our list
}
- (void) interceptMethodEndForSelector:  (SEL)sel withInterceptorTarget:(id)target interceptorSelector:(SEL)selector {

  NSParameterAssert(target != nil);                   // make sure the target is not nil

  AOPInterceptorInfo *info  = AOPInterceptorInfo.new; // create the interceptorInfo
  info.interceptedSelector  = sel;
  info.interceptorTarget    = target;
  info.interceptorSelector  = selector;
  info.point                = InterceptPointEnd;
  [methodInterceptors addObject:info];             // add to our list
}
- (void) invokeOriginalMethod:(NSInvocation*)inv           { [inv invoke]; }
- (void) forwardInvocation:   (NSInvocation*)inv           {

  SEL aSelector = inv.selector;
  if (![parentObj respondsToSelector:aSelector]) return;   // check if the parent object responds to the selector ...
  inv.target = parentObj;

  void (^invokeSelectors)(NSArray*) = ^(NSArray*interceptors){ @autoreleasepool {
    // Intercept the start/end of the method, depending on passed array.
    [interceptors enumerateObjectsUsingBlock:^(AOPInterceptorInfo *oneInfo, NSUInteger idx, BOOL *stop) {
                       // first search for this selector ...
        if (oneInfo.block)
          return  oneInfo.block(inv,oneInfo.point);
//      if (oneInfo.interceptedSelector != aSelector) return;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

      [(NSObject*)oneInfo.interceptorTarget performSelector:oneInfo.interceptorSelector withObject:inv];

#pragma clang diagnostic pop
      }];
    }
  };

  NSArray *sameSelectors =  [methodInterceptors filteredArrayUsingPredicate: // Match only items with same selector!
                            [NSPredicate predicateWithBlock:^BOOL(AOPInterceptorInfo*info, NSDictionary *x) {
                              return info.interceptedSelector == aSelector;  }]];

  invokeSelectors([sameSelectors filteredArrayUsingPredicate:    // Intercept the starting of the method.
                            [NSPredicate predicateWithFormat:@"point == %@", @(InterceptPointStart)]]);

  [self invokeOriginalMethod:inv];                               // Invoke the original method ...

  invokeSelectors([sameSelectors filteredArrayUsingPredicate:    // Intercept the ending of the method.
                            [NSPredicate predicateWithFormat:@"point == %@", @(InterceptPointEnd)]]);

  //	else { [super forwardInvocation:invocation]; }
}
- (NSMethodSignature*) methodSignatureForSelector:(SEL)sel { return [parentObj methodSignatureForSelector:sel]; }

@end

@implementation AOPInterceptorInfo @end
