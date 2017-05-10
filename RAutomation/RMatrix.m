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
    self = [super initWithEngineAndExpression:eng expression:sexp];
    return self;
}

@end