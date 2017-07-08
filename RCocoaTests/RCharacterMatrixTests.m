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
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"x <- matrix(c('hello', 'world'), nrow=2, ncol=1)"];
        RCCharacterMatrix* results = [rse AsCharacterMatrix];
        XCTAssertEqualObjects(@"hello", [results ElementAt:0 column:0]);
        [results release];
        [rse release];
    }
}


@end
