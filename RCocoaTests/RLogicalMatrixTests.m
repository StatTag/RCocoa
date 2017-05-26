//
//  RCCharacterMatrixTests.m
//  RCocoa
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "RCLogicalMatrix.h"

@interface RCLogicalMatrixTests : XCTestCase

@end

@implementation RCLogicalMatrixTests

+ (void)setUp {
    [super setUp];
    [[RCEngine mainEngine] activate];
}

+ (void)tearDown {
    [super tearDown];
    //[RCEngine shutdown];
}

- (void)testElementAtReturnsValue {
    @autoreleasepool {
        RCSymbolicExpression* rse = [[RCEngine mainEngine] Evaluate: @"x <- matrix(c(TRUE, FALSE, FALSE, TRUE), nrow=2, ncol=2)"];
        RCLogicalMatrix* results = [rse AsLogicalMatrix];
        XCTAssertTrue([results ElementAt:0 column:0]);
        XCTAssertFalse([results ElementAt:0 column:1]);
        XCTAssertFalse([results ElementAt:1 column:0]);
        XCTAssertTrue([results ElementAt:1 column:1]);
        [results release];
        [rse release];
    }
    
}


@end
