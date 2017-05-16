//
//  RMatrix.m
//  RAutomation
//
//  Created by Luke Rasmussen on 5/3/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMatrix.h"

@implementation RMatrix

-(id) initWithEngineAndExpressionAndDimensions: (REngine*)eng expression: (SEXP)sexp rowCount: (unsigned long)rowCount columnCount: (unsigned long)columnCount
{
    if (rowCount <= 0) {
        NSException* exc = [NSException
                            exceptionWithName:@"ArgumentOutOfRangeException"
                            reason:@"Row count must be greater than 0"
                            userInfo:nil];
        @throw exc;
    }
    
    if (columnCount <= 0) {
        NSException* exc = [NSException
                            exceptionWithName:@"ArgumentOutOfRangeException"
                            reason:@"Column count must be greater than 0"
                            userInfo:nil];
        @throw exc;
    }
    
    self = [super initWithEngineAndExpression:eng expression:sexp];
    
    // Allocate the matrix with the appropriate dimensions
    _values = [[NSMutableArray alloc] initWithCapacity: rowCount];
    for (int index = 0; index < rowCount; index++) {
        [_values insertObject:[[NSMutableArray alloc] initWithCapacity:columnCount] atIndex:index];
    }
    
    return self;
}

-(int) RowCount
{
    return Rf_nrows(_expression);
}

-(int) ColumnCount
{
    return Rf_ncols(_expression);
}

-(id) ElementAt: (int)row column:(int)column;
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void) CheckIndices: (int)row column:(int)column
{
    if (column < 0 || column >= [self ColumnCount]) {
        NSException* exc = [NSException
                            exceptionWithName:@"ArgumentOutOfRangeException"
                            reason:@"Column is out of range"
                            userInfo:nil];
        @throw exc;
    }
    
    if (row < 0 || row >= [self RowCount]) {
        NSException* exc = [NSException
                            exceptionWithName:@"ArgumentOutOfRangeException"
                            reason:@"Row is out of range"
                            userInfo:nil];
        @throw exc;
    }
}
@end