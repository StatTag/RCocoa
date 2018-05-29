//
//  RCSymbolicExpression.m
//  RCocoa
//
//  Created by Luke Rasmussen on 4/13/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCocoa.h"

@implementation RCSymbolicExpression

void CheckForNullExpression(id expression)
{
    if (expression == nil) {
        NSException* exc = [NSException
                            exceptionWithName:@"ArgumentNullException"
                            reason:@"The expression is null for this object"
                            userInfo:nil];
        @throw exc;
    }
}

+(RCFunction*) _getAsListFunction
{
    static RCFunction *asListFunction = nil;
    if (asListFunction == nil) {
        RCEngine* mainEngine = [RCEngine GetInstance];
        asListFunction = [[mainEngine Evaluate:@"invisible(as.list)"] AsFunction];
    }
    return asListFunction;
}

-(id) initWithEngineAndExpression: (RCEngine*) engine expression: (id)sexp
{
    self = [super init];
    _engine = engine;
    _expression = sexp;
    return self;
}

-(int) Type
{
    return (_expression) ? TYPEOF(_expression) : NILSXP;
}

- (int) Length
{
    if (!_expression) return 0;
    switch (TYPEOF(_expression)) {
        case VECSXP:
        case STRSXP:
        case INTSXP:
        case REALSXP:
        case CPLXSXP:
        case LGLSXP:
        case EXPRSXP:
            return LENGTH(_expression);
    }
    return 1;
}

-(RCEngine*) Engine
{
    return _engine;
}

-(id) GetHandle
{
    return _expression;
}

-(BOOL) IsInvalid
{
  return (_expression == NULL);
}

// Get all attribute value names for this expression.  If no attributes exist,
// a valid, but empty, array will be returned.
-(NSArray<NSString*>*) GetAttributeNames
{
    NSMutableArray<NSString*>* attrs = [[NSMutableArray<NSString*> alloc] init];
    if (_expression != NULL) {
        int length = (int)Rf_length(ATTRIB(_expression));
        id pointer = ATTRIB(_expression);
        for (int index = 0; index < length; index++) {
            id attrib = PRINTNAME(TAG(pointer));
            const char* name = CHAR(Rf_asChar(attrib));
            [attrs addObject:[NSString stringWithUTF8String:name]];
            pointer = CDR(pointer);
        }
    }
    return attrs;
}

-(RCSymbolicExpression*) GetAttribute: (NSString*)name
{
    if (name == nil) {
        NSException* exc = [NSException
                            exceptionWithName:@"ArgumentNullException"
                            reason:@"You must specify an attribute name"
                            userInfo:nil];
        @throw exc;
    }
    
    id installedName = Rf_install([name UTF8String]);
    id attribute = Rf_getAttrib(_expression, installedName);
    RCSymbolicExpression* rsx = [[RCSymbolicExpression alloc] initWithEngineAndExpression:_engine expression:attribute];
    return rsx;
}

// Assign an attribute with corresponding value to this expression
-(void) SetAttribute: (RCSymbolicExpression*) symbol value:(RCSymbolicExpression*) value
{
    if (symbol == nil) {
        NSException* exc = [NSException
                            exceptionWithName:@"ArgumentNullException"
                            reason:@"You must specify a symbolic expression"
                            userInfo:nil];
        @throw exc;
    }
    
    // Make sure it's a symbolic expression
    if ([symbol Type] != SYMSXP) {
        NSException* exc = [NSException
                            exceptionWithName:@"ArgumentException"
                            reason:@"You must specify a symbolic expression"
                            userInfo:nil];
        @throw exc;
    }
    
    if (value == nil) {
        value = [_engine NilValue];
    }
    
    Rf_setAttrib([self GetHandle], [symbol GetHandle], [value GetHandle]);
}

- (RCSymbolicExpression*) ElementAt: (int) index
{
    if (index<0 || index>=LENGTH(_expression)) return nil;
    return [[RCSymbolicExpression alloc] initWithEngineAndExpression: _engine expression:VECTOR_ELT(_expression, index)];
}

-(BOOL) IsVector
{
    CheckForNullExpression(_expression);
    return R_TRUE == Rf_isVector(_expression);
}

-(BOOL) IsFactor
{
    CheckForNullExpression(_expression);
    return R_TRUE == Rf_isFactor(_expression);
}

-(BOOL) IsMatrix
{
    CheckForNullExpression(_expression);
    return R_TRUE == Rf_isMatrix(_expression);
}

-(BOOL) IsDataFrame
{
    CheckForNullExpression(_expression);
    return R_TRUE == Rf_isFrame(_expression);
}

// Gets whether the specified expression is a list
-(BOOL) IsList
{
    // As noted by R.NET library, Rf_isList in the R API is NOT the correct thing to use
    CheckForNullExpression(_expression);
    return ([self Type] == VECSXP) || ([self Type] == LISTSXP && Rf_length(_expression));
}

// Gets whether the specified expression is a function
-(BOOL) IsFunction
{
    // As noted by R.NET library, Rf_isList in the R API is NOT the correct thing to use
    CheckForNullExpression(_expression);
    return R_TRUE == Rf_isFunction(_expression);
}

-(NSArray*) AsInteger
{
    if (![self IsVector]) { return nil; }
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    id coercedVector = Rf_coerceVector(_expression, INTSXP);
    int length = LENGTH(coercedVector);
    int* results = INTEGER(coercedVector);
    for (int i = 0; i < length; ++i) {
        [retVal addObject:[NSNumber numberWithInt:results[i]]];
    }
    return retVal;
}

-(NSArray*) AsReal
{
    if (![self IsVector]) { return nil; }
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    id coercedVector = Rf_coerceVector(_expression, REALSXP);
    int length = LENGTH(coercedVector);
    double* results = REAL(coercedVector);
    for (int i = 0; i < length; ++i) {
        [retVal addObject:[NSNumber numberWithDouble:results[i]]];
    }
    return retVal;
}

-(NSArray*) AsLogical
{
    if (![self IsVector]) { return nil; }
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    id coercedVector = Rf_coerceVector(_expression, LGLSXP);
    int length = LENGTH(coercedVector);
    int* results = LOGICAL(coercedVector);
    for (int i = 0; i < length; ++i) {
        [retVal addObject:[NSNumber numberWithBool:results[i]]];
    }
    return retVal;
}

-(NSArray*) AsCharacter
{
    if (![self IsVector]) { return nil; }
    id coercedVector = nil;
    if ([self IsFactor]) {
        coercedVector = Rf_asCharacterFactor(_expression);
    } else {
        coercedVector = Rf_coerceVector(_expression, STRSXP);
    }
    
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    int length = LENGTH(coercedVector);
    for (int i = 0; i < length; ++i) {
        [retVal addObject:[NSString stringWithUTF8String:CHAR(STRING_PTR(coercedVector)[i])]];
    }
    return retVal;
}

-(RCDataFrame*) AsDataFrame
{
    if (![self IsVector]) { return nil; }
    RCDataFrame* dataFrame = [[RCDataFrame alloc] initWithEngineAndExpression: _engine expression:_expression];
    return dataFrame;
}

-(RCVector*) AsList
{
    if (![self IsList]) { return nil; }
    RCFunction* asList = [RCSymbolicExpression _getAsListFunction];
    NSArray<RCSymbolicExpression*>* args = @[self];
    RCSymbolicExpression* newExpression = [asList Invoke:args];
    return [[RCVector alloc] initWithEngineAndExpression:_engine expression:[newExpression GetHandle]];
}

-(RCFunction*) AsFunction
{
    if (![self IsFunction]) { return nil; }

    switch ([self Type]) {
        case CLOSXP:
            return [[RCClosure alloc] initWithEngineAndExpression: _engine expression:_expression];
        case BUILTINSXP:
            return [[RCBuiltinFunction alloc] initWithEngineAndExpression: _engine expression:_expression];
        case SPECIALSXP:
            return [[RCSpecialFunction alloc] initWithEngineAndExpression: _engine expression:_expression];
        default: {
            NSException* exc = [NSException
                                exceptionWithName:@"ArgumentException"
                                reason:@"The expression is not a function"
                                userInfo:nil];
            @throw exc;
        }
    }
}


// Helper function to build the R internal representation of a matrix dimension, and assign it withing
// the matrix expression.
void SetMatrixDimensions(RCMatrix* matrix, RCEngine* engine, int rowCount, int columnCount)
{
    NSMutableArray<NSNumber*>* dimensionArray = [[NSMutableArray<NSNumber*> alloc] initWithCapacity: 2];
    dimensionArray[0] = [NSNumber numberWithInt:rowCount];
    dimensionArray[1] = [NSNumber numberWithInt:columnCount];
    RCIntegerVector* dimensionVector = [[RCIntegerVector alloc] initWithEngineAndExpressionAndLength:engine expression:nil length:[dimensionArray count]];
    [dimensionVector SetVector:dimensionArray];
    RCSymbolicExpression* dimSymbolExpr = [[RCSymbolicExpression alloc] initWithEngineAndExpression:engine expression:R_DimSymbol];
    [matrix SetAttribute:dimSymbolExpr value:dimensionVector];
}

-(RCCharacterMatrix*) AsCharacterMatrix
{
    if (![self IsVector]) { return nil; }
    
    int rowCount = 0;
    int columnCount = 0;
    if ([self IsMatrix]) {
        if (TYPEOF(_expression) == STRSXP) {
            RCCharacterMatrix* matrix = [[RCCharacterMatrix alloc] initWithEngineAndExpression:_engine expression:_expression];
            return matrix;
        }
        else {
            rowCount = Rf_nrows(_expression);
            columnCount = Rf_ncols(_expression);
        }
    }
    
    if (columnCount == 0) {
        rowCount = Rf_length(_expression);
        columnCount = 1;
    }
    
    id coercedVector = Rf_coerceVector(_expression, STRSXP);
    RCCharacterMatrix* matrix = [[RCCharacterMatrix alloc] initWithEngineAndExpression:_engine expression:coercedVector];
    SetMatrixDimensions(matrix, _engine, rowCount, columnCount);
    return matrix;
}

-(RCLogicalMatrix*) AsLogicalMatrix
{
    if (![self IsVector]) { return nil; }
    
    int rowCount = 0;
    int columnCount = 0;
    if ([self IsMatrix]) {
        if (TYPEOF(_expression) == LGLSXP) {
            RCLogicalMatrix* matrix = [[RCLogicalMatrix alloc] initWithEngineAndExpression:_engine expression:_expression];
            return matrix;
        }
        else {
            rowCount = Rf_nrows(_expression);
            columnCount = Rf_ncols(_expression);
        }
    }
    
    if (columnCount == 0) {
        rowCount = Rf_length(_expression);
        columnCount = 1;
    }
    
    id coercedVector = Rf_coerceVector(_expression, LGLSXP);
    RCLogicalMatrix* matrix = [[RCLogicalMatrix alloc] initWithEngineAndExpression:_engine expression:coercedVector];
    SetMatrixDimensions(matrix, _engine, rowCount, columnCount);
    return matrix;
}

-(RCIntegerMatrix*) AsIntegerMatrix
{
    if (![self IsVector]) { return nil; }
    
    int rowCount = 0;
    int columnCount = 0;
    if ([self IsMatrix]) {
        if (TYPEOF(_expression) == INTSXP) {
            RCIntegerMatrix* matrix = [[RCIntegerMatrix alloc] initWithEngineAndExpression:_engine expression:_expression];
            return matrix;
        }
        else {
            rowCount = Rf_nrows(_expression);
            columnCount = Rf_ncols(_expression);
        }
    }
    
    if (columnCount == 0) {
        rowCount = Rf_length(_expression);
        columnCount = 1;
    }
    
    id coercedVector = Rf_coerceVector(_expression, INTSXP);
    RCIntegerMatrix* matrix = [[RCIntegerMatrix alloc] initWithEngineAndExpression:_engine expression:coercedVector];
    SetMatrixDimensions(matrix, _engine, rowCount, columnCount);
    return matrix;
}

-(RCRealMatrix*) AsRealMatrix
{
    if (![self IsVector]) { return nil; }
    
    int rowCount = 0;
    int columnCount = 0;
    if ([self IsMatrix]) {
        if (TYPEOF(_expression) == REALSXP) {
            RCRealMatrix* matrix = [[RCRealMatrix alloc] initWithEngineAndExpression:_engine expression:_expression];
            return matrix;
        }
        else {
            rowCount = Rf_nrows(_expression);
            columnCount = Rf_ncols(_expression);
        }
    }
    
    if (columnCount == 0) {
        rowCount = Rf_length(_expression);
        columnCount = 1;
    }
    
    id coercedVector = Rf_coerceVector(_expression, REALSXP);
    RCRealMatrix* matrix = [[RCRealMatrix alloc] initWithEngineAndExpression:_engine expression:coercedVector];
    SetMatrixDimensions(matrix, _engine, rowCount, columnCount);
    return matrix;
}

@end
