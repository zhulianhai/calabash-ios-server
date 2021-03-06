#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "InvokerFactory.h"
#import "LPInvoker.h"
#import "LPInvocationError.h"
#import <CoreLocation/CoreLocation.h>

@interface LPInvoker (LPXCTTEST)

- (id) resultByCoercingReturnValue;
- (BOOL) selectorReturnValueCanBeCoerced;

@end

@interface LPInvokerObjectByCoercingReturnValueTest : XCTestCase

@end

@implementation LPInvokerObjectByCoercingReturnValueTest

#pragma mark - Mocking

- (id) expectInvokerEncoding:(NSString *) mockEncoding {
  LPInvoker *invoker = [[LPInvoker alloc] initWithSelector:@selector(length)
                                                    target:@"string"];
  id mock = [OCMockObject partialMockForObject:invoker];
  [[[mock expect] andReturn:mockEncoding] encodingForSelectorReturnType];
  return mock;
}


- (id) stubInvokerEncoding:(NSString *) mockEncoding {
  LPInvoker *invoker = [[LPInvoker alloc] initWithSelector:@selector(length)
                                                    target:@"string"];
  id mock = [OCMockObject partialMockForObject:invoker];
  [[[mock stub] andReturn:mockEncoding] encodingForSelectorReturnType];
  return mock;
}

- (id) stubInvokerDoesNotRespondToSelector {
  LPInvoker *invoker = [[LPInvoker alloc] initWithSelector:@selector(length)
                                                    target:@"string"];
  id mock = [OCMockObject partialMockForObject:invoker];
  BOOL falsey = NO;
  [[[mock stub] andReturnValue:OCMOCK_VALUE(falsey)] targetRespondsToSelector];
  return mock;
}

#pragma mark - Tests

- (void) testObjectByCoercingReturnValueDoesNotRespondToSelector {
  id mock = [self stubInvokerDoesNotRespondToSelector];
  LPInvocationResult *result = [mock resultByCoercingReturnValue];
  XCTAssertEqualObjects([result description], LPTargetDoesNotRespondToSelector);
  [mock verify];
}

- (void) testObjectByCoercingReturnValueNotAutoboxable {
  LPInvoker *invoker = [[LPInvoker alloc] initWithSelector:@selector(length)
                                                    target:@"string"];
  id mock = [OCMockObject partialMockForObject:invoker];
  BOOL falsey = NO;
  [[[mock expect] andReturnValue:OCMOCK_VALUE(falsey)] selectorReturnValueCanBeCoerced];
  LPInvocationResult *result = [mock resultByCoercingReturnValue];
  XCTAssertEqualObjects([result description], LPCannotCoerceSelectorReturnValueToObject);
  [mock verify];
}

- (void) testObjectByCoercingReturnValueUnexpectedEncoding {
  // space is intential; don't want first char to match
  NSString *encoding = @" unexpected encoding";
  id mock = [self expectInvokerEncoding:encoding];
  LPInvocationResult *result = [mock resultByCoercingReturnValue];
  XCTAssertEqualObjects([result description], LPSelectorHasUnknownReturnTypeEncoding);
  [mock verify];
}

- (void) testObjectByCoercingReturnValueInvalidEncoding {
  NSString *encoding = @"";
  id mock = [self expectInvokerEncoding:encoding];
  LPInvocationResult *result = [mock resultByCoercingReturnValue];
  XCTAssertEqualObjects([result description], LPSelectorHasUnknownReturnTypeEncoding);
  [mock verify];
}

- (void) testObjectByCoercingReturnValueConstCharStar {
  LPInvoker *invoker = [InvokerFactory invokerWithSelectorReturnValue:@"const char *"];
  LPInvocationResult *result = [invoker resultByCoercingReturnValue];
  id value = result.value;
  XCTAssertEqualObjects(value, @"const char *");
}

- (void) testObjectByCoercingReturnValueCharStar {
  LPInvoker *invoker = [InvokerFactory invokerWithSelectorReturnValue:@"char *"];
  LPInvocationResult *result = [invoker resultByCoercingReturnValue];
  id value = result.value;
  XCTAssertEqualObjects(value, @"char *");
}

- (void) testObjectByCoercingReturnValueChar {
  LPInvoker *invoker = [InvokerFactory invokerWithSelectorReturnValue:@"char"];
  LPInvocationResult *result = [invoker resultByCoercingReturnValue];
  id value = result.value;
  XCTAssertEqualObjects(value, @"c");
}

- (void) testObjectByCoercingReturnValueUnsignedChar {
  LPInvoker *invoker = [InvokerFactory invokerWithSelectorReturnValue:@"unsigned char"];
  LPInvocationResult *result = [invoker resultByCoercingReturnValue];
  id value = result.value;
  XCTAssertEqualObjects(value, @"C");
}

- (void) testObjectByCoercingReturnValueBool {
  LPInvoker *invoker = [InvokerFactory invokerWithSelectorReturnValue:@"bool true"];
  LPInvocationResult *result = [invoker resultByCoercingReturnValue];
  id value = result.value;
  XCTAssertEqual([value boolValue], YES);

  invoker = [InvokerFactory invokerWithSelectorReturnValue:@"bool false"];
  result =  [invoker resultByCoercingReturnValue];
  value = result.value;
  XCTAssertEqual([value boolValue], NO);
}

- (void) testObjectByCoercingReturnValueBOOL {
  LPInvoker *invoker = [InvokerFactory invokerWithSelectorReturnValue:@"BOOL YES"];
  LPInvocationResult *result = [invoker resultByCoercingReturnValue];
  id value = result.value;
  XCTAssertEqual([value boolValue], YES);

  invoker = [InvokerFactory invokerWithSelectorReturnValue:@"BOOL NO"];
  result =  [invoker resultByCoercingReturnValue];
  value = result.value;
  XCTAssertEqual([value boolValue], NO);
}

- (void) testObjectByCoercingReturnValueInteger {
  LPInvoker *invoker = [InvokerFactory invokerWithSelectorReturnValue:@"NSInteger"];
  LPInvocationResult *result = [invoker resultByCoercingReturnValue];
  id value = result.value;
  XCTAssertEqual([value integerValue], NSIntegerMin);

  invoker = [InvokerFactory invokerWithSelectorReturnValue:@"NSUInteger"];
  result =  [invoker resultByCoercingReturnValue];
  value = result.value;
  XCTAssertEqual([value unsignedIntegerValue], NSNotFound);
}

- (void) testObjectByCoercingReturnValueShort {
  LPInvoker *invoker = [InvokerFactory invokerWithSelectorReturnValue:@"short"];
  LPInvocationResult *result = [invoker resultByCoercingReturnValue];
  id value = result.value;
  XCTAssertEqual([value shortValue], SHRT_MIN);

  invoker = [InvokerFactory invokerWithSelectorReturnValue:@"unsigned short"];
  result =  [invoker resultByCoercingReturnValue];
  value = result.value;
  XCTAssertEqual([value unsignedShortValue], SHRT_MAX);
}

- (void) testObjectByCoercingReturnValueDouble {
  LPInvoker *invoker = [InvokerFactory invokerWithSelectorReturnValue:@"double"];
  LPInvocationResult *result = [invoker resultByCoercingReturnValue];
  id value = result.value;
  XCTAssertEqual([value doubleValue], DBL_MAX);
}

- (void) testObjectByCoercingReturnValueFloat {
  LPInvoker *invoker = [InvokerFactory invokerWithSelectorReturnValue:@"float"];
  LPInvocationResult *result = [invoker resultByCoercingReturnValue];
  id value = result.value;
  XCTAssertEqual([value floatValue], MAXFLOAT);
}

- (void) testObjectByCoercingReturnValueLong {
  LPInvoker *invoker = [InvokerFactory invokerWithSelectorReturnValue:@"long"];
  LPInvocationResult *result = [invoker resultByCoercingReturnValue];
  id value = result.value;
  XCTAssertEqual([value longValue], LONG_MIN);

  invoker = [InvokerFactory invokerWithSelectorReturnValue:@"unsigned long"];
  result =  [invoker resultByCoercingReturnValue];
  value = result.value;
  XCTAssertEqual([value unsignedLongValue], ULONG_MAX);

  invoker = [InvokerFactory invokerWithSelectorReturnValue:@"long long"];
  result =  [invoker resultByCoercingReturnValue];
  value = result.value;
  XCTAssertEqual([value longLongValue], LONG_LONG_MIN);

  invoker = [InvokerFactory invokerWithSelectorReturnValue:@"unsigned long long"];
  result =  [invoker resultByCoercingReturnValue];
  value = result.value;
  XCTAssertEqual([value unsignedLongLongValue], ULONG_LONG_MAX);
}

- (void) testObjectbyCoercingStruct {
  LPInvoker *invoker = [InvokerFactory invokerWithSelectorReturnValue:@"struct"];
  LPInvocationResult *result = [invoker resultByCoercingReturnValue];
  id value = result.value;
  expect(value).to.equal(@"InvokerFactoryStruct");
}

- (void) testObjectbyCoercingClass {
  LPInvoker *invoker = [InvokerFactory invokerWithSelectorReturnValue:@"Class"];
  LPInvocationResult *result = [invoker resultByCoercingReturnValue];
  id value = result.value;
  expect(value).to.equal(@"NSArray");
}

- (void) testObjectbyCoercingCoreLocation2D {
  LPInvoker *invoker = [InvokerFactory invokerWithSelectorReturnValue:@"Location2D"];
  LPInvocationResult *result = [invoker resultByCoercingReturnValue];
  id value = result.value;

  expect([value isKindOfClass:[NSArray class]]).to.equal(YES);

  NSArray *array = (NSArray *)value;
  expect(array.count).to.equal(2);
  expect(array[0]).to.equal(@(56.17216));
  expect(array[1]).to.equal(@(10.18754));
}

- (void) testObjectByCoercingRaisesExceptionWhenInvocationIsNil {
  LPInvoker *invoker = [InvokerFactory invokerWithSelectorReturnValue:@"char"];
  id mock = OCMPartialMock(invoker);
  [[[mock expect] andReturn:nil] invocation];

  expect(^{
    [mock resultByCoercingReturnValue];
  }).to.raise(@"Calabash Server: LPInvoker");
}

@end

SpecBegin(LPInvokerObjectByCoercingReturnValue)

it(@"CGPoint", ^{
  LPInvoker *invoker = [InvokerFactory invokerWithSelectorReturnValue:@"CGPoint"];
  LPInvocationResult *result = [invoker resultByCoercingReturnValue];
  id value = result.value;

  expect([value isKindOfClass:[NSDictionary class]]).to.equal(YES);

  NSDictionary *dictionary = (NSDictionary *)value;
  expect(dictionary.count).to.equal(3);
  expect(dictionary[@"X"]).to.equal(@(17.0));
  expect(dictionary[@"Y"]).to.equal(@(42.0));
  expect(dictionary[@"description"]).to.equal(@"NSPoint: {17, 42}");
});

it(@"CGRect", ^{
  LPInvoker *invoker = [InvokerFactory invokerWithSelectorReturnValue:@"CGRect"];
  LPInvocationResult *result = [invoker resultByCoercingReturnValue];
  id value = result.value;

  expect([value isKindOfClass:[NSDictionary class]]).to.equal(YES);

  NSDictionary *dictionary = (NSDictionary *)value;
  expect(dictionary.count).to.equal(5);
  expect(dictionary[@"X"]).to.equal(@(17.0));
  expect(dictionary[@"Y"]).to.equal(@(42.0));
  expect(dictionary[@"Width"]).to.equal(@(11.0));
  expect(dictionary[@"Height"]).to.equal(@(13.0));
  expect(dictionary[@"description"]).to.equal(@"NSRect: {{17, 42}, {11, 13}}");
});


SpecEnd
