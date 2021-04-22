//
//  RCSymbolicExpression.h
//  RCocoa
//
//  Created by Luke Rasmussen on 4/13/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#ifndef RCSymbolicExpression_h
#define RCSymbolicExpression_h

//#include <R/Rinternals.h>

/*
 Note on memory management
 Some of the methods have a ns_returns_retained attribute as part of their definition (https://clang.llvm.org/docs/AutomaticReferenceCounting.html#retained-return-values).  This tells an app calling this framework that it is responsible for cleaning up the returned value.  Per the Apple documentation, this should let ARC know (assuming the framework is called from an ARC-enabled application) that it is responsible for releasing and cleaning the object it receives.
 */

@class RCEngine;
@class RCCharacterMatrix;
@class RCLogicalMatrix;
@class RCIntegerMatrix;
@class RCRealMatrix;
@class RCDataFrame;
@class RCVector;
@class RCFunction;
@class RCClosure;
@class RCBuiltinFunction;
@class RCSpecialFunction;

@interface RCSymbolicExpression : NSObject
{
    id _expression;
    RCEngine* _engine;
    bool isProtected;
}

+(RCFunction*) _getAsListFunction;

-(id) initWithEngineAndExpression: (RCEngine*)eng expression: (id)sexp;

// Gets the symbolic expression type
-(int) Type;

// Gets the length of the expression
-(int) Length;

// Gets the RCEngine to which this expression belongs
-(RCEngine*) Engine;

// Is the handle of this SEXP invalid (zero, i.e. null pointer)
-(BOOL) IsInvalid;

// Get all attribute value names
-(NSArray<NSString*>*) GetAttributeNames __attribute((ns_returns_retained));

// Get a specific attribute
-(RCSymbolicExpression*) GetAttribute: (NSString*)name __attribute((ns_returns_retained));

// Set an attribute
-(void) SetAttribute: (RCSymbolicExpression*) symbol value:(RCSymbolicExpression*) value;

// Get the underlying SEXP pointer
-(id) GetHandle;

// Type detection methods
-(BOOL) IsVector;
-(BOOL) IsFactor;
-(BOOL) IsMatrix;
-(BOOL) IsDataFrame;
-(BOOL) IsList;
//-(BOOL) IsS4;
//-(BOOL) IsEnvironment;
//-(BOOL) IsExpression;
//-(BOOL) IsSymbol;
//-(BOOL) IsLanguage;
-(BOOL) IsFunction;
//-(BOOL) IsFactor;

// Vector conversion methods methods
-(NSArray*) AsInteger __attribute((ns_returns_retained));
-(NSArray*) AsReal __attribute((ns_returns_retained));
-(NSArray*) AsLogical __attribute((ns_returns_retained));
-(NSArray*) AsCharacter __attribute((ns_returns_retained));
//(NSArray*) AsNumeric;
//(NSArray*) AsComplex;

// Other conversion methods
-(RCVector*) AsList;
-(RCDataFrame*) AsDataFrame;
//(NSArray*) AsS4;
//(NSArray*) AsVector;
//(NSArray*) AsRaw;
//(NSArray*) AsEnvironment;
//(NSArray*) AsExpression;
//(NSArray*) AsSymbol;
//(NSArray*) AsLanguage;
-(RCFunction*) AsFunction;
//(NSArray*) AsFactor;

// Matrix conversion methods
-(RCIntegerMatrix*) AsIntegerMatrix __attribute((ns_returns_retained));
-(RCRealMatrix*) AsRealMatrix __attribute((ns_returns_retained));
-(RCCharacterMatrix*) AsCharacterMatrix __attribute((ns_returns_retained));
-(RCLogicalMatrix*) AsLogicalMatrix __attribute((ns_returns_retained));
//(NSArray*) AsNumericMatrix;
//(NSArray*) AsComplexMatrix;
//(NSArray*) AsRawMatrix;

//FIXME: this is NOT ideal, but we want to mask RInternals, so we're redefining the enums/typedefs
//taken from RInternals.h so we can share without having to import the RInternals.h in the host framework/applicaiton
//prefix is required because of the variable conflict
typedef NS_ENUM(NSUInteger, RC_SEXPTYPE) {
  RC_NILSXP  = 0,  /* nil = NULL */
  RC_SYMSXP  = 1,  /* symbols */
  RC_LISTSXP  = 2,  /* lists of dotted pairs */
  RC_CLOSXP  = 3,  /* closures */
  RC_ENVSXP  = 4,  /* environments */
  RC_PROMSXP  = 5,  /* promises: [un]evaluated closure arguments */
  RC_LANGSXP  = 6,  /* language constructs (special lists) */
  RC_SPECIALSXP  = 7,  /* special forms */
  RC_BUILTINSXP  = 8,  /* builtin non-special forms */
  RC_CHARSXP  = 9,  /* "scalar" string type (internal only)*/
  RC_LGLSXP  = 10,  /* logical vectors */
  RC_INTSXP  = 13,  /* integer vectors */
  RC_REALSXP  = 14,  /* real variables */
  RC_CPLXSXP  = 15,  /* complex variables */
  RC_STRSXP  = 16,  /* string vectors */
  RC_DOTSXP  = 17,  /* dot-dot-dot object */
  RC_ANYSXP  = 18,  /* make "any" args work */
  RC_VECSXP  = 19,  /* generic vectors */
  RC_EXPRSXP  = 20,  /* expressions vectors */
  RC_BCODESXP  = 21,  /* byte code */
  RC_EXTPTRSXP  = 22,  /* external pointer */
  RC_WEAKREFSXP  = 23,  /* weak reference */
  RC_RAWSXP  = 24,  /* raw bytes */
  RC_S4SXP  = 25,  /* S4 non-vector */

  RC_NEWSXP      = 30,   /* fresh node creaed in new page */
  RC_FREESXP     = 31,   /* node released by GC */

  RC_FUNSXP  = 99,  /* Closure or Builtin */
};


@end

#endif /* RCSymbolicExpression_h */
