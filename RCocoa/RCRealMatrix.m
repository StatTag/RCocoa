//
//  RCRealMatrix.m
//  RCocoa
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "RCRealMatrix.h"

@implementation RCRealMatrix

-(double) ElementAt: (int)row column:(int)column
{
    [self CheckIndices:row column:column];
    double result = REAL(_expression)[(row * [self RowCount]) + column];
    return result;
}

@end