//
//  RLogicalMatrix.m
//  RAutomation
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "RLogicalMatrix.h"

@implementation RLogicalMatrix

-(BOOL) ElementAt: (int)row column:(int)column
{
    [self CheckIndices:row column:column];
    bool result = LOGICAL(_expression)[(row * [self RowCount]) + column];
    return result;
}

@end