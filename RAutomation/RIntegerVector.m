//
//  RIntegerVector.m
//  RAutomation
//
//  Created by Luke Rasmussen on 5/3/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RIntegerVector.h"

@implementation RIntegerVector

-(id) initWithEngineAndExpressionAndLength: (REngine*)eng expression: (SEXP)sexp length: (unsigned long)len
{
    self = [super initWithEngineAndExpressionAndLength:eng expression:sexp length:len];
    _expression = PROTECT(Rf_allocVector(INTSXP, len));
    return self;
}

-(void) SetVector: (NSArray<NSNumber*>*) values
{
    for (int index = 0; index < [values count]; index++) {
        int value = [[values objectAtIndex: index] intValue];
        INTEGER(_expression)[index] = value;
    }
}

-(NSNumber*)objectAtIndexedSubscript:(int)index
{
    if (index < 0 || index >= LENGTH(_expression)) {
        NSException* exc = [NSException
                            exceptionWithName:@"ArgumentOutOfRangeException"
                            reason:@"Array index out of bounds"
                            userInfo:nil];
        @throw exc;
    }
    
    return [NSNumber numberWithInt:INTEGER(_expression)[index]];
}

@end