//
//  RCCharacterMatrixTests.m
//  RCocoa
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "RCRealMatrix.h"

@interface RCRealMatrixTests : XCTestCase

@end

@implementation RCRealMatrixTests

- (void)testElementAtReturnsValue {
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"x <- matrix(c(0.1, 1.0, 0.2, 2.0, 0.2, 2.0, 0.1, 1.0, 2.0, 0.1), nrow=5, ncol=2)"];
        RCRealMatrix* results = [rse AsRealMatrix];
        XCTAssertEqual(0.1, [results ElementAt:0 column:0]);
        XCTAssertEqual(1.0, [results ElementAt:1 column:0]);
        XCTAssertEqual(0.2, [results ElementAt:2 column:0]);
        XCTAssertEqual(2.0, [results ElementAt:3 column:0]);
      
        XCTAssertEqual(0.2, [results ElementAt:4 column:0]);
        XCTAssertEqual(2.0, [results ElementAt:0 column:1]);
        XCTAssertEqual(0.1, [results ElementAt:1 column:1]);
        XCTAssertEqual(1.0, [results ElementAt:2 column:1]);

        XCTAssertEqual(2.0, [results ElementAt:3 column:1]);
        XCTAssertEqual(0.1, [results ElementAt:4 column:1]);

        NSLog(@"%@", [results description]);
      
      
        [results release];
        [rse release];
    }
    
}


@end
