//
//  RCIntegerMatrix.m
//  RCocoa
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "RCIntegerMatrix.h"

@implementation RCIntegerMatrix

-(int) ElementAt: (int)row column:(int)column
{
    [self CheckIndices:row column:column];
    int result = INTEGER(_expression)[(row * [self RowCount]) + column];
    return result;
}

@end