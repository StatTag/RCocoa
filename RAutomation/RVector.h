//
//  RVector.h
//  RAutomation
//
//  Created by Luke Rasmussen on 5/3/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#ifndef RVector_h
#define RVector_h

#import "RSymbolicExpression.h"

@class REngine;

@interface RVector<__covariant ObjectType> : RSymbolicExpression
{
}

-(id) initWithEngineAndExpressionAndLength: (REngine*)eng expression: (SEXP)sexp length: (unsigned long)len;
-(void) SetVector: (NSArray<ObjectType>*) values;

@end

#endif /* RVector_h */
