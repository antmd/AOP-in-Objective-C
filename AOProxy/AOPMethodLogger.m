
/***  AOPMethodLogger.m  InnoliFoundation Created by Szilveszter Molnar on 1/7/11.  Copyright 2011 Innoli Kft. All rights reserved. */

#import <AOPProxy.h>

@implementation AOPMethodLogger

- (void) invokeOriginalMethod:(NSInvocation*)inv {

  const char  * sels = NSStringFromSelector(inv.selector).UTF8String,
               * cls = NSStringFromClass([inv.target class]).UTF8String,
          * proxyCls = NSStringFromClass(self.class).UTF8String,
           * retType = inv.methodSignature.methodReturnType;
  NSUInteger invArgs = inv.methodSignature.numberOfArguments;

  printf("START -[%s %s] args:%ld returns:%s (%s)\n", cls, sels, invArgs, retType, proxyCls);
  [super invokeOriginalMethod:inv];
  printf("  END -[%s %s] args:%ld returns:%s (%s)\n", cls, sels, invArgs, retType, proxyCls);
}

@end
