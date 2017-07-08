//
//  RCDeviceTests.m
//  RCocoa
//
//  Created by Luke Rasmussen on 7/7/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCICharacterDevice.h"
#import "RCEngine.h"


@interface TestDevice : NSObject<RCICharacterDevice>
{
    BOOL _wasCalled;
}
@property (nonatomic) BOOL WasCalled;
-(void)WriteConsole:(const char*)buffer length:(int)length;
-(void) WriteConsoleEx:(const char*)buffer length:(int)length otype:(int)otype;
@end

@implementation TestDevice
@synthesize WasCalled = _wasCalled;
-(void)WriteConsole:(const char*)buffer length:(int)length
{
    _wasCalled = true;
}

-(void) WriteConsoleEx:(const char*)buffer length:(int)length otype:(int)otype
{
    _wasCalled = true;
}
@end


@interface RCDeviceTests : XCTestCase
@end

@implementation RCDeviceTests

TestDevice* device = nil;
RCEngine* mainEngine = nil;

+ (void)setUp {
    [super setUp];
    device = [[TestDevice alloc] init];
    mainEngine = [RCEngine GetInstance:(RCICharacterDevice*)device];
}

// Right now there's a problem - this test has to be run totally by itself.  If any other tests are
// run, they initialize the singleton RCEngine that is accessed by everyone else.  This means we
// don't have a chance to pass in the custom device we need to use.  So, if we run the test suite
// this will fail - as expected.  Run this test class separately and it should work.
// TODO: fix this issue, we should be able to run the whole test suite.
- (void)testCustomDevice
{
    @autoreleasepool {
        RCSymbolicExpression* result = [mainEngine Evaluate:@"x <- 2; x + 1"];
        XCTAssertNotNil(result);
        XCTAssertTrue([device WasCalled]);
    }
}

@end
