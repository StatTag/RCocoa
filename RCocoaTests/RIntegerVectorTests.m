//
//  RCIntegerVectorTests.m
//  RCocoa
//
//  Created by Luke Rasmussen on 5/12/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCIntegerVector.h"

@interface RCIntegerVectorTests : XCTestCase

@end

@implementation RCIntegerVectorTests

- (void)testSetVector {
    NSMutableArray<NSNumber*>* vector = [[NSMutableArray alloc] initWithCapacity:3];
    [vector insertObject:[NSNumber numberWithInt:5] atIndex:0];
    [vector insertObject:[NSNumber numberWithInt:10] atIndex:1];
    [vector insertObject:[NSNumber numberWithInt:15] atIndex:2];

    RCEngine* mainEngine = [RCEngine GetInstance];
    RCIntegerVector* intVector = [[RCIntegerVector alloc] initWithEngineAndExpressionAndLength:mainEngine expression:nil length:3];
    [intVector SetVector:vector];
    XCTAssertEqual(5, [intVector[0] intValue]);
    XCTAssertEqual(10, [intVector[1] intValue]);
    XCTAssertEqual(15, [intVector[2] intValue]);
}

- (void)testSubscriptOutOfRange {
    RCEngine* mainEngine = [RCEngine GetInstance];
    RCIntegerVector* intVector = [[RCIntegerVector alloc] initWithEngineAndExpressionAndLength:mainEngine expression:nil length:1];
    XCTAssertThrows(intVector[-1]);
    XCTAssertThrows(intVector[1]);
}

@end
