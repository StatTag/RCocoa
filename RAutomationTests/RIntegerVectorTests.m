//
//  RIntegerVectorTests.m
//  RAutomation
//
//  Created by Luke Rasmussen on 5/12/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RIntegerVector.h"

@interface RIntegerVectorTests : XCTestCase

@end

@implementation RIntegerVectorTests

- (void)setUp {
    [super setUp];
    [[REngine mainEngine] activate];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSetVector {
    NSMutableArray<NSNumber*>* vector = [[NSMutableArray alloc] initWithCapacity:3];
    [vector insertObject:[NSNumber numberWithInt:5] atIndex:0];
    [vector insertObject:[NSNumber numberWithInt:10] atIndex:1];
    [vector insertObject:[NSNumber numberWithInt:15] atIndex:2];
    
    RIntegerVector* intVector = [[RIntegerVector alloc] initWithEngineAndExpressionAndLength:[REngine mainEngine] expression:nil length:3];
    [intVector SetVector:vector];
    XCTAssertEqual(5, [intVector[0] intValue]);
    XCTAssertEqual(10, [intVector[1] intValue]);
    XCTAssertEqual(15, [intVector[2] intValue]);
}

- (void)testSubscriptOutOfRange {
    RIntegerVector* intVector = [[RIntegerVector alloc] initWithEngineAndExpressionAndLength:[REngine mainEngine] expression:nil length:1];
    XCTAssertThrows(intVector[-1]);
    XCTAssertThrows(intVector[1]);
}

@end
