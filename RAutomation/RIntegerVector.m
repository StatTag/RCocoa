//
//  RIntegerVector.m
//  RAutomation
//
//  Created by Luke Rasmussen on 5/3/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RIntegerVector.h"

@implementation RIntegerVector

-(id) initWithEngineAndExpressionAndLength: (REngine*)eng expression: (SEXP)sexp length: (int)len
{
    self = [super initWithEngineAndExpressionAndLength:eng expression:sexp length:len];
    return self;
}

-(void) SetVector: (NSArray<NSNumber*>*) values
{
    _values = [values copy];
}

@end