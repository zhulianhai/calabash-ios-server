#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


//
//  LPQueryOperationTest.m
//  calabash
//
//  Created by Chris Fuentes on 6/11/15.
//  Copyright (c) 2015 Xamarin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LPQueryOperation.h"

#define FOO_RET_VAL @"foo"
#define FOO_BAR_RET_VAL @"foobar_ret"

@interface UIView (QueryOpTest)
- (id)foo:(id)one;
- (id)foo:(id)one bar:(id)two;
@end

@implementation UIView(QueryOpTest)
- (id)foo:(id)one             { return FOO_RET_VAL; }
- (id)foo:(id)one bar:(id)two { return FOO_BAR_RET_VAL; }
@end

@interface LPQueryOperationTest : XCTestCase
@end

@implementation LPQueryOperationTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSingleArgOperation {
  LPQueryOperation *queryOp = [LPQueryOperation operationFromDictionary:@{ @"arguments" : @[
                                                                               @{
                                                                                 @"foo" : @0
                                                                                 }
                                                                               ],
                                                                           @"method_name" : @"query"
                                                                           }];
  UIView *v = [UIView new];
  NSError *e;
  id res = [queryOp performWithTarget:v error:&e];
  XCTAssertEqualObjects(res, FOO_RET_VAL);
}

- (void)testMultiArgOperation {
  LPQueryOperation *queryOp = [LPQueryOperation operationFromDictionary:@{ @"arguments" : @[
                                                                     @{
                                                                       @"foo" : @0
                                                                       },
                                                                     @{
                                                                       @"bar" : @0
                                                                       }
                                                                     ],
                                                                           @"method_name" : @"query"
                                                                 }];
  UIView *v = [UIView new];
  NSError *e;
  id res = [queryOp performWithTarget:v error:&e];
  XCTAssertEqualObjects(res, FOO_BAR_RET_VAL);
}


@end
