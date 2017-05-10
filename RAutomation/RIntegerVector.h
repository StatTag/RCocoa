//
//  RIntegerVector.h
//  RAutomation
//
//  Created by Luke Rasmussen on 5/3/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#ifndef RIntegerVector_h
#define RIntegerVector_h

#include "RVector.h"

@interface RIntegerVector : RVector<NSNumber*>
{
    NSArray<NSNumber*>* _values;
}

-(void) SetVector: (NSArray<NSNumber*>*) values;

@end

#endif /* RIntegerVector_h */
