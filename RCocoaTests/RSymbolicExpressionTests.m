//
//  RSymbolicExpressionTests.m
//  RAutomation
//
//  Created by Luke Rasmussen on 4/13/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "RAutomation.h"

@interface RSymbolicExpressionTests : XCTestCase

@end

@implementation RSymbolicExpressionTests

- (void)setUp {
    [super setUp];

    //[[REngine mainEngine] activate];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitWithNils {
    @autoreleasepool {
        RSymbolicExpression* rse = [ [RSymbolicExpression alloc] initWithEngineAndExpression: nil expression: nil];
        XCTAssertNotNil(rse);
        XCTAssertNil([rse Engine]);
        XCTAssertEqual(NILSXP, [rse Type]);
        [rse release];
    }
}

- (void)testInitWithEngine {
    @autoreleasepool {
        RSymbolicExpression* rse = [ [RSymbolicExpression alloc] initWithEngineAndExpression: [REngine mainEngine] expression: nil];
        XCTAssertNotNil(rse);
        XCTAssertNotNil([rse Engine]);
        XCTAssertEqual(NILSXP, [rse Type]);
        [rse release];
    }
}

- (void)testIsInvalid {
    @autoreleasepool {
        RSymbolicExpression* rse = [ [RSymbolicExpression alloc] initWithEngineAndExpression: nil expression: nil];
        XCTAssert([rse IsInvalid]);
        [rse release];
    }
}

- (void)testGetAttributeNames_Empty {
    @autoreleasepool {
        RSymbolicExpression* rse = [ [RSymbolicExpression alloc] initWithEngineAndExpression: nil expression: nil];
        NSArray<NSString*>* attrs = [rse GetAttributeNames];
        XCTAssertNotNil(attrs);
        XCTAssertEqual(0, [attrs count]);
        [attrs release];
        [rse release];
    }
}

- (void)testIsVector_Nil{
    @autoreleasepool {
        XCTAssert([[REngine mainEngine] activate]);
        RSymbolicExpression* rse = [ [RSymbolicExpression alloc] initWithEngineAndExpression: [REngine mainEngine] expression: nil];
        XCTAssertThrows([rse IsVector]);
        [rse release];
        [REngine shutdown];
    }
}

- (void)testIsMatrix_Nil{
    @autoreleasepool {
        XCTAssert([[REngine mainEngine] activate]);
        RSymbolicExpression* rse = [ [RSymbolicExpression alloc] initWithEngineAndExpression: [REngine mainEngine] expression: nil];
        XCTAssertThrows([rse IsMatrix]);
        [rse release];
        [REngine shutdown];
    }
}

- (void)testIsMatrix{
    @autoreleasepool {
        XCTAssert([[REngine mainEngine] activate]);
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"x <- matrix(c(1,2,3,4), nrow=2, ncol=2, byrow=TRUE)"];
        XCTAssertTrue([rse IsMatrix]);
        [rse release];
        [REngine shutdown];
    }
}

- (void)testIsVector{
    @autoreleasepool {
        XCTAssert([[REngine mainEngine] activate]);
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"x <- c(1, 2)"];
        XCTAssert([rse IsVector]);
        [rse release];
        [REngine shutdown];
    }
}

- (void)testIsDataFrame{
    @autoreleasepool {
        XCTAssert([[REngine mainEngine] activate]);
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"n = c(1,2)\n s=c('a','b')\n df = data.frame(n, s)"];
        XCTAssert([rse IsDataFrame]);
        [rse release];
        [REngine shutdown];
    }
}

- (void)testAsInteger{
    @autoreleasepool {
        XCTAssert([[REngine mainEngine] activate]);
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"x <- c(1, 2)"];
        NSArray* results = [rse AsInteger];
        XCTAssertNotNil(results);
        XCTAssertEqual(2, [results count]);
        XCTAssertEqual(1, [results[0] intValue]);
        XCTAssertEqual(2, [results[1] intValue]);
        [results release];
        [rse release];
        [REngine shutdown];
    }
}

- (void)testAsReal{
    @autoreleasepool {
        XCTAssert([[REngine mainEngine] activate]);
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"x <- c(1, 2)"];
        NSArray* results = [rse AsReal];
        XCTAssertNotNil(results);
        XCTAssertEqual(2, [results count]);
        XCTAssertEqual(1.0, [results[0] doubleValue]);
        XCTAssertEqual(2.0, [results[1] doubleValue]);
        [results release];
        [rse release];
        [REngine shutdown];
    }
}

- (void)testAsLogical{
    @autoreleasepool {
        XCTAssert([[REngine mainEngine] activate]);
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"x <- c(1, 0)"];
        NSArray* results = [rse AsLogical];
        XCTAssertNotNil(results);
        XCTAssertEqual(2, [results count]);
        XCTAssertEqual(TRUE, [results[0] boolValue]);
        XCTAssertEqual(FALSE, [results[1] boolValue]);
        [results release];
        [rse release];
        [REngine shutdown];
    }
}

- (void)testAsCharacter{
    @autoreleasepool {
        XCTAssert([[REngine mainEngine] activate]);
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"x <- c('hello', 'world')"];
        NSArray* results = [rse AsCharacter];
        XCTAssertNotNil(results);
        XCTAssertEqual(2, [results count]);
        XCTAssertEqualObjects(@"hello", results[0]);
        XCTAssertEqualObjects(@"world", results[1]);
        [results release];
        [rse release];
        [REngine shutdown];
    }
}

- (void)testAsCharacterMatrix{
    @autoreleasepool {
        XCTAssert([[REngine mainEngine] activate]);
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"x <- matrix(c('hello', 'world'), nrow=2, ncol=1)"];
        RCharacterMatrix* results = [rse AsCharacterMatrix];
        XCTAssertNotNil(results);
        [REngine shutdown];
    }
}

- (void)testAsIntegerMatrix{
    @autoreleasepool {
        XCTAssert([[REngine mainEngine] activate]);
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"x <- matrix(c(5, 10), nrow=2, ncol=1)"];
        RIntegerMatrix* results = [rse AsIntegerMatrix];
        XCTAssertNotNil(results);
        [REngine shutdown];
    }
}

- (void)testAsLogicalMatrix{
    @autoreleasepool {
        XCTAssert([[REngine mainEngine] activate]);
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"x <- matrix(c(FALSE, TRUE), nrow=2, ncol=1)"];
        RLogicalMatrix* results = [rse AsLogicalMatrix];
        XCTAssertNotNil(results);
        [REngine shutdown];
    }
}

- (void)testGetAttributeNames_Filled {
    @autoreleasepool {
        REngine* engine = [REngine mainEngine];
        XCTAssert([engine activate]);
        RSymbolicExpression* rse = [engine Evaluate: @"library(survival)"];
        rse = [engine Evaluate: @"data(pbc)"];
        rse = [engine Evaluate: @"library(tableone)"];
        rse = [engine Evaluate: @"table1 <- CreateTableOne(vars = c(\"trt\", \"age\", \"sex\", \"albumin\"), data = pbc, factorVars = c(\"trt\", \"sex\"))"];
        XCTAssertNotNil(rse);
        NSArray<NSString*>* attrs = [rse GetAttributeNames];
        XCTAssertNotNil(attrs);
        XCTAssertEqual(2, [attrs count]);
        XCTAssertEqualObjects(@"names", attrs[0]);
        XCTAssertEqualObjects(@"class", attrs[1]);
        [attrs release];
        [rse release];
        [REngine shutdown];
    }
}

- (void)testGetAttribute {
    @autoreleasepool {
        REngine* engine = [REngine mainEngine];
        XCTAssert([engine activate]);
        RSymbolicExpression* rse = [engine Evaluate: @"library(survival)"];
        rse = [engine Evaluate: @"data(pbc)"];
        rse = [engine Evaluate: @"library(tableone)"];
        rse = [engine Evaluate: @"table1 <- CreateTableOne(vars = c(\"trt\", \"age\", \"sex\", \"albumin\"), data = pbc, factorVars = c(\"trt\", \"sex\"))"];
        XCTAssertNotNil(rse);
        RSymbolicExpression* attrExp = [rse GetAttribute:@"class"];
        XCTAssertNotNil(attrExp);
        [attrExp release];
        [rse release];
        [REngine shutdown];
    }
}

- (void)testAsDataFrame{
    @autoreleasepool {
        XCTAssert([[REngine mainEngine] activate]);
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"n = c(1,2)\n s=c('a','b')\n df = data.frame(n, s)"];
        RDataFrame* dataFrame = [rse AsDataFrame];
        XCTAssertNotNil(dataFrame);
        [dataFrame release];
        [rse release];
        [REngine shutdown];
    }
}

@end
