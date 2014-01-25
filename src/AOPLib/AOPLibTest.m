
//  AOPLibTest.m  AOPLib
//  Created by Szilveszter Molnar on 1/9/11. Copyright 2011 Innoli Kft. All rights reserved.

#import "AOPProxy.h"

@interface      AOPLibTest : NSObject @end
@implementation AOPLibTest

- (void) addInterceptor:   (NSInvocation*)i { NSLog(@"ADD intercepted.");         }
- (void) removeInterceptor:(NSInvocation*)i { NSLog(@"REMOVE END intercepted !"); }
- (void) testAOP {

  AOPProxy *testArray = [AOPProxy.alloc initWithNewInstanceOfClass:NSMutableArray.class];

  [testArray interceptMethodStartForSelector:@selector(addObject:)
                                     withInterceptorTarget:self
                                       interceptorSelector:@selector(addInterceptor:)];

  [testArray interceptMethodEndForSelector:@selector(removeObjectAtIndex:)
                                   withInterceptorTarget:self
                                     interceptorSelector:@selector(removeInterceptor:)];

  [(NSMutableArray*)testArray addObject:@1];
  [(NSMutableArray*)testArray removeObjectAtIndex:0];
}

@end

int main(int argc, const char *argv[])
{
    @autoreleasepool
    {
        [AOPLibTest.new testAOP];
    }
    return 0;
}
