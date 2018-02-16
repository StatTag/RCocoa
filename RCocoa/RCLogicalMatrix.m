//
//  RCLogicalMatrix.m
//  RCocoa
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "RCLogicalMatrix.h"

@implementation RCLogicalMatrix

-(BOOL) ElementAt: (int)row column:(int)column
{
    [self CheckIndices:row column:column];
    bool result = LOGICAL(_expression)[(column * [self RowCount]) + row];
    return result;
}

-(NSString*)ElementDescriptionAtRow: (int)row andColumn:(int)column
{
  return [NSString stringWithFormat:@"%@", ([self ElementAt:row column:column]? @"YES" : @"NO")];
}


@end
