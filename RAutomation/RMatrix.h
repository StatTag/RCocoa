//
//  RMatrix.h
//  RAutomation
//
//  Created by Luke Rasmussen on 5/3/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#ifndef RMatrix_h
#define RMatrix_h

#import "RSymbolicExpression.h"

@class REngine;

@interface RMatrix<__covariant ObjectType> : RSymbolicExpression
{
}

-(id) initWithEngineAndExpressionAndDimensions: (REngine*)eng expression: (SEXP)sexp rowCount: (unsigned long)rowCount columnCount: (unsigned long)columnCount;

@end


#endif /* RMatrix_h */
