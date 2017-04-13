//
//  RAutomationTests.m
//  RAutomationTests
//
//  Created by Luke Rasmussen on 1/5/17.
//  Copyright © 2017 Luke Rasmussen. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "RAutomation.h"

@interface RAutomationTests : XCTestCase

@end

@implementation RAutomationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testEvaluate {
    @autoreleasepool {
        //RAutomation* automation = new RAutomation();
    }
}




/*
 The following block are basic tests to validate the interface with R is working correctly.  It is not a comprehensive
 suite of R tests, since that would be out of the scope of our work.  The majority of tests are going to be for the
 helpers/wrappers we implement on top of R, but validating R functionatliy seemed like a good idea.
 */
- (void)testActivate {
    @autoreleasepool {
        XCTAssert([[REngine mainEngine] activate]);
        [REngine shutdown];
    }
}

- (void)testEvaluateString {
    @autoreleasepool {
        XCTAssert([[REngine mainEngine] activate]);
        RSEXP* exp = [[REngine mainEngine] evaluateString: @"2+3"];
        XCTAssertNotNil(exp);
        XCTAssertEqual(REALSXP, [exp type]);
        [exp release];
        [REngine shutdown];
    }
}

- (void)testExecuteString {
    @autoreleasepool {
        XCTAssert([[REngine mainEngine] activate]);
        XCTAssert([[REngine mainEngine] executeString: @"2+3"]);
        [REngine shutdown];
    }
}

- (void)testParse {
    @autoreleasepool {
        XCTAssert([[REngine mainEngine] activate]);
        RSEXP* exp = [[REngine mainEngine] parse: @"2+3"];
        XCTAssertNotNil(exp);
        XCTAssertEqual(EXPRSXP, [exp type]);
        [exp release];
        [REngine shutdown];
    }
}

//- (void)initialize {
//    
//}

@end
