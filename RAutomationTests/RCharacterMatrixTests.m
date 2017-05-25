//
//  RCharacterMatrixTests.m
//  RAutomation
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "RCharacterMatrix.h"

@interface RCharacterMatrixTests : XCTestCase

@end

@implementation RCharacterMatrixTests

- (void)setUp {
    [super setUp];
    [[REngine mainEngine] activate];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [REngine shutdown];
}

- (void)testElementAtReturnsValue {
    @autoreleasepool{
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"x <- matrix(c('hello', 'world'), nrow=2, ncol=1)"];
        RCharacterMatrix* results = [rse AsCharacterMatrix];
        XCTAssertEqualObjects(@"hello", [results ElementAt:0 column:0]);
        [results release];
        [rse release];
    }
    
}


@end
