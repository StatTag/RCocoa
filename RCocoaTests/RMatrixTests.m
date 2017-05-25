//
//  RMatrixTests.m
//  RAutomation
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RMatrix.h"

@interface RMatrixTests : XCTestCase

@end

@implementation RMatrixTests

- (void)setUp {
    [super setUp];
    [[REngine mainEngine] activate];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [REngine shutdown];
}

- (void)testRowColCounts {
    @autoreleasepool {
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"x <- matrix(c('hello', 'world'), nrow=2, ncol=1)"];
        RCharacterMatrix* results = [rse AsCharacterMatrix];
        XCTAssertEqual(2, [results RowCount]);
        XCTAssertEqual(1, [results ColumnCount]);
        [results release];
        [rse release];
    }
}

- (void)testElementAtThrows {
    @autoreleasepool {
        RMatrix<NSNumber*>* matrix = [[RMatrix alloc] init];
        XCTAssertThrows([matrix ElementAt:0 column:0]);
    }
}

- (void)testCheckIndicesThrows {
    @autoreleasepool {
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"x <- matrix(c('hello', 'world'), nrow=2, ncol=1)"];
        RCharacterMatrix* results = [rse AsCharacterMatrix];
        XCTAssertThrows([results CheckIndices:2 column:1]);
        XCTAssertThrows([results CheckIndices:-1 column:0]);
        XCTAssertThrows([results CheckIndices:0 column:-1]);
        [results release];
        [rse release];
    }
}
@end
