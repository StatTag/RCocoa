//
//  RCTestAsync.m
//  RCocoa
//
//  Created by Eric Whitley on 7/3/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "RCocoa.h"

@interface RCTestAsync : XCTestCase

@end

@implementation RCTestAsync

- (void)setUp {
  [super setUp];
  [[RCEngine mainEngine] activate];

    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAsyncCall {

  //If R_CStackLimit is enabled - this will fail and crash
  //check in Rinit.m
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    RCSymbolicExpression* rse = [[RCEngine mainEngine] Evaluate: @"n = c(1,2)\n s=c('a','b')\n ls = list(n, s)"];
    RCVector* list = [rse AsList];
    XCTAssertNotNil(list);
    XCTAssertNotNil([list ElementAt:0]);
    XCTAssertNotNil([list ElementAt:1]);
    [list release];
    [rse release];
  });
}


@end
