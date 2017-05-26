/*
 *  R.app : a Cocoa front end to: "R A Computer Language for Statistical Data Analysis"
 *  
 *  R.app Copyright notes:
 *                     Copyright (C) 2004-5  The R Foundation
 *                     written by Stefano M. Iacus and Simon Urbanek
 *
 *                  
 *  R Copyright notes:
 *                     Copyright (C) 1995-1996   Robert Gentleman and Ross Ihaka
 *                     Copyright (C) 1998-2001   The R Development Core Team
 *                     Copyright (C) 2002-2004   The R Foundation
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  A copy of the GNU General Public License is available via WWW at
 *  http://www.gnu.org/copyleft/gpl.html.  You can also obtain it by
 *  writing to the Free Software Foundation, Inc., 59 Temple Place,
 *  Suite 330, Boston, MA  02111-1307  USA.
 *
 *  Created by Simon Urbanek on Wed Dec 10 2003.
 *
 */

#import <Cocoa/Cocoa.h>
#include "Rinit.h"
#include <R.h>
#include <Rinternals.h>
#include <R_ext/Parse.h>
#import "RCEngine.h"

/* we should move this to another callback at some point ... it's a bad, bad hack for now */
#ifndef RENG_STAND_ALONE
//#import "RController.h"
#define DO_RENG_EVAL_STATUS(S)  NSString *lsl = @""; [self setStatusLineText:[NSString stringWithFormat:@"%@: %@", NLS(@"executing"), S]];
#define DONE_RENG_EVAL_STATUS() [self setStatusLineText: lsl];
#endif

/* this is also provided in RGUI.h, but we want to be independent */
#ifndef SLog
#if defined DEBUG_RGUI && defined PLAIN_STDERR
#define SLog(X,...) NSLog(X, ## __VA_ARGS__)
#else
#define SLog(X,...)
#endif
#endif

// this flag causes some parts of the code to not use RCEngine if that would cause re-entrance
// it is meant for the user-level code, not for RCEngine itself - such that the UI can react and display appropriate warnings
BOOL preventReentrance = NO;

@implementation RCEngine

+ (RCEngine*) mainEngine
{
    static RCEngine* _mainRengine = nil;
    static dispatch_once_t onceToken;
    if (_mainRengine) return _mainRengine;
    dispatch_once(&onceToken, ^{
        _mainRengine = [[RCEngine alloc] init];
    });
    //if (_mainRengine == nil)
        
    return _mainRengine;
}

+ (void) shutdown
{
//    if (mainRengine!=nil) {
//        [mainRengine release];
//    }
}

+ (id <REPLHandler>) mainHandler
{
	return [[self mainEngine] handler];
}

+ (id <CocoaHandler>) cocoaHandler
{
	return [[self mainEngine] cocoaHandler];
}

- (id) init
{
    return [self initWithHandler:nil];
}

- (id) initWithHandler: (id <REPLHandler>) hand
{
    [self initREnvironment];
    char *args[4]={ "R", "--no-save", "--gui=cocoa", 0 };
	return [self initWithHandler: hand arguments: args];
}

// From RController (to break dependency on the controller)
- (void)setStatusLineText:(NSString*)text
{
    SLog(@"RController.setStatusLine: \"%@\"", [text description]);
    
    if(text == nil) text = @"";
    
    // We are doing nothing with this for now.  We needed to define this method as part of
    // the port over from the R Mac project.
}

- (void) initREnvironment
{
    if (!getenv("R_HOME")) {
        NSBundle *rfb = [NSBundle bundleWithIdentifier:@"org.r-project.R-framework"];
        if (!rfb) {
            SLog(@" * problem: R_HOME is not set and I can't find the framework bundle");
            NSFileManager *fm = [[NSFileManager alloc] init];
            if ([fm fileExistsAtPath:@"/Library/Frameworks/R.framework/Resources/bin/R"]) {
                SLog(@" * I'm being desperate and I found R at /Library/Frameworks/R.framework - so I'll use it, wish me luck");
                setenv("R_HOME", "/Library/Frameworks/R.framework/Resources", 1);
            } else {
                SLog(@" * I didn't even find R framework in the default location, I'm giving up - you're on your own");
            }
            [fm release];
        } else {
            SLog(@"   %s", [[rfb resourcePath] UTF8String]);
            setenv("R_HOME", [[rfb resourcePath] UTF8String], 1);
        }
    }
    NSString* home = @"";
    if (getenv("R_HOME"))
        home = [[NSString alloc] initWithUTF8String:getenv("R_HOME")];
    else
        home = [[NSString alloc] initWithString:@""];
    
    {
        char tp[1024];
        /* since 2.2.0 those are set in the R shell script, so we need to set them as well */
        /* FIXME: possible buffer-overflow attack by over-long R_HOME */
        if (!getenv("R_INCLUDE_DIR")) {
            strcpy(tp, getenv("R_HOME")); strcat(tp, "/include"); setenv("R_INCLUDE_DIR", tp, 1);
        }
        if (!getenv("R_SHARE_DIR")) {
            strcpy(tp, getenv("R_HOME")); strcat(tp, "/share"); setenv("R_SHARE_DIR", tp, 1);
        }
        if (!getenv("R_DOC_DIR")) {
            strcpy(tp, getenv("R_HOME")); strcat(tp, "/doc"); setenv("R_DOC_DIR", tp, 1);
        }
    }
    
#if defined __i386__
#define arch_lib_nss @"/lib/i386"
#define arch_str "/i386"
#elif defined __x86_64__
#define arch_lib_nss @"/lib/x86_64"
#define arch_str "/x86_64"
    /* not used in R >= 2.15.2, so remove eventually */
#elif defined __ppc__
#define arch_lib_nss @"/lib/ppc"
#define arch_str "/ppc"
#elif defined __ppc64__
#define arch_lib_nss @"/lib/ppc64"
#define arch_str "/ppc64"
#endif
    
#ifdef arch_lib_nss
    if (!getenv("R_ARCH")) {
        NSFileManager *fm = [[NSFileManager alloc] init];
        if ([fm fileExistsAtPath:[[NSString stringWithUTF8String:getenv("R_HOME")] stringByAppendingString: arch_lib_nss]]) {
            setenv("R_ARCH", arch_str, 1);
        }
        [fm release];
    }
#else
#warning "Unknown architecture, R_ARCH won't be set automatically."
#endif

}

- (id) initWithHandler: (id <REPLHandler>) hand arguments: (char**) args
{
	int i=0;
	argc=0;
	while (args[argc]) argc++;
	
	argv = (char**) malloc(sizeof(char*) * (argc+1));
	while (i<argc) {
		argv[i]=(char*) malloc(strlen(args[i])+1);
		strcpy(argv[i], args[i]);
		i++;
	}
	argv[i]=0;
	
    replHandler=hand;
	cocoaHandler=nil; // cocoaHandlier is optional
    //_mainRengine = self;
    loopRunning=NO;
	active=NO;
	insideR=0;
	maskEvents=0;
	saveAction=@"ask";
	
    //setenv("R_HOME","/Library/Frameworks/R.framework/Resources",1);
    //setenv("DYLD_LIBRARY_PATH","/Library/Frameworks/R.framework/Resources/lib",1);
    
	return self;
}

- (BOOL) activate
{
	SLog(@"RCEngine.activate: starting R ...");
	RENGINE_BEGIN;
	{
		int res = initR(argc, argv, [saveAction isEqual:@"yes"]?Rinit_save_yes:([saveAction isEqual:@"no"]?Rinit_save_no:Rinit_save_ask));
		active = (res==0)?YES:NO;
	}
	RENGINE_END;
	if (lastInitRError) {
		if (lastError) [lastError release];
		lastError = [[NSString alloc] initWithUTF8String:lastInitRError];
	} else lastError=nil;
	SLog(@"RCEngine.activate: %@", (lastError)?lastError:@"R started with no error");
    return active;
}

- (NSString*) lastError
{
	return lastError;
}

- (BOOL) isActive { return active; }
- (BOOL) isLoopRunning { return loopRunning; }

- (BOOL) allowEvents { return (maskEvents==0); }

- (BOOL) beginProtected {
	SLog(@"RCEngine.beginProtected, maskEvents=%d, protectedMode=%d", maskEvents, (int)protectedMode);
	if (protectedMode) return NO;
	maskEvents++;
	protectedMode=YES;
	return YES;
}

- (void) endProtected {
	SLog(@"RCEngine.endProtected, maskEvents=%d, protectedMode=%d", maskEvents, (int)protectedMode);
	maskEvents--;
	protectedMode=NO;
}

- (void) runREPL
{
	BOOL keepInLoop = YES;
	if (!active) return;
	loopRunning=YES;
	while (keepInLoop) {
#ifdef USE_POOLS
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#endif
		insideR++;
		@try {
			run_RCEngineRmainloop(0);
			insideR--;
			keepInLoop = NO; // voluntary exit, break the loop
		}
		@catch (NSException *foo) {
			insideR--;
			NSLog(@"*** RCEngine.runREPL: caught ObjC exception in the main loop. Update to the latest GUI version and consider reporting this properly (see FAQ) if it persists and is not known. \n*** reason: %@\n*** name: %@, info: %@\n*** Version: R %s.%s (%d) R.app %@%s\nConsider saving your work soon in case this develops into a problem.", [foo reason], [foo name], [foo userInfo], R_MAJOR, R_MINOR, R_SVN_REVISION, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], getenv("R_ARCH"));
		}
#ifdef USE_POOLS
		[pool release];
#endif
	}
	loopRunning=NO;	
}

- (void) runDelayedREPL
{
	if (!active) return;
	loopRunning=YES;
	insideR++;
    run_RCEngineRmainloop(1);
	insideR--;
	/* in fact loopRunning is not determinable, because later longjmp may have re-started the loop, so we just keep it at YES */
}

- (id <REPLHandler>) handler
{
    return replHandler;
}

- (id <CocoaHandler>) cocoaHandler
{
	return cocoaHandler;
}

- (void) setCocoaHandler: (id <CocoaHandler>) ch
{
	cocoaHandler=ch;
}

- (void) setSaveAction: (NSString*) action
{
	saveAction = action?action:@"ask";
}

- (NSString*) saveAction
{
	return saveAction;
}

- (void) disableRSignalHandlers: (BOOL) disable
{
	setRSignalHandlers(disable?0:1);
}

- (void) begin
{
	// FIXME: we should set a lock here
	[replHandler handleBusy:YES];
	if (insideR) SLog(@"***********> RCEngine.begin: expected insideR to be 0, but it's %d", insideR);
	if (insideR < 0) insideR = 0; // this can happen 
	insideR++;
}

- (void) end
{
	// FIXME: we should release a lock here
	insideR--;
	if (insideR) SLog(@"***********> RCEngine.end: expected insideR to be 0, but it's %d", insideR);
	[replHandler handleBusy:NO];
}

//- (RSEXP*) parse: (NSString*) str
//{
//    return [self parse: str withParts: 1];
//}

//- (NSMutableArray<RCSymbolicExpression*>*) parse: (NSString*) str
//{
//    return [self parse: str withParts: -1];
//}

//- (RSEXP*) parse: (NSString*) str withParts: (int) count
//{
//    ParseStatus ps;
//    SEXP pstr, cv;
//
//	if (!active) return nil;
//	RENGINE_BEGIN;
//    PROTECT(cv=allocVector(STRSXP, 1));
//    SET_STRING_ELT(cv, 0, mkChar([str UTF8String]));    
//    pstr=R_ParseVector(cv, count, &ps, R_NilValue);
//    UNPROTECT(1);
//	RENGINE_END;
//    //NSLog(@"parse status: %d, SEXP: %x, type: %d\n", ps, pstr, TYPEOF(pstr));
//	return pstr?[[RSEXP alloc] initWithSEXP: pstr]:nil;
//}

- (NSMutableArray<RCSymbolicExpression*>*) Parse: (NSString*) str
{
    NSMutableArray<RCSymbolicExpression*>* results = [[NSMutableArray<RCSymbolicExpression*> alloc] init];
    
    ParseStatus parseStatus;
    SEXP cmdexpr, cmdSexp;
    
    if (!active) return nil;
    RENGINE_BEGIN;
    PROTECT(cmdSexp=allocVector(STRSXP, 1));
    SET_STRING_ELT(cmdSexp, 0, mkChar([str UTF8String]));
    cmdexpr = R_ParseVector(cmdSexp, -1, &parseStatus, R_NilValue);

    // If the vector is empty, return a nil response
    //if (cmdexpr == nil || count <= 0) { return nil; }
    if (cmdexpr == nil || parseStatus != PARSE_OK) { return nil; }
    
    // With help from: http://www.hep.by/gnu/r-patched/r-exts/R-exts_121.html
    int errVal = 0;
    int exprLen = Rf_length(cmdexpr);
    for(R_len_t i = 0; i < exprLen; i++) {
        SEXP cmdElement = Rf_eval(VECTOR_ELT(cmdexpr, i), R_GlobalEnv);
        if (cmdElement == nil) { continue; }
        SEXP cmdEvalElement = R_tryEval(cmdElement, R_GlobalEnv, &errVal);
        if (cmdEvalElement == nil) { continue; }
        [results addObject:[[RCSymbolicExpression alloc] initWithEngineAndExpression: self expression: cmdEvalElement]];
    }
    
    UNPROTECT(1);
    RENGINE_END;
    
    return results;
}

//- (RCSymbolicExpression*) evaluateExpressions: (RCSymbolicExpression*) expr
//{
//    SEXP evaluatedExpression = NULL;
//    int errVal = 0;
//
//    if (!active) return nil;
//	RENGINE_BEGIN;
//    // if we have an entire expression list, evaluate its contents one-by-one and return only the last one
//    if ([expr Type]==EXPRSXP) {
//        int length = [expr Length];
//        for (int index = 0; index < length; index++) {
//            evaluatedExpression = R_tryEval([[expr ElementAt:index] GetHandle], R_GlobalEnv, &errVal);
//        }
//    } else {
//        evaluatedExpression=R_tryEval([expr GetHandle], R_GlobalEnv, &errVal);
//    }
//	RENGINE_END;
//    
//    if (errVal) {
//        [NSException raise:@"There was an error evaluating the expression" format:@"%s", R_curErrorBuf()];
//    }
//    return evaluatedExpression ? [[RCSymbolicExpression alloc] initWithEngineAndExpression:self expression: evaluatedExpression] : nil;
//}

- (RCSymbolicExpression*) Evaluate: (NSString*) str
{
    // Internally, this will take a string expression (which may be multiple commands).  Similar to the R.NET library, we
    // will only return the last evaluated expression, or nil if there are no results.
    RCSymbolicExpression *xr;
	if (!active) return nil;
    NSMutableArray<RCSymbolicExpression*>* parsedExpressions = [self Parse: str];
    if (parsedExpressions == nil) return nil;
    RCSymbolicExpression* lastExpression = [parsedExpressions lastObject];
	if([lastExpression Type] == NILSXP) { [parsedExpressions release]; return nil; }
//	DO_RENG_EVAL_STATUS(str);
//    xr=[self evaluateExpressions: ps];
//	DONE_RENG_EVAL_STATUS();
	[parsedExpressions release];
    return lastExpression;
//	return xr;
}

//- (RCSymbolicExpression*) evaluateString: (NSString*) str withParts: (int) count
//{
//    RCSymbolicExpression *ps, *xr;
//	if (!active) return nil;
//    ps=[self parse: str withParts: count];
//    if (ps==nil) return nil;
//	if([ps Type]==NILSXP) { [ps release]; return nil; }
//	DO_RENG_EVAL_STATUS(str);
//    xr=[self evaluateExpressions: ps];
//	DONE_RENG_EVAL_STATUS();
//	[ps release];
//	return xr;
//}

//- (BOOL) executeString: (NSString*) str
//{
//    RSEXP *ps, *xr;
//	BOOL success=NO;
//	SLog(@"RCEngine.executeString:\"%@\"", str);
//	if (!active) return NO;
//    ps=[self parse: str];
//    if (ps==nil) return NO;
//	DO_RENG_EVAL_STATUS(str);
//
//	// Run NSDefaultRunLoopMode to allow to update status line
//	[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode 
//							 beforeDate:[NSDate distantPast]];
//
//    xr=[self evaluateExpressions: ps];
//	DONE_RENG_EVAL_STATUS();
//	[ps release];
//	if (xr!=nil) success=YES;
//	if (xr) [xr release];
//	SLog(@" - success: %@", success?@"YES":@"NO");
//	return success;
//}

- (RCSymbolicExpression*) NilValue
{
    return [[RCSymbolicExpression alloc] initWithEngineAndExpression:self expression:R_NilValue];
}

- (RCSymbolicExpression*) NaString
{
    return [[RCSymbolicExpression alloc] initWithEngineAndExpression:self expression:R_NaString];
}

@end
