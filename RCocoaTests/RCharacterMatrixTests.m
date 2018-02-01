//
//  RCCharacterMatrixTests.m
//  RCocoa
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "RCCharacterMatrix.h"

@interface RCCharacterMatrixTests : XCTestCase

@end

@implementation RCCharacterMatrixTests

- (void)testElementAtReturnsValue {
    @autoreleasepool{
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"x <- matrix(c('hello', 'world', 'the', 'quick', 'brown', 'fox', 'jumped', 'over', 'the', 'lazy', 'dog'), nrow=6, ncol=2)"];
        RCCharacterMatrix* results = [rse AsCharacterMatrix];
        XCTAssertEqualObjects(@"hello", [results ElementAt:0 column:0]);
        XCTAssertEqualObjects(@"world", [results ElementAt:0 column:1]);
        XCTAssertEqualObjects(@"the", [results ElementAt:1 column:0]);
        XCTAssertEqualObjects(@"quick", [results ElementAt:1 column:1]);
        XCTAssertEqualObjects(@"brown", [results ElementAt:2 column:0]);
        XCTAssertEqualObjects(@"fox", [results ElementAt:2 column:1]);
        XCTAssertEqualObjects(@"jumped", [results ElementAt:3 column:0]);
        XCTAssertEqualObjects(@"over", [results ElementAt:3 column:1]);
        XCTAssertEqualObjects(@"the", [results ElementAt:4 column:0]);
        XCTAssertEqualObjects(@"lazy", [results ElementAt:4 column:1]);
        XCTAssertEqualObjects(@"dog", [results ElementAt:5 column:0]);

        
        [results release];
        [rse release];
    }
}


@end
