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

- (void)testAsyncCall {

  //If R_CStackLimit is enabled - this will fail and crash
  //check in Rinit.m
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    RCEngine* mainEngine = [RCEngine GetInstance];
    RCSymbolicExpression* rse = [mainEngine Evaluate: @"n = c(1,2)\n s=c('a','b')\n ls = list(n, s)"];
    RCVector* list = [rse AsList];
    XCTAssertNotNil(list);
    XCTAssertNotNil([list ElementAt:0]);
    XCTAssertNotNil([list ElementAt:1]);
    [list release];
    [rse release];
  });
}


@end
