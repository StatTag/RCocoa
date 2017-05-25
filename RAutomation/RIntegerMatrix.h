//
//  RIntegerMatrix.h
//  RAutomation
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#ifndef RIntegerMatrix_h
#define RIntegerMatrix_h

#include "RMatrix.h"

@interface RIntegerMatrix : RMatrix<NSNumber*>
{
    
}

-(int) ElementAt: (int)row column:(int)column;

@end

#endif /* RIntegerMatrix_h */
