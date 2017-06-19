//
//  RCFunction.m
//  RCocoa
//
//  Created by Rasmussen, Luke on 6/19/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "RCFunction.h"

@implementation RCFunction

// Executes the function. Match the function arguments by order.
// Defined in R.NET as abstract method
-(RCSymbolicExpression*) Invoke: (NSArray<RCSymbolicExpression*>*) args
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

// A convenience method to executes the function. Match the function arguments by order,
// after evaluating each to an R expression.
// args - string representation of the arguments; each is evaluated to symbolic expression before being passed as argument to this object (i.e. this Function)
-(RCSymbolicExpression*) InvokeStrArgs: (NSArray<NSString*>*) args
{
    NSMutableArray<RCSymbolicExpression*>* expressionArgs = [[NSMutableArray alloc] initWithCapacity:[args count]];
    for (int index = 0; index < [args count]; index++) {
        [expressionArgs addObject:[_engine Evaluate:args[index]]];
    }
    return [self Invoke:expressionArgs];
}


///// <summary>
///// Executes the function. Match the function arguments by name.
///// </summary>
///// <param name="args">The arguments, indexed by argument name</param>
///// <returns>The result of the function evaluation</returns>
//public abstract SymbolicExpression Invoke(IDictionary<string, SymbolicExpression> args);
//
///// <summary>
///// Executes the function. Match the function arguments by name.
///// </summary>
///// <param name="args">one or more tuples, conceptually a pairlist of arguments. The argument names must be unique</param>
///// <returns>The result of the function evaluation</returns>
//public SymbolicExpression InvokeNamed(params Tuple<string, SymbolicExpression>[] args)
//{
//    return InvokeNamedFast(args);
//    // 2015-01-04 used to call InvokeViaPairlist
//    // If no unforeseen changes (all unit tests pass), just remove this comment
//    // return InvokeViaPairlist(Array.ConvertAll(args, x => x.Item1), Array.ConvertAll(args, x => x.Item2));
//}
//
///// <summary>
///// Executes the function. Match the function arguments by name.
///// </summary>
///// <param name="argNames">The names of the arguments. These can be empty strings for unnamed function arguments</param>
///// <param name="args">The arguments passed to the function</param>
///// <returns></returns>
//protected SymbolicExpression InvokeViaPairlist(string[] argNames, SymbolicExpression[] args)
//{
//    var names = new CharacterVector(Engine, argNames);
//    var arguments = new GenericVector(Engine, args);
//    arguments.SetNames(names);
//    var argPairList = arguments.ToPairlist();
//
//    //IntPtr newEnvironment = Engine.GetFunction<Rf_allocSExp>()(SymbolicExpressionType.Environment);
//    //IntPtr result = Engine.GetFunction<Rf_applyClosure>()(Body.DangerousGetHandle(), handle,
//    //                                                      argPairList.DangerousGetHandle(),
//    //                                                      Environment.DangerousGetHandle(), newEnvironment);
//    return createCallAndEvaluate(argPairList.DangerousGetHandle());
//}
//


-(SEXP) _evaluateCall:(SEXP)call
{
    SEXP result = NULL;
    int errorOccurred = 0;
    @try {
        result = R_tryEval(call, R_GlobalEnv, &errorOccurred);
    }
    @catch (NSException* exc) {
        errorOccurred = 1;
    }

    if (errorOccurred > 0) {
        NSException* exc = [NSException
                            exceptionWithName:@"EvaluationException"
                            reason:@"There was an error evaluating the function call"
                            userInfo:nil];
        @throw exc;
    }

    return result;
}

//// http://msdn.microsoft.com/en-us/magazine/dd419661.aspx
//[HandleProcessCorruptedStateExceptions]
//[SecurityCritical]
//private ProtectedPointer evaluateCall(IntPtr call)
//{
//    ProtectedPointer result;
//    bool errorOccurred = false;
//    try
//    {
//        result = new ProtectedPointer(Engine, Engine.GetFunction<R_tryEval>()(call, Engine.GlobalEnvironment.DangerousGetHandle(), out errorOccurred));
//    }
//    catch (Exception ex) // TODO: this is usually dubious to catch all that, but given the inner exception is preserved
//    {
//        throw new EvaluationException(Engine.LastErrorMessage, ex);
//    }
//    if (errorOccurred)
//        throw new EvaluationException(Engine.LastErrorMessage);
//    return result;
//}
//

-(RCSymbolicExpression*) InvokeOrderedArguments:(NSArray<RCSymbolicExpression*>*) args
{
    SEXP argument = R_NilValue;
    if (args != nil && [args count] > 0) {
        for (int index = ([args count] - 1); index >= 0; index--) {
            argument = Rf_cons([args[index] GetHandle], argument);
        }
    }

    return [self _createCallAndEvaluate:argument];
}

-(RCSymbolicExpression*) _createCallAndEvaluate:(SEXP)argument
{
    SEXP call = Rf_lcons(_expression, argument);
    SEXP result = [self _evaluateCall:call];
    return [[RCSymbolicExpression alloc] initWithEngineAndExpression:_engine expression:result];
}

//
///// <summary>
///// Invoke the function with optionally named arguments by order.
///// </summary>
///// <param name="args">one or more tuples, conceptually a pairlist of arguments.
///// The argument names must be unique; null or empty string indicates unnamed argument. </param>
///// <returns>The result of the function evaluation</returns>
//private SymbolicExpression InvokeNamedFast(params Tuple<string, SymbolicExpression>[] args)
//{
//    IntPtr argument = Engine.NilValue.DangerousGetHandle();
//    var rfInstall = GetFunction<Rf_install>();
//    var rSetTag = GetFunction<SET_TAG>();
//    var rfCons = GetFunction<Rf_cons>();
//    foreach (var arg in args.Reverse())
//    {
//        var sexp = arg.Item2;
//        argument = rfCons(sexp.DangerousGetHandle(), argument);
//        string name = arg.Item1;
//        if (!string.IsNullOrEmpty(name))
//        {
//            rSetTag(argument, rfInstall(name));
//        }
//    }
//    return createCallAndEvaluate(argument);
//}


@end
