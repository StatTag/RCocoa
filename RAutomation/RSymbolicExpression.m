//
//  RSymbolicExpression.m
//  RAutomation
//
//  Created by Luke Rasmussen on 4/13/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSymbolicExpression.h"

@implementation RSymbolicExpression

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

@end