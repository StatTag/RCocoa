//
//  RCVector.h
//  RCocoa
//
//  Created by Luke Rasmussen on 5/3/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#ifndef RCVector_h
#define RCVector_h

#import "RCSymbolicExpression.h"

@class RCEngine;

@interface RCVector<__covariant ObjectType> : RCSymbolicExpression
{
}

-(id) initWithEngineAndExpressionAndLength: (RCEngine*)eng expression: (SEXP)sexp length: (int)len;
-(void) SetVector: (NSArray<ObjectType>*) values;
-(NSArray<NSString*>*) Names;

@end

#endif /* RCVector_h */
