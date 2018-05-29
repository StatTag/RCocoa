//
//  RCVector.m
//  RCocoa
//
//  Created by Luke Rasmussen on 5/3/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCVector.h"

@implementation RCVector

-(id) initWithEngineAndExpressionAndLength: (RCEngine*)eng expression: (id)sexp length: (int)len
{
    if (len <= 0) {
        NSException* exc = [NSException
                            exceptionWithName:@"ArgumentOutOfRangeException"
                            reason:@"Length must be greater than 0"
                            userInfo:nil];
        @throw exc;
    }
    
    self = [super initWithEngineAndExpression:eng expression:sexp];
    
    return self;
}

// Abstract method (requires implementation)
-(void) SetVector: (NSArray<id>*) values;
{
    [self doesNotRecognizeSelector:_cmd];
}

// Get the element at a specific index.  While an id type is returned for the base
// RCVector, it will be an RCSymbolicExpression.  Inherited classes will return
// more specific types.
-(id) ElementAt: (int)index
{
    if (index < 0 || index >= [self Length]) {
        NSException* exc = [NSException
                            exceptionWithName:@"ArgumentOutOfRangeException"
                            reason:@"Index is out of range"
                            userInfo:nil];
        @throw exc;
    }

    return [[RCSymbolicExpression alloc] initWithEngineAndExpression:_engine expression:VECTOR_ELT(_expression, index)];
}

// The use of the R_xlen_t here will allow us to support long vectors
-(R_xlen_t) Length
{
    return Rf_xlength(_expression);
}

-(NSArray<NSString*>*) Names
{
    id names = Rf_getAttrib(_expression, R_NamesSymbol);
    if (names == nil) {
        return nil;
    }
    
    RCSymbolicExpression* namesExp = [[RCSymbolicExpression alloc] initWithEngineAndExpression:_engine expression:names];
    if (namesExp == nil) {
        return nil;
    }
    
    return [namesExp AsCharacter];
}


@end
