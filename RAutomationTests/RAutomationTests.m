//
//  RAutomationTests.m
//  RAutomationTests
//
//  Created by Luke Rasmussen on 1/5/17.
//  Copyright © 2017 Luke Rasmussen. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "REngine.h"

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

- (void)testActivate {
    @autoreleasepool {
        if (![[REngine mainEngine] activate]) {
            NSLog(@"%@", [NSString stringWithFormat:NLS(@"Unable to start R: %@"), [[REngine mainEngine] lastError]]);
            XCTAssert(false);
        }
        RSEXP* exp = [[REngine mainEngine] evaluateString: @"2+3"];
        XCTAssertNotNil(exp);
        XCTAssertEqual(REALSXP, [exp type]);
    }
}

//- (void)initialize {
//    
//}

@end
