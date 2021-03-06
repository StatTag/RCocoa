//
//  RCRealMatrix.m
//  RCocoa
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "RCRealMatrix.h"
#include <R/Rinternals.h>

@implementation RCRealMatrix

-(double) ElementAt: (int)row column:(int)column
{
    [self CheckIndices:row column:column];
    double result = REAL(_expression)[(column * [self RowCount]) + row];
    return result;
}

-(NSString*)ElementDescriptionAtRow: (int)row andColumn:(int)column
{
  return [NSString stringWithFormat:@"%f", [self ElementAt:row column:column]];
}


@end
