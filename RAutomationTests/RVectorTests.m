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
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
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
    }
}

@end
