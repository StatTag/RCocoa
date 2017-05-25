//
//  RCharacterMatrixTests.m
//  RAutomation
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "RIntegerMatrix.h"

@interface RIntegerMatrixTests : XCTestCase

@end

@implementation RIntegerMatrixTests

- (void)setUp {
    [super setUp];
    [[REngine mainEngine] activate];
}

- (void)tearDown {
    [super tearDown];
    [REngine shutdown];
}

- (void)testElementAtReturnsValue {
    @autoreleasepool {
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"x <- matrix(c(1, 2, 3, 4), nrow=2, ncol=2)"];
        RIntegerMatrix* results = [rse AsIntegerMatrix];
        XCTAssertEqual(1, [results ElementAt:0 column:0]);
        XCTAssertEqual(2, [results ElementAt:0 column:1]);
        XCTAssertEqual(3, [results ElementAt:1 column:0]);
        XCTAssertEqual(4, [results ElementAt:1 column:1]);
        [results release];
        [rse release];
    }
    
}


@end
