//
//  RCSymbolicExpressionTests.m
//  RCocoa
//
//  Created by Luke Rasmussen on 4/13/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "RCocoa.h"

@interface RCSymbolicExpressionTests : XCTestCase

@end

@implementation RCSymbolicExpressionTests

- (void)testInitWithNils {
    @autoreleasepool {
        RCSymbolicExpression* rse = [ [RCSymbolicExpression alloc] initWithEngineAndExpression: nil expression: nil];
        XCTAssertNotNil(rse);
        XCTAssertNil([rse Engine]);
        XCTAssertEqual(NILSXP, [rse Type]);
        [rse release];
    }
}

- (void)testInitWithEngine {
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [ [RCSymbolicExpression alloc] initWithEngineAndExpression: mainEngine expression: nil];
        XCTAssertNotNil(rse);
        XCTAssertNotNil([rse Engine]);
        XCTAssertEqual(NILSXP, [rse Type]);
        [rse release];
    }
}

- (void)testIsInvalid {
    @autoreleasepool {
        RCSymbolicExpression* rse = [ [RCSymbolicExpression alloc] initWithEngineAndExpression: nil expression: nil];
        XCTAssert([rse IsInvalid]);
        [rse release];
    }
}

- (void)testGetAttributeNames_Empty {
    @autoreleasepool {
        RCSymbolicExpression* rse = [ [RCSymbolicExpression alloc] initWithEngineAndExpression: nil expression: nil];
        NSArray<NSString*>* attrs = [rse GetAttributeNames];
        XCTAssertNotNil(attrs);
        XCTAssertEqual(0, [attrs count]);
        [attrs release];
        [rse release];
    }
}

- (void)testIsVector_Nil{
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [ [RCSymbolicExpression alloc] initWithEngineAndExpression: mainEngine expression: nil];
        XCTAssertThrows([rse IsVector]);
        [rse release];
    }
}

- (void)testIsMatrix_Nil{
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [ [RCSymbolicExpression alloc] initWithEngineAndExpression: mainEngine expression: nil];
        XCTAssertThrows([rse IsMatrix]);
        [rse release];
    }
}

- (void)testCommandReturnsNullType {
    // R will return symbolic expressions that are of a null type, which is different from a null response.
    // We want to ensure that we get a symbolic expression returned when we issue commands that return
    // a null expression type.
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"png(\"test.png\")"];
        XCTAssertNotNil(rse);
        XCTAssertEqual(NILSXP, [rse Type]);
        rse = [mainEngine Evaluate: @"dev.off()"];
        [rse release];
    }
}

- (void)testIsMatrix{
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"x <- matrix(c(1,2,3,4), nrow=2, ncol=2, byrow=TRUE)"];
        XCTAssertTrue([rse IsMatrix]);
        [rse release];
    }
}

- (void)testIsVector{
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"x <- c(1, 2)"];
        XCTAssert([rse IsVector]);
        [rse release];
    }
}

- (void)testIsDataFrame{
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"n = c(1,2)\n s=c('a','b')\n df = data.frame(n, s)"];
        XCTAssert([rse IsDataFrame]);
        [rse release];
    }
}


- (void)testIsList{
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"n = c(1,2)\n s=c('a','b')\n ls = list(n, s)"];
        XCTAssert([rse IsList]);
        [rse release];
    }
}

- (void)testIsFunction{
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"invisible(as.list)"];
        XCTAssert([rse IsFunction]);
        [rse release];
    }
}

- (void)testAsInteger{
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"x <- c(1, 2)"];
        NSArray* results = [rse AsInteger];
        XCTAssertNotNil(results);
        XCTAssertEqual(2, [results count]);
        XCTAssertEqual(1, [results[0] intValue]);
        XCTAssertEqual(2, [results[1] intValue]);
        [results release];
        [rse release];
    }
}

- (void)testAsReal{
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"x <- c(1, 2)"];
        NSArray* results = [rse AsReal];
        XCTAssertNotNil(results);
        XCTAssertEqual(2, [results count]);
        XCTAssertEqual(1.0, [results[0] doubleValue]);
        XCTAssertEqual(2.0, [results[1] doubleValue]);
        [results release];
        [rse release];
    }
}

- (void)testAsLogical{
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"x <- c(1, 0)"];
        NSArray* results = [rse AsLogical];
        XCTAssertNotNil(results);
        XCTAssertEqual(2, [results count]);
        XCTAssertEqual(R_TRUE, [results[0] boolValue]);
        XCTAssertEqual(R_FALSE, [results[1] boolValue]);
        [results release];
        [rse release];
    }
}

- (void)testAsCharacter{
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"x <- c('hello', 'world')"];
        NSArray* results = [rse AsCharacter];
        XCTAssertNotNil(results);
        XCTAssertEqual(2, [results count]);
        XCTAssertEqualObjects(@"hello", results[0]);
        XCTAssertEqualObjects(@"world", results[1]);
        [results release];
        [rse release];
    }
}

- (void)testAsCharacterMatrix{
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"x <- matrix(c('hello', 'world'), nrow=2, ncol=1)"];
        RCCharacterMatrix* results = [rse AsCharacterMatrix];
        XCTAssertNotNil(results);
    }
}

- (void)testAsIntegerMatrix{
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"x <- matrix(c(5, 10), nrow=2, ncol=1)"];
        RCIntegerMatrix* results = [rse AsIntegerMatrix];
        XCTAssertNotNil(results);
    }
}

- (void)testAsLogicalMatrix{
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"x <- matrix(c(FALSE, TRUE), nrow=2, ncol=1)"];
        RCLogicalMatrix* results = [rse AsLogicalMatrix];
        XCTAssertNotNil(results);
    }
}

- (void)testGetAttributeNames_Filled {
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"n = c(1,2)\n s=c('a','b')\n df = data.frame(n, s)"];
        XCTAssertNotNil(rse);
        NSArray<NSString*>* attrs = [rse GetAttributeNames];
        XCTAssertNotNil(attrs);
        XCTAssertEqual(3, [attrs count]);
        XCTAssertEqualObjects(@"names", attrs[0]);
        XCTAssertEqualObjects(@"row.names", attrs[1]);
        XCTAssertEqualObjects(@"class", attrs[2]);
        [attrs release];
        [rse release];
    }
}

- (void)testGetAttribute {
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"n = c(1,2)\n s=c('a','b')\n df = data.frame(n, s)"];
        XCTAssertNotNil(rse);
        RCSymbolicExpression* attrExp = [rse GetAttribute:@"class"];
        XCTAssertNotNil(attrExp);
        [attrExp release];
        [rse release];
    }
}

- (void)testAsDataFrame{
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"n = c(1,2)\n s=c('a','b')\n df = data.frame(n, s)"];
        RCDataFrame* dataFrame = [rse AsDataFrame];
        XCTAssertNotNil(dataFrame);
        [dataFrame release];
        [rse release];
    }
}

- (void)testAsList{
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"n = c(1,2)\n s=c('a','b')\n ls = list(n, s)"];
        RCVector* list = [rse AsList];
        XCTAssertNotNil(list);
        XCTAssertNotNil([list ElementAt:0]);
        XCTAssertNotNil([list ElementAt:1]);
        [list release];
        [rse release];
    }
}

- (void)testAsFunction{
    @autoreleasepool {
        RCEngine* mainEngine = [RCEngine GetInstance];
        RCSymbolicExpression* rse = [mainEngine Evaluate: @"invisible(as.list)"];
        RCFunction* fn = [rse AsFunction];
        XCTAssertNotNil(fn);
        [fn release];
        [rse release];
    }
}
@end
