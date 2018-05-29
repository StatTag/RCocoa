//
//  RCDataFrame.m
//  RCocoa
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDataFrame.h"

@implementation RCDataFrame

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
    
    id element = VECTOR_ELT(_expression, index);
    if (element == nil) {
        return nil;
    }
    
    return [[RCVector alloc] initWithEngineAndExpression:_engine expression:element];
}

-(NSArray<NSString*>*) RowNames
{
    id rowNamesAttr = Rf_getAttrib(_expression, R_RowNamesSymbol);
    if (rowNamesAttr == nil) {
        return nil;
    }
    
    RCSymbolicExpression* namesExp = [[RCSymbolicExpression alloc] initWithEngineAndExpression:_engine expression:rowNamesAttr];
    if (namesExp == nil) {
        return nil;
    }
    
    return [namesExp AsCharacter];
}

-(NSArray<NSString*>*) ColumnNames
{
    return [self Names];
}


-(int) RowCount
{
    if ([self ColumnCount] == 0) {
        return 0;
    }
    
    RCVector* firstRow = (RCVector*)[self objectAtIndexedSubscript:0];
    if (firstRow == nil) {
        return 0;
    }
    
    return [firstRow Length];
}

-(int) ColumnCount
{
    if (_expression == nil) {
        return 0;
    }
    
    return Rf_length(_expression);
}

@end
