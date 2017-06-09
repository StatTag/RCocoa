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

- (void)testMultipleEngineAndActivateRequests {
    @autoreleasepool {
        RCEngine* engine1 = [RCEngine mainEngine];
        RCEngine* engine2 = [RCEngine mainEngine];
        XCTAssertNotNil(engine1);
        XCTAssertNotNil(engine2);
        XCTAssertEqual(engine1, engine2);
        XCTAssertTrue([[RCEngine mainEngine] activate]);
        XCTAssertTrue([[RCEngine mainEngine] activate]);
    }
}

- (void)testMultipleEngineActivateAndParseRequests {
    __block BOOL hasCalledBack = NO;
    
    void (^completionBlock)(void) = ^(void){
        NSLog(@"Completion Block!");
        hasCalledBack = YES;
    };
    
    NSLog(@"START");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"ASYNC");
        for (int index = 0; index < 100; index++) {
            NSLog(@"ITERATION");
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"RUN");
                XCTAssertTrue([[RCEngine mainEngine] activate]);
                [[RCEngine mainEngine] Evaluate:@"x <- 2"];
                [[RCEngine mainEngine] Evaluate:@"x"];
                [[RCEngine mainEngine] Evaluate:@""];
            });
        }
    });
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    while (hasCalledBack == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
}

@end
