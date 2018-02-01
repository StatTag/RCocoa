//
//  RCCharacterMatrixTests.m
//  RCocoa
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "RCIntegerMatrix.h"

@interface RCIntegerMatrixTests : XCTestCase

@end

@implementation RCIntegerMatrixTests


- (void)testElementAtReturnsValue {
  @autoreleasepool {
    RCEngine* mainEngine = [RCEngine GetInstance];
    RCSymbolicExpression* rse = [mainEngine Evaluate: @"x <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14), nrow=7, ncol=2)"];
    RCIntegerMatrix* results = [rse AsIntegerMatrix];
    XCTAssertEqual(1, [results ElementAt:0 column:0]);
    XCTAssertEqual(2, [results ElementAt:0 column:1]);
    XCTAssertEqual(3, [results ElementAt:1 column:0]);
    XCTAssertEqual(4, [results ElementAt:1 column:1]);
    XCTAssertEqual(5, [results ElementAt:2 column:0]);
    XCTAssertEqual(6, [results ElementAt:2 column:1]);
    XCTAssertEqual(7, [results ElementAt:3 column:0]);
    XCTAssertEqual(8, [results ElementAt:3 column:1]);
    XCTAssertEqual(9, [results ElementAt:4 column:0]);
    XCTAssertEqual(10, [results ElementAt:4 column:1]);
    XCTAssertEqual(11, [results ElementAt:5 column:0]);
    XCTAssertEqual(12, [results ElementAt:5 column:1]);
    XCTAssertEqual(13, [results ElementAt:6 column:0]);
    XCTAssertEqual(14, [results ElementAt:6 column:1]);
    [results release];
    [rse release];
  }
}


@end
