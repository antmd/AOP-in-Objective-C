
#import <SenTestingKit/SenTestingKit.h>
#import "AOPProxy.h"

@interface AOPProxyTests : SenTestCase
@property AOPProxy * proxy;
@property NSMutableString *testString;
@end

@implementation AOPProxyTests

- (void)setUp
{
    [super setUp];
    _testString = @"apple".mutableCopy;
    _proxy = [AOPProxy proxyWithObject:_testString];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown { [super tearDown]; }

- (void)testInvocationBlock {

  STAssertEquals  ([_proxy proxiedObject], _testString, @"proxied object should equal our s†ring");
  STAssertTrue    (_testString.length == 5,             @"test string should start out with length of 5. it is %lu", _testString.length);
  [_proxy interceptMethodForSelector:@selector(length)
                    interceptorPoint:InterceptPointEnd
                               block:^(NSInvocation * i, InterceptionPoint p){


    STAssertNotNil(i,                                                         @"Invocation Should exist");



    STAssertTrue  (p == InterceptPointEnd,                                    @"insertion poin† should be at end!");
    STAssertTrue  ([i.target isEqual:_testString],                            @"invocation target should be our string!");
    NSString *selStr = NSStringFromSelector(i.selector);
    STAssertTrue  ([selStr isEqualToString:@"length"],                        @"selector should be 'length'");
    STAssertTrue  ([[i.target valueForKey:selStr]unsignedIntegerValue] == 10, @"length should be 10, now.");
  }];

  [(id)_proxy appendString:@"farts"];
  NSUInteger length = [(id)_proxy length];
  STAssertTrue(length == 10, @"length should be 10, now.");
}

@end
