
#import <SenTestingKit/SenTestingKit.h>
#import "AOPProxy.h"

@interface  AOPProxyTests : SenTestCase
@property        AOPProxy * proxy;
@property NSMutableString * testString;
@property              id   valueHolder;
@end

@implementation AOPProxyTests

- (void) setUp                { [super setUp];

  _testString = @"apple".mutableCopy;
       _proxy = [AOPProxy proxyWithObject:_testString];
}
- (void) testInvocationBlock  {

  STAssertEquals ( [_proxy proxiedObject], _testString, @"proxied object should equal our string");
    STAssertTrue ( _testString.length == 5,             @"test string should start out with length of 5. it is %lu", _testString.length);

  [_proxy interceptMethodForSelector:@selector(length)
                    interceptorPoint:InterceptPointEnd
                               block:^(NSInvocation * i, InterceptionPoint p){

    NSString *selStr = NSStringFromSelector(i.selector);

    STAssertNotNil ( i,                                                         @"Invocation Should exist");
      STAssertTrue ( p == InterceptPointEnd,                                    @"insertion poin† should be at end!");
      STAssertTrue ( [i.target isEqual:_testString],                            @"invocation target should be our string!");
      STAssertTrue ( [selStr isEqualToString:@"length"],                        @"selector should be 'length'");
      STAssertTrue ( [[i.target valueForKey:selStr]unsignedIntegerValue] == 10, @"length should be 10, now.");
  }];

  [(id)_proxy appendString:@"farts"];
  STAssertTrue([(id)_proxy length] == 10, @"length should be 10, now.");
}
- (void) testProxyEntryPoints {

  STAssertNil(_valueHolder, @"when this starts, valueHolder should be nil");  _valueHolder = @1;

  [_proxy interceptMethodForSelector:@selector(substringFromIndex:)
                    interceptorPoint:InterceptPointStart
                               block:^(NSInvocation * i, InterceptionPoint p){ NSUInteger index = [_valueHolder unsignedIntegerValue];

    [i setArgument:&index atIndex:2];                           /* we alter the invocation's args with our own variable's property */
    [_proxy invokeOriginalMethod:i];                            /* We call the original method with out new arguments */
    _valueHolder = @([_valueHolder unsignedIntegerValue] + 1);  /* do whatever we want, cleanup, etc */
  }];

  NSString *subString = [(NSString*)_proxy substringFromIndex:88]; /* actual args will be ignored by us inside proxy */

  NSAssert([subString isEqualToString:@"pple"], @"Substring should be \"pple\", it was %@", subString);
  NSAssert([_valueHolder unsignedIntegerValue] == 2, @"Holder should have incremented");
}
- (void) testNSObjectProxy    {

  [_testString interceptMethodForSelector:@selector(isEqualToString:)  /* here we add a proxy to an existing object */
                         interceptorPoint:InterceptPointStart
                                    block:^(NSInvocation *inv, InterceptionPoint intPt) {

    NSString *faker = @"Konnichiwa";  /* we fudge the arguements. in essence, we lie. */
    [inv setArgument:&faker atIndex:0];
    [_testString.ao_proxy invokeProxiedOriginalMethod:inv];
  }];

   STAssertTrue ( [_testString isEqualToString:@"apple"], @"Although we added proxy, original should STILL return apple.");
  STAssertFalse ( [_testString isEqualToString:@"IBM"], @"original object is NOT IBM");
  STAssertFalse ( [_testString.ao_proxy isEqualToString:@"apple"], @"Our proxy is a trickster"); /* we checked @"Konnichiwa", not apple, inside the proxy */
   STAssertTrue ( [_testString.ao_proxy isEqualToString:@"Konnichiwa"], @"Take that, bitches");

}
@end
