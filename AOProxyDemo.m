
/***  AOProxyDemo.m  AOProxy  Created by Szilveszter Molnar on 1/9/11. Copyright 2011 Innoli Kft. All rights reserved. */

#import <AOPProxy.h>

@interface  AOPLibTest : NSObject + (void) testAOP:(AOPProxy*)proxy; @end

int main(int c, char *v[]) { @autoreleasepool {

  printf("Normal proxy test (No implicit log)\n-----------------------------------\n");
  [AOPLibTest testAOP:[AOPProxy        instanceOfClass:NSMutableArray.class]];
  printf("\nLogging proxy test (Has inherent log)\n-------------------------------------\n");
  [AOPLibTest testAOP:[AOPMethodLogger instanceOfClass:NSMutableArray.class]];

} return EXIT_SUCCESS; }

@implementation AOPLibTest

+ (void) addInterceptor:   (NSInvocation*)i { printInvocation(i, InterceptPointStart); }
+ (void) removeInterceptor:(NSInvocation*)i { printInvocation(i, InterceptPointEnd);   }
+ (void) testAOP:          (AOPProxy*)proxy {

  [proxy interceptMethodStartForSelector:@selector(addObject:)
                   withInterceptorTarget:self
                     interceptorSelector:@selector(addInterceptor:)];

  [proxy   interceptMethodEndForSelector:@selector(removeObjectAtIndex:)
                   withInterceptorTarget:self
                     interceptorSelector:@selector(removeInterceptor:)];

  [proxy      interceptMethodForSelector:@selector(count)
                        interceptorPoint:InterceptPointStart
                                   block:^(NSInvocation * i, InterceptionPoint p){ printInvocation(i,p); }];

  [(id)proxy          addObject:@1];
  [(id)proxy removeObjectAtIndex:0];
  [(id)proxy                 count];
}

void printInvocation(NSInvocation*i, InterceptionPoint p) { // Logger

  printf("%s -[__NSArrayM %s] intercepted with custom interceptor!\n",
                          p == InterceptPointStart ? "START" :"  END",
                          NSStringFromSelector(i.selector).UTF8String);
}

@end

