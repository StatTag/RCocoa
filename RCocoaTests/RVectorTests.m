//
//  RCVectorTests.m
//  RCocoa
//
//  Created by Luke Rasmussen on 5/3/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "RCocoa.h"

@interface RCVectorTests : XCTestCase

@end

@implementation RCVectorTests

+ (void)setUp {
    [super setUp];
    [[RCEngine mainEngine] activate];
}

+ (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [RCEngine shutdown];
}

- (void)testInitWithEngineAndExpressionAndLength_invalidLength {
    @autoreleasepool {
        XCTAssertThrows([[RCVector alloc] initWithEngineAndExpressionAndLength:[RCEngine mainEngine] expression: nil length: -1]);
    }
}

- (void)testInitWithEngineAndExpressionAndLength {
    @autoreleasepool {
        RCSymbolicExpression* rse = [[RCEngine mainEngine] Evaluate: @"x <- c(1, 2)"];
        RCVector* vector = [[RCVector alloc] initWithEngineAndExpressionAndLength:[RCEngine mainEngine] expression: [rse GetHandle] length: 1];
        XCTAssertNotNil(vector);
        [vector release];
        [rse release];
    }
}

- (void)testNamesWithNoNames {
    @autoreleasepool {
        RCSymbolicExpression* rse = [[RCEngine mainEngine] Evaluate: @"x <- c(1, 2)"];
        RCVector* vector = [[RCVector alloc] initWithEngineAndExpressionAndLength:[RCEngine mainEngine] expression: [rse GetHandle] length: 1];
        XCTAssertNil([vector Names]);
        [vector release];
        [rse release];
    }
}

- (void)testNamesWithNames {
    @autoreleasepool {
        RCSymbolicExpression* rse = [[RCEngine mainEngine] Evaluate: @"n = c(1,2)\n s=c('a','b')\n df = data.frame(n, s)"];
        RCVector* vector = [[RCVector alloc] initWithEngineAndExpressionAndLength:[RCEngine mainEngine] expression: [rse GetHandle] length: 1];
        NSArray<NSString*>* names = [vector Names];
        XCTAssertNotNil(names);
        XCTAssertEqual(2, [names count]);
        [vector release];
        [rse release];
    }
}

@end
