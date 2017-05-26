//
//  RCocoaTests.m
//  RCocoaTests
//
//  Created by Luke Rasmussen on 1/5/17.
//  Copyright © 2017 Luke Rasmussen. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "RCEngine.h"

@interface RCEngineTests : XCTestCase

@end

@implementation RCEngineTests

- (void)testActivate {
    @autoreleasepool {
        XCTAssert([[RCEngine mainEngine] activate]);
        [RCEngine shutdown];
    }
}
- (void)testNilValue {
    @autoreleasepool {
        XCTAssert([[RCEngine mainEngine] activate]);
        RCSymbolicExpression* sexp = [[RCEngine mainEngine] NilValue];
        XCTAssertNotNil(sexp);
        XCTAssertEqual(NILSXP, [sexp Type]);
        [RCEngine shutdown];
    }
}

- (void)testNaString {
    @autoreleasepool {
        XCTAssert([[RCEngine mainEngine] activate]);
        RCSymbolicExpression* sexp = [[RCEngine mainEngine] NaString];
        XCTAssertNotNil(sexp);
        XCTAssertEqual(CHARSXP, [sexp Type]);
        [sexp release];
        [RCEngine shutdown];
    }
}

@end
