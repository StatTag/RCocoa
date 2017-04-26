//
//  RSymbolicExpression.h
//  RAutomation
//
//  Created by Luke Rasmussen on 4/13/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#ifndef RSymbolicExpression_h
#define RSymbolicExpression_h

#include <Rinternals.h>
//#include "RSEXP.h"
//#include "REngine.h"

@class REngine;

@interface RSymbolicExpression : NSObject
{
    SEXP _expression;
    REngine* _engine;
    bool isProtected;
}

-(id) initWithEngineAndExpression: (REngine*)eng expression: (SEXP)sexp;

// Gets the symbolic expression type
-(int) Type;

// Gets the length of the expression
-(int) Length;

// Gets the REngine to which this expression belongs
-(REngine*) Engine;

// Is the handle of this SEXP invalid (zero, i.e. null pointer)
-(BOOL) IsInvalid;

// Get all attribute value names
-(NSArray<NSString*>*) GetAttributeNames;

// Get the underlying SEXP pointer
-(SEXP) GetHandle;

@end

#endif /* RSymbolicExpression_h */
