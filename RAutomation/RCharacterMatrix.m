//
//  RCharacterMatrix.m
//  RAutomation
//
//  Created by Luke Rasmussen on 5/3/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "RCharacterMatrix.h"

@implementation RCharacterMatrix

-(NSString*) ElementAt: (int)row column:(int)column
{
    [self CheckIndices:row column:column];
    const char* result = CHAR(STRING_PTR(_expression)[(row * [self RowCount]) + column]);
    return [NSString stringWithUTF8String: result];
}

@end