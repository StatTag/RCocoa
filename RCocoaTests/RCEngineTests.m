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

// The purpose of this test is to run a bunch of evaluations accessing the same RCEngine
// instance from multiple threads.  All we care about is that it doesn't crash.
- (void)testMultipleEngineActivateAndParseRequests {
    __block BOOL hasCalledBack = NO;
    
    void (^completionBlock)(void) = ^(void){
        NSLog(@"Completion Block!");
        hasCalledBack = YES;
    };
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int index = 0; index < 100; index++) {
            dispatch_async(dispatch_get_main_queue(), ^{
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

- (void)testPreProcessStatement
{
    @autoreleasepool {
        NSString* statement = @"test\r\ntest 2\n\r  test 3 \t  \rtest 4\ntest 5\n\n";
        NSMutableArray<NSString*>* results = [[RCEngine mainEngine] PreProcessStatement:statement];
        XCTAssertEqual(7, [results count]);
        XCTAssertEqualObjects(@"test 3", results[2]);
        XCTAssertEqualObjects(@"", results[6]);
        [results release];
    }
}

- (void)testPreProcessStatement_Empties
{
    @autoreleasepool {
        NSString* statement = @"";
        NSMutableArray<NSString*>* results = [[RCEngine mainEngine] PreProcessStatement:statement];
        XCTAssertEqual(1, [results count]);
        [results release];

        XCTAssertNil([[RCEngine mainEngine] PreProcessStatement:nil]);
    }
}

- (void)testProcessLine_Comment
{
    @autoreleasepool {
        NSString* statement = @"# This is a comment";
        NSArray<NSString*>* results = [[RCEngine mainEngine] ProcessLine:statement];
        XCTAssertEqual(1, [results count]);
        XCTAssertEqualObjects(statement, results[0]);
    }
}

- (void)testProcessLine_MultipleStatements
{
    @autoreleasepool {
        NSString* statement = @"x <- 2; x + 1";
        NSArray<NSString*>* results = [[RCEngine mainEngine] ProcessLine:statement];
        XCTAssertEqual(2, [results count]);
        XCTAssertEqualObjects(@"x <- 2", results[0]);
        XCTAssertEqualObjects(@"x + 1", results[1]);
        [results release];
    }
}

- (void)testProcessLine_Complex
{
    @autoreleasepool {
        NSString* statement = @"paste('this contains ### characters', \" this too ###\", 'Oh, and this # one too') # but \"this\" 'rest' is commented";
        NSArray<NSString*>* results = [[RCEngine mainEngine] ProcessLine:statement];
        XCTAssertEqual(1, [results count]);
        XCTAssertEqualObjects(@"paste('this contains ### characters', \" this too ###\", 'Oh, and this # one too') ", results[0]);
    }
}

- (void)testParse_OK
{
    @autoreleasepool {
        NSString* statement = @"x <- 2; y<-x + 1\r\ny+2";
        NSMutableArray<RCSymbolicExpression*>* results = [[RCEngine mainEngine] Parse:statement];
        XCTAssertEqual(3, [results count]);
    }
}

- (void)testParse_CompleteMultiLine
{
    @autoreleasepool {
        NSString* statement = @"x <-\r\n2";
        NSMutableArray<RCSymbolicExpression*>* results = [[RCEngine mainEngine] Parse:statement];
        XCTAssertEqual(1, [results count]);
    }
}

- (void)testParse_Incomplete
{
    @autoreleasepool {
        @try {
            NSString* statement = @"x <-\r\n";
            [[RCEngine mainEngine] Parse:statement];
            XCTAssertTrue(false);
        }
        @catch (NSException* exc) {
            XCTAssertEqualObjects(exc.description, @"The following expression appears to be incomplete:\r\n'x <-'");
        }
    }
}

- (void)testParse_Invalid
{
    @autoreleasepool {
        @try {
            NSString* statement = @"this really should not work";
            [[RCEngine mainEngine] Parse:statement];
            XCTAssertTrue(false);
        }
        @catch (NSException* exc) {
            XCTAssertEqualObjects(exc.description, @"There was an error interpreting the expression:\r\n'this really should not work'");
        }
    }
}

- (void)testIsClosedString
{
    // Tests taken from R.NET comments in IsClosedString
    @autoreleasepool {
        XCTAssertTrue([[RCEngine mainEngine] IsClosedString:@"paste(\"#hashtag\")"]);
        XCTAssertTrue([[RCEngine mainEngine] IsClosedString:@"paste(\"#hashtag''''\")"]);
        XCTAssertFalse([[RCEngine mainEngine] IsClosedString:@"paste(\"#hashtag'''')"]);
        XCTAssertTrue([[RCEngine mainEngine] IsClosedString:@"paste('#hashtag\"\"\"\"')"]);
        XCTAssertFalse([[RCEngine mainEngine] IsClosedString:@"paste('#hashtag\"\"\"\")"]);
        XCTAssertTrue([[RCEngine mainEngine] IsClosedString:@"paste('#hashtag\"\"#\"\"')"]);
        XCTAssertTrue([[RCEngine mainEngine] IsClosedString:@"paste('#hashtag\"\"#\"\"', \"#hash ''' \")"]);
    }
}

- (void)testEvaluate_NoExpressions
{
    @autoreleasepool {
        RCSymbolicExpression* result = [[RCEngine mainEngine] Evaluate:@""];
        XCTAssertNil(result);

        result = [[RCEngine mainEngine] Evaluate:nil];
        XCTAssertNil(result);
    }
}


- (void)testEvaluate_MultipleExpressions
{
    @autoreleasepool {
        RCSymbolicExpression* result = [[RCEngine mainEngine] Evaluate:@"x <- 2; x + 1"];
        XCTAssertNotNil(result);
    }
}

@end
