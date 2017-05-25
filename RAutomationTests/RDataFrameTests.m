//
//  RDataFrameTests.m
//  RAutomation
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "RAutomation.h"


@interface RDataFrameTests : XCTestCase

@end

@implementation RDataFrameTests

- (void)setUp {
    [super setUp];
    [[REngine mainEngine] activate];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [REngine shutdown];
}

- (void)testDataFrame_ColumnNames {
    @autoreleasepool {
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"n = c(1,2)\n s=c('a','b')\n df = data.frame(n, s)"];
        RDataFrame* dataFrame = [rse AsDataFrame];
        NSArray<NSString*>* names = [dataFrame ColumnNames];
        XCTAssertEqual(2, [names count]);
        XCTAssertEqualObjects(@"n", names[0]);
        XCTAssertEqualObjects(@"s", names[1]);
        [names release];
        [dataFrame release];
        [rse release];
    }
}

- (void)testDataFrame_ColumnAccess {
    @autoreleasepool {
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"n = c(1,2)\n s=c('a','b')\n df = data.frame(n, s)"];
        RDataFrame* dataFrame = [rse AsDataFrame];
        NSArray<NSString*>* names = [(RVector*)dataFrame[1] AsCharacter];
        XCTAssertNotNil(names);
        XCTAssertEqual(2, [names count]);
        XCTAssertEqualObjects(@"a", names[0]);
        XCTAssertEqualObjects(@"b", names[1]);
        [names release];

        NSArray<NSNumber*>* values = [(RVector*)dataFrame[0] AsInteger];
        XCTAssertNotNil(values);
        XCTAssertEqual(2, [values count]);
        XCTAssertEqual(1, [values[0] integerValue]);
        XCTAssertEqual(2, [values[1] integerValue]);
        [values release];

        [dataFrame release];
        [rse release];
    }
}


- (void)testDataFrame_RowNames {
    @autoreleasepool {
        RSymbolicExpression* rse = [[REngine mainEngine] Evaluate: @"n = c(1,2)\n s=c('a','b')\n df = data.frame(n, s)"];
        RDataFrame* dataFrame = [rse AsDataFrame];
        NSArray<NSString*>* names = [dataFrame RowNames];
        XCTAssertEqual(2, [names count]);
        XCTAssertEqualObjects(@"1", names[0]);
        XCTAssertEqualObjects(@"2", names[1]);
        [names release];
        [dataFrame release];
        [rse release];
    }
}

@end
