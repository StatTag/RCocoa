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
}

-(void) SetVector: (NSArray<NSNumber*>*) values;
- (NSNumber*)objectAtIndexedSubscript:(int)index;

@end

#endif /* RIntegerVector_h */
