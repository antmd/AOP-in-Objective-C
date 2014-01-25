
//  AOPProxy.m  InnoliFoundation
//  Created by Szilveszter Molnar on 1/7/11.  Copyright 2011 Innoli Kft. All rights reserved.

#import "AOPProxy.h"

@interface AOPInterceptorInfo : NSObject
@property (unsafe_unretained) id interceptorTarget;
@property SEL interceptedSelector,
              interceptorSelector;
@end

@implementation AOPProxy { id parentObj;  NSMutableArray *methodStartInterceptors, *methodEndInterceptors; }

-   (id) initWithObject:    (id)obj         {

  parentObj               = obj;
  methodStartInterceptors = NSMutableArray.new;
  methodEndInterceptors   = NSMutableArray.new;    return self;
}
+   (id) instanceOfClass:   (Class)cls      {   // create a new instance of the specified class

  return [self.alloc initWithObject:[cls new]] ?: nil;     // invoke my designated initializer
}
- (BOOL) isKindOfClass:     (Class)cls;     { return [parentObj isKindOfClass:cls];        }
- (BOOL) conformsToProtocol:(Protocol*)prt  { return [parentObj conformsToProtocol:prt]; }
- (BOOL) respondsToSelector:(SEL)sel        { return [parentObj respondsToSelector:sel];   }

- (NSMethodSignature*) methodSignatureForSelector:(SEL)sel { return [parentObj methodSignatureForSelector:sel]; }

- (void)interceptMethodStartForSelector:(SEL)sel withInterceptorTarget:(id)target interceptorSelector:(SEL)selector {

  NSParameterAssert(target != nil);                   // make sure the target is not nil

  AOPInterceptorInfo *info = AOPInterceptorInfo.new;  // create the interceptorInfo
  info.interceptedSelector = sel;
  info.interceptorTarget   = target;
  info.interceptorSelector = selector;
  [methodStartInterceptors addObject:info];           // add to our list
}

- (void)interceptMethodEndForSelector:(SEL)sel withInterceptorTarget:(id)target interceptorSelector:(SEL)selector {

  NSParameterAssert(target != nil);                   // make sure the target is not nil

  AOPInterceptorInfo *info  = AOPInterceptorInfo.new; // create the interceptorInfo
  info.interceptedSelector  = sel;
  info.interceptorTarget    = target;
  info.interceptorSelector  = selector;
  [methodEndInterceptors addObject:info];             // add to our list
}

- (void)invokeOriginalMethod:(NSInvocation *)inv { [inv invoke]; }

- (void)forwardInvocation:(NSInvocation *)inv {

  SEL aSelector = inv.selector;
  if (![parentObj respondsToSelector:aSelector]) return;   // check if the parent object responds to the selector ...
  inv.target = parentObj;

  void (^invokeSelectors)(NSArray*) = ^(NSArray*interceptors){ @autoreleasepool {
    // Intercept the start/end of the method, depending on passed array.
    [interceptors enumerateObjectsUsingBlock:^(AOPInterceptorInfo *oneInfo, NSUInteger idx, BOOL *stop) {
      if (oneInfo.interceptedSelector != aSelector) return;                 // first search for this selector ...

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

      [(NSObject*)oneInfo.interceptorTarget performSelector:oneInfo.interceptorSelector withObject:inv];

#pragma clang diagnostic pop
      }];
    }
  };

  // Intercept the starting of the method.
  invokeSelectors(methodStartInterceptors);
  // Invoke the original method ...
  [self invokeOriginalMethod:inv];
   // Intercept the ending of the method.
  invokeSelectors(methodEndInterceptors);
  //	else { [super forwardInvocation:invocation]; }
}

@end

@implementation AOPInterceptorInfo @end
