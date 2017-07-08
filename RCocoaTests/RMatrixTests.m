//
//  RCMatrixTests.m
//  RCocoa
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCMatrix.h"

@interface RCMatrixTests : XCTestCase

@end

@implementation RCMatrixTests

- (void)testRowColCounts {
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"x <- matrix(c('hello', 'world'), nrow=2, ncol=1)"];
        RCCharacterMatrix* results = [rse AsCharacterMatrix];
        XCTAssertEqual(2, [results RowCount]);
        XCTAssertEqual(1, [results ColumnCount]);
        [results release];
        [rse release];
    }
}

- (void)testElementAtThrows {
    @autoreleasepool {
        RCMatrix<NSNumber*>* matrix = [[RCMatrix alloc] init];
        XCTAssertThrows([matrix ElementAt:0 column:0]);
    }
}

- (void)testCheckIndicesThrows {
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"x <- matrix(c('hello', 'world'), nrow=2, ncol=1)"];
        RCCharacterMatrix* results = [rse AsCharacterMatrix];
        XCTAssertThrows([results CheckIndices:2 column:1]);
        XCTAssertThrows([results CheckIndices:-1 column:0]);
        XCTAssertThrows([results CheckIndices:0 column:-1]);
        [results release];
        [rse release];
    }
}
@end
