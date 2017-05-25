//
//  RDataFrame.h
//  RAutomation
//
//  Created by Luke Rasmussen on 5/16/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#ifndef RDataFrame_h
#define RDataFrame_h

#include "RVector.h"

@interface RDataFrame : RVector<id>
{
}

-(void) SetVector: (NSArray<id>*) values;
- (id)objectAtIndexedSubscript:(int)index;

-(NSArray<NSString*>*) RowNames;
-(NSArray<NSString*>*) ColumnNames;

@end

#endif /* RDataFrame_h */
