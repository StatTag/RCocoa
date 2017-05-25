//
//  RDataFrame.m
//  RAutomation
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDataFrame.h"

@implementation RDataFrame

-(void) SetVector: (NSArray<id>*) values
{
    for (int index = 0; index < [values count]; index++) {
        //int value = [[values objectAtIndex: index] intValue];
        //INTEGER(_expression)[index] = value;
    }
}

-(id)objectAtIndexedSubscript:(int)index
{
    if (index < 0 || index >= LENGTH(_expression)) {
        NSException* exc = [NSException
                            exceptionWithName:@"ArgumentOutOfRangeException"
                            reason:@"Array index out of bounds"
                            userInfo:nil];
        @throw exc;
    }
    
    SEXP element = VECTOR_ELT(_expression, index);
    if (element == nil) {
        return nil;
    }
    
    return [[RVector alloc] initWithEngineAndExpression:_engine expression:element];
}

-(NSArray<NSString*>*) RowNames
{
    SEXP rowNamesAttr = Rf_getAttrib(_expression, R_RowNamesSymbol);
    if (rowNamesAttr == nil) {
        return nil;
    }
    
    RSymbolicExpression* namesExp = [[RSymbolicExpression alloc] initWithEngineAndExpression:_engine expression:rowNamesAttr];
    if (namesExp == nil) {
        return nil;
    }
    
    return [namesExp AsCharacter];
}

-(NSArray<NSString*>*) ColumnNames
{
    return [self Names];
}

@end