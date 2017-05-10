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

// Type detection methods
-(BOOL) IsVector;
-(BOOL) IsFactor;
-(BOOL) IsMatrix;
//-(BOOL) IsDataFrame;
//-(BOOL) IsS4;
//-(BOOL) IsEnvironment;
//-(BOOL) IsExpression;
//-(BOOL) IsSymbol;
//-(BOOL) IsLanguage;
//-(BOOL) IsFunction;
//-(BOOL) IsFactor;

// Vector conversion methods methods
-(NSArray*) AsInteger;
-(NSArray*) AsReal;
-(NSArray*) AsLogical;
-(NSArray*) AsCharacter;
//(NSArray*) AsNumeric;
//(NSArray*) AsComplex;

// Other conversion methods
//(NSArray*) AsList;
//(NSArray*) AsDataFrame;
//(NSArray*) AsS4;
//(NSArray*) AsVector;
//(NSArray*) AsRaw;
//(NSArray*) AsEnvironment;
//(NSArray*) AsExpression;
//(NSArray*) AsSymbol;
//(NSArray*) AsLanguage;
//(NSArray*) AsFunction;
//(NSArray*) AsFactor;

// Matrix conversion methods
-(NSArray*) AsCharacterMatrix;
//(NSArray*) AsLogicalMatrix;
//(NSArray*) AsIntegerMatrix;
//(NSArray*) AsNumericMatrix;
//(NSArray*) AsComplexMatrix;
//(NSArray*) AsRawMatrix;

@end

#endif /* RSymbolicExpression_h */
