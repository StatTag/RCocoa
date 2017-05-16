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

/*
 Note on memory management
 Some of the methods have a ns_returns_retained attribute as part of their definition (https://clang.llvm.org/docs/AutomaticReferenceCounting.html#retained-return-values).  This tells an app calling this framework that it is responsible for cleaning up the returned value.  Per the Apple documentation, this should let ARC know (assuming the framework is called from an ARC-enabled application) that it is responsible for releasing and cleaning the object it receives.
 */

@class REngine;
@class RCharacterMatrix;
@class RLogicalMatrix;

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

// Set an attribute
-(void) SetAttribute: (RSymbolicExpression*) symbol value:(RSymbolicExpression*) value;

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
-(NSArray*) AsInteger __attribute((ns_returns_retained));
-(NSArray*) AsReal __attribute((ns_returns_retained));
-(NSArray*) AsLogical __attribute((ns_returns_retained));
-(NSArray*) AsCharacter __attribute((ns_returns_retained));
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
-(RCharacterMatrix*) AsCharacterMatrix __attribute((ns_returns_retained));
-(RLogicalMatrix*) AsLogicalMatrix __attribute((ns_returns_retained));
//(NSArray*) AsIntegerMatrix;
//(NSArray*) AsNumericMatrix;
//(NSArray*) AsComplexMatrix;
//(NSArray*) AsRawMatrix;

@end

#endif /* RSymbolicExpression_h */
