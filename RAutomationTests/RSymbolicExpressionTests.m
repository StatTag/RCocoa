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

- (void)testGetAttributeNames_Filled {
    @autoreleasepool {
        XCTAssert([[REngine mainEngine] activate]);
        RSymbolicExpression* rse = [[REngine mainEngine] evaluateString: @"library(survival)\ndata(pbc)\nlibrary(tableone)\ntable1 <- CreateTableOne(vars = c(\"trt\", \"age\", \"sex\", \"albumin\"), data = pbc, factorVars = c(\"trt\", \"sex\"))"];
        XCTAssertNotNil(rse);
        NSArray<NSString*>* attrs = [rse GetAttributeNames];
        [attrs release];
        [rse release];
        [REngine shutdown];
    }
}

@end
