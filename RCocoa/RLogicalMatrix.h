//
//  RLogicalMatrix.h
//  RAutomation
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#ifndef RLogicalMatrix_h
#define RLogicalMatrix_h

#include "RMatrix.h"

@interface RLogicalMatrix : RMatrix<NSNumber*>
{
    
}

-(BOOL) ElementAt: (int)row column:(int)column;

@end

#endif /* RLogicalMatrix_h */
