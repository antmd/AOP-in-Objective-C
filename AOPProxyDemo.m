
/***  AOPProxyDemo.m  AOPProxy  Created by Szilveszter Molnar on 1/9/11. Copyright 2011 Innoli Kft. All rights reserved. */

#import <AOPProxy.h>

@interface    AOPProxyDemo : NSObject  + (void) testProxy:(id)proxy;
@property   NSMutableArray * strongProperty;
@property               id   proxy;
@end

int main(int c, char *v[]) { @autoreleasepool {

  printf("Normal proxy test (No implicit log)\n-----------------------------------\n");
  [AOPProxyDemo testProxy:[AOPProxy       proxyWithObject:NSMutableArray.new]];
  printf("\nLogging proxy test (Has inherent log)\n-------------------------------------\n");
  [AOPProxyDemo testProxy:[AOPMethodLogger proxyWithClass:NSMutableArray.class]];

} return EXIT_SUCCESS; }

@implementation AOPProxyDemo static AOPProxyDemo *retainer;

-   (id) init { return self = super.init ?

  [ _proxy = [AOPMethodLogger proxyWithObject:_strongProperty = NSMutableArray.new]
                  interceptMethodForSelector:@selector(addObjectsFromArray:)
                            interceptorPoint:InterceptPointEnd
                                       block:^(NSInvocation *inv, InterceptionPoint intPt) {
    printInvocation(inv, intPt);

  }], self : nil;
}

+ (void) addInterceptor:   (NSInvocation*)i { printInvocation(i, InterceptPointStart); }
+ (void) removeInterceptor:(NSInvocation*)i { printInvocation(i, InterceptPointEnd);   }
+ (void) testProxy:        (id)proxy        {

  [proxy interceptMethodStartForSelector:@selector(addObject:)
                   withInterceptorTarget:self
                     interceptorSelector:@selector(addInterceptor:)];

  [proxy   interceptMethodEndForSelector:@selector(removeObjectAtIndex:)
                   withInterceptorTarget:self
                     interceptorSelector:@selector(removeInterceptor:)];

  [proxy      interceptMethodForSelector:@selector(count)
                        interceptorPoint:InterceptPointStart
                                   block:^(NSInvocation * i, InterceptionPoint p){ printInvocation(i,p); }];

  retainer = retainer ?: self.new;

  [(id)proxy                      addObject:@1];
  [(id)proxy             removeObjectAtIndex:0];
  [(id)proxy                             count];
  [retainer.proxy addObjectsFromArray:@[@2,@3]];
}

void printInvocation(NSInvocation*i, InterceptionPoint p) { // Logger

  printf("%s -[__NSArrayM %s] intercepted with custom interceptor!\n",
                          p == InterceptPointStart ? "START" :"  END",
                          NSStringFromSelector(i.selector).UTF8String);
}

@end

