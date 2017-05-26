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

+ (void)setUp {
    [super setUp];
    [[RCEngine mainEngine] activate];
}

+ (void)tearDown {
    [super tearDown];
    //[RCEngine shutdown];
}

- (void)testNilValue {
    @autoreleasepool {
        RCSymbolicExpression* sexp = [[RCEngine mainEngine] NilValue];
        XCTAssertNotNil(sexp);
        XCTAssertEqual(NILSXP, [sexp Type]);
    }
}

- (void)testNaString {
    @autoreleasepool {
        RCSymbolicExpression* sexp = [[RCEngine mainEngine] NaString];
        XCTAssertNotNil(sexp);
        XCTAssertEqual(CHARSXP, [sexp Type]);
        [sexp release];
    }
}

@end
