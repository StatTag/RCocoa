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

+ (void)setUp {
    [super setUp];
    [[RCEngine mainEngine] activate];
}

+ (void)tearDown {
    [super tearDown];
    [RCEngine shutdown];
}

- (void)testElementAtReturnsValue {
    @autoreleasepool {
        RCSymbolicExpression* rse = [[RCEngine mainEngine] Evaluate: @"x <- matrix(c(1, 2, 3, 4), nrow=2, ncol=2)"];
        RCIntegerMatrix* results = [rse AsIntegerMatrix];
        XCTAssertEqual(1, [results ElementAt:0 column:0]);
        XCTAssertEqual(2, [results ElementAt:0 column:1]);
        XCTAssertEqual(3, [results ElementAt:1 column:0]);
        XCTAssertEqual(4, [results ElementAt:1 column:1]);
        [results release];
        [rse release];
    }
    
}


@end
