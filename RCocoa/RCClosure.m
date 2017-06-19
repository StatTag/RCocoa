//
//  RCClosure.m
//  RCocoa
//
//  Created by Rasmussen, Luke on 6/19/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCClosure.h"

@implementation RCClosure


-(RCSymbolicExpression*) Invoke:(NSArray<RCSymbolicExpression *> *)args
{
    return [self InvokeOrderedArguments: args];
}

///// <summary>
///// Invoke this function, using an ordered list of unnamed arguments.
///// </summary>
///// <param name="args">The arguments of the function</param>
///// <returns>The result of the evaluation</returns>
//public override SymbolicExpression Invoke(params SymbolicExpression[] args)
//{
//    //int count = Arguments.Count;
//    //if (args.Length > count)
//    //   throw new ArgumentException("Too many arguments provided for this function", "args");
//    return InvokeOrderedArguments(args);
//}

@end
