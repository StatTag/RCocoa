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

- (void)testElementAtReturnsValue {
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"x <- matrix(c(TRUE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, TRUE, TRUE, FALSE), nrow=5, ncol=2)"];
        RCLogicalMatrix* results = [rse AsLogicalMatrix];
        XCTAssertTrue([results ElementAt:0 column:0]);
        XCTAssertFalse([results ElementAt:1 column:0]);
      
        XCTAssertFalse([results ElementAt:2 column:0]);
        XCTAssertTrue([results ElementAt:3 column:0]);

        XCTAssertTrue([results ElementAt:4 column:0]);
        XCTAssertFalse([results ElementAt:0 column:1]);

        XCTAssertFalse([results ElementAt:1 column:1]);
        XCTAssertTrue([results ElementAt:2 column:1]);
        
        XCTAssertTrue([results ElementAt:3 column:1]);
        XCTAssertFalse([results ElementAt:4 column:1]);
      
//        NSLog(@"%@", [results description]);

      
        [results release];
        [rse release];
    }
    
}


@end
