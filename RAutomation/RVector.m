//
//  RVector.m
//  RAutomation
//
//  Created by Luke Rasmussen on 5/3/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RVector.h"

@implementation RVector

-(id) initWithEngineAndExpressionAndLength: (REngine*)eng expression: (SEXP)sexp length: (unsigned long)len
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

@end
