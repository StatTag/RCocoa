//
//  RCharacterMatrixTests.m
//  RAutomation
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "RLogicalMatrix.h"

@interface RLogicalMatrixTests : XCTestCase

@end

@implementation RLogicalMatrixTests

- (void)setUp {
    [super setUp];
    [[REngine mainEngine] activate];
}

- (void)tearDown {
    [super tearDown];
    [REngine shutdown];
}

- (void)testElementAtReturnsString {
    @autoreleasepool {
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"x <- matrix(c(TRUE, FALSE, FALSE, TRUE), nrow=2, ncol=2)"];
        RLogicalMatrix* results = [rse AsLogicalMatrix];
        XCTAssertTrue([results ElementAt:0 column:0]);
        XCTAssertFalse([results ElementAt:1 column:0]);
        XCTAssertFalse([results ElementAt:0 column:1]);
        XCTAssertTrue([results ElementAt:1 column:1]);
        [results release];
        [rse release];
    }
    
}


@end
