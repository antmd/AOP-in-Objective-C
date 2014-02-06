
//  AOPLibTest.m  AOPLib
//  Created by Szilveszter Molnar on 1/9/11. Copyright 2011 Innoli Kft. All rights reserved.

#import "AOPProxy.h"

@interface      AOPLibTest : NSObject @end
@implementation AOPLibTest

+ (void) addInterceptor:   (NSInvocation*)i { printf("%s START intercepted with custom interceptor!\n", NSStringFromSelector(i.selector).UTF8String);         }
+ (void) removeInterceptor:(NSInvocation*)i { printf("%s END   intercepted with custom interceptor!\n", NSStringFromSelector(i.selector).UTF8String); }

+ (void) testAOP:(AOPProxy*)proxy {

  [proxy interceptMethodStartForSelector:@selector(addObject:)
                   withInterceptorTarget:self
                     interceptorSelector:@selector(addInterceptor:)];

  [proxy interceptMethodEndForSelector:@selector(removeObjectAtIndex:)
                 withInterceptorTarget:self
                   interceptorSelector:@selector(removeInterceptor:)];

  [proxy interceptMethodForSelector:@selector(count)
                   interceptorPoint:InterceptPointStart
                              block:^(NSInvocation *i, InterceptionPoint p) {

      printf("**%s %s intercepted with custom interceptor!\n", NSStringFromSelector(i.selector).UTF8String,
                                                              (p == InterceptPointStart ?@"START" :@"  END").UTF8String);
  }];

  [(NSMutableArray*)proxy addObject:@1];
  [(NSMutableArray*)proxy removeObjectAtIndex:0];
  [(NSArray*)proxy count];
}

@end

int main(int argc, const char *argv[])
{
    @autoreleasepool
    {
      printf("Normal proxy test (No implicit log)\n------------------------------\n");
        [AOPLibTest testAOP:[AOPProxy instanceOfClass:NSMutableArray.class]];
      printf("\nLogging proxy test (Has inherent log)\n------------------------------\n");
        [AOPLibTest testAOP:[AOPMethodLogger instanceOfClass:NSMutableArray.class]];

    }
    return 0;
}
