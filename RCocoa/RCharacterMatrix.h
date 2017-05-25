//
//  RCharacterMatrix.h
//  RAutomation
//
//  Created by Luke Rasmussen on 5/3/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#ifndef RCharacterMatrix_h
#define RCharacterMatrix_h

#include "RMatrix.h"

@interface RCharacterMatrix : RMatrix<NSString*>
{
    
}

-(NSString*) ElementAt: (int)row column:(int)column;

@end

#endif /* RCharacterMatrix_h */
