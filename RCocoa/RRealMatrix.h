//
//  RRealMatrix.h
//  RAutomation
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#ifndef RRealMatrix_h
#define RRealMatrix_h

#include "RMatrix.h"

@interface RRealMatrix : RMatrix<NSNumber*>
{
    
}

-(double) ElementAt: (int)row column:(int)column;

@end

#endif /* RRealMatrix_h */
