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

-(id) initWithEngineAndExpressionAndLength: (RCEngine*)eng expression: (SEXP)sexp length: (int)len
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

-(void) SetVector: (NSArray<id>*) values;
{
    [self doesNotRecognizeSelector:_cmd];
}

-(NSArray<NSString*>*) Names
{
    SEXP names = Rf_getAttrib(_expression, R_NamesSymbol);
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
