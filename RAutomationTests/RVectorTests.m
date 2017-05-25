//
//  RVectorTests.m
//  RAutomation
//
//  Created by Luke Rasmussen on 5/3/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "RAutomation.h"

@interface RVectorTests : XCTestCase

@end

@implementation RVectorTests

- (void)setUp {
    [super setUp];
    [[REngine mainEngine] activate];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [REngine shutdown];
}

- (void)testInitWithEngineAndExpressionAndLength_invalidLength {
    @autoreleasepool {
        XCTAssertThrows([[RVector alloc] initWithEngineAndExpressionAndLength:[REngine mainEngine] expression: nil length: -1]);
    }
}

- (void)testInitWithEngineAndExpressionAndLength {
    @autoreleasepool {
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"x <- c(1, 2)"];
        RVector* vector = [[RVector alloc] initWithEngineAndExpressionAndLength:[REngine mainEngine] expression: [rse GetHandle] length: 1];
        XCTAssertNotNil(vector);
        [vector release];
        [rse release];
    }
}

- (void)testNamesWithNoNames {
    @autoreleasepool {
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"x <- c(1, 2)"];
        RVector* vector = [[RVector alloc] initWithEngineAndExpressionAndLength:[REngine mainEngine] expression: [rse GetHandle] length: 1];
        XCTAssertNil([vector Names]);
        [vector release];
        [rse release];
    }
}

- (void)testNamesWithNames {
    @autoreleasepool {
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"n = c(1,2)\n s=c('a','b')\n df = data.frame(n, s)"];
        RVector* vector = [[RVector alloc] initWithEngineAndExpressionAndLength:[REngine mainEngine] expression: [rse GetHandle] length: 1];
        NSArray<NSString*>* names = [vector Names];
        XCTAssertNotNil(names);
        XCTAssertEqual(2, [names count]);
        [vector release];
        [rse release];
    }
}

@end
