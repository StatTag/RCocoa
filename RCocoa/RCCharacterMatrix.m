//
//  RCCharacterMatrix.m
//  RCocoa
//
//  Created by Luke Rasmussen on 5/3/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#include "RCCharacterMatrix.h"
#include <R/Rinternals.h>

@implementation RCCharacterMatrix

-(NSString*) ElementAt: (int)row column:(int)column
{
    [self CheckIndices:row column:column];
    const char* result = CHAR(STRING_PTR(_expression)[(column * [self RowCount]) + row] );
    return [NSString stringWithUTF8String: result];
}

@end
