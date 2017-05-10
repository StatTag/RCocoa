//
//  RSymbolicExpression.m
//  RAutomation
//
//  Created by Luke Rasmussen on 4/13/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RAutomation.h"

@implementation RSymbolicExpression

void CheckForNullExpression(SEXP expression)
{
    if (expression == nil) {
        NSException* exc = [NSException
                            exceptionWithName:@"ArgumentNullException"
                            reason:@"The expression is null for this object"
                            userInfo:nil];
        @throw exc;
    }
}

-(id) initWithEngineAndExpression: (REngine*) engine expression: (SEXP)sexp
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

-(REngine*) Engine
{
    return _engine;
}

-(SEXP) GetHandle
{
    return _expression;
}

-(BOOL) IsInvalid
{
  return (_expression == NULL);
}

-(NSArray<NSString*>*) GetAttributeNames
{
    NSMutableArray<NSString*>* attrs = [[NSMutableArray<NSString*> alloc] init];
    if (_expression != NULL) {
        int length = (int)Rf_length(ATTRIB(_expression));
        for (int index = 0; index < length; index++) {
            //struct SEXPREC attribute = (struct SEXPREC) (*_expression);
        }
    }
    return attrs;
}

- (RSymbolicExpression*) ElementAt: (int) index
{
    if (index<0 || index>=LENGTH(_expression)) return nil;
    return [[RSymbolicExpression alloc] initWithEngineAndExpression: _engine expression:VECTOR_ELT(_expression, index)];
}

-(BOOL) IsVector
{
    CheckForNullExpression(_expression);
    return TRUE == Rf_isVector(_expression);
}

-(BOOL) IsFactor
{
    CheckForNullExpression(_expression);
    return TRUE == Rf_isFactor(_expression);
}

-(BOOL) IsMatrix
{
    CheckForNullExpression(_expression);
    return TRUE == Rf_isMatrix(_expression);
}

-(NSArray*) AsInteger
{
    if (![self IsVector]) { return nil; }
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    SEXP coercedVector = Rf_coerceVector(_expression, INTSXP);
    int length = LENGTH(coercedVector);
    int* results = INTEGER(coercedVector);
    for (int i = 0; i < length; ++i) {
        [retVal addObject:[NSNumber numberWithInt:results[i]]];
    }
    return [retVal copy];
}

-(NSArray*) AsReal
{
    if (![self IsVector]) { return nil; }
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    SEXP coercedVector = Rf_coerceVector(_expression, REALSXP);
    int length = LENGTH(coercedVector);
    double* results = REAL(coercedVector);
    for (int i = 0; i < length; ++i) {
        [retVal addObject:[NSNumber numberWithDouble:results[i]]];
    }
    return [retVal copy];
}

-(NSArray*) AsLogical
{
    if (![self IsVector]) { return nil; }
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    SEXP coercedVector = Rf_coerceVector(_expression, LGLSXP);
    int length = LENGTH(coercedVector);
    int* results = LOGICAL(coercedVector);
    for (int i = 0; i < length; ++i) {
        [retVal addObject:[NSNumber numberWithBool:results[i]]];
    }
    return [retVal copy];
}

-(NSArray*) AsCharacter
{
    if (![self IsVector]) { return nil; }
    SEXP coercedVector = nil;
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

-(NSArray*) AsCharacterMatrix
{
    if (![self IsVector]) { return nil; }
    
    int rowCount = 0;
    int columnCount = 0;
    if ([self IsMatrix]) {
        if (TYPEOF(_expression) == STRSXP) {
            //TODO: return new CharacterMatrix(expression.Engine, expression.DangerousGetHandle());
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
    
    SEXP coercedVector = Rf_coerceVector(_expression, STRSXP);
    NSMutableArray<NSNumber*>* dimensionArray = [[NSMutableArray<NSNumber*> alloc] initWithCapacity: 2];
    dimensionArray[0] = [NSNumber numberWithInt:rowCount];
    dimensionArray[1] = [NSNumber numberWithInt:columnCount];
    RIntegerVector* dimensionVector = [[RIntegerVector alloc] initWithEngineAndExpressionAndLength:_engine expression:nil length:[dimensionArray count]];
    [dimensionVector SetVector:dimensionArray];
    
    //RCharacterMatrix* matrix = [[RCharacterMatrix alloc] init];
    
    return nil;
//    IntPtr coerced = expression.GetFunction<Rf_coerceVector>()(expression.DangerousGetHandle(), SymbolicExpressionType.CharacterVector);
//    var dim = new IntegerVector(expression.Engine, new[] { rowCount, columnCount });
//    SymbolicExpression dimSymbol = expression.Engine.GetPredefinedSymbol("R_DimSymbol");
//    var matrix = new CharacterMatrix(expression.Engine, coerced);
//    matrix.SetAttribute(dimSymbol, dim);
//    return matrix;
}

@end