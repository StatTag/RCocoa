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

// this flag causes some parts of the code to not use RCEngine if that would cause re-entrance
// it is meant for the user-level code, not for RCEngine itself - such that the UI can react and display appropriate warnings
BOOL preventReentrance = NO;

@implementation RCEngine

static RCEngine* _mainRengine = nil;
static BOOL _activated = FALSE;

+ (RCEngine*) mainEngine
{
    @synchronized(self) {
        if (_mainRengine == nil) {
            _mainRengine = [[RCEngine alloc] init];
            [_mainRengine disableRSignalHandlers:TRUE];
            if (![_mainRengine activate]) {
                [RCEngine shutdown];
                return nil;
            }
        };
    }
    return _mainRengine;
}

+ (void) shutdown
{
    @synchronized(self) {
        if (_mainRengine != nil) {
            [_mainRengine release];
            _mainRengine = nil;
            R_RunExitFinalizers();
        }
    }
}


- (id) init
{
    [self initREnvironment];
    char *args[3]={ "R", "--no-save", 0 };
    return [self initWithArgs: args];
}

- (void) initREnvironment
{
    if (!getenv("R_HOME")) {
        NSBundle *rfb = [NSBundle bundleWithIdentifier:@"org.r-project.R-framework"];
        if (!rfb) {
            NSLog(@" * problem: R_HOME is not set and I can't find the framework bundle");
            NSFileManager *fm = [[NSFileManager alloc] init];
            if ([fm fileExistsAtPath:@"/Library/Frameworks/R.framework/Resources/bin/R"]) {
                NSLog(@" * I'm being desperate and I found R at /Library/Frameworks/R.framework - so I'll use it, wish me luck");
                setenv("R_HOME", "/Library/Frameworks/R.framework/Resources", 1);
            } else {
                NSLog(@" * I didn't even find R framework in the default location, I'm giving up - you're on your own");
            }
            [fm release];
        } else {
            NSLog(@"   %s", [[rfb resourcePath] UTF8String]);
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

- (id) initWithArgs: (char**) args
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
	
    loopRunning=NO;
	active=NO;
	maskEvents=0;
	saveAction=@"ask";
	
	return self;
}

- (BOOL) activate
{
    // If the engine has already been activated, don't allow it to be activated again.
    if (_activated) {
        return _activated;
    }

    int res = initR(argc, argv,
                    [saveAction isEqual:@"yes"] ? Rinit_save_yes :
                        ([saveAction isEqual:@"no"] ? Rinit_save_no : Rinit_save_ask));
    active = (res==0) ? YES : NO;

    if (lastInitRError) {
        if (lastError) { [lastError release]; }
		lastError = [[NSString alloc] initWithUTF8String:lastInitRError];
    } else {
        lastError=nil;
    }

    _activated = active;
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
	NSLog(@"RCEngine.beginProtected, maskEvents=%d, protectedMode=%d", maskEvents, (int)protectedMode);
	if (protectedMode) return NO;
	maskEvents++;
	protectedMode=YES;
	return YES;
}

- (void) endProtected {
	NSLog(@"RCEngine.endProtected, maskEvents=%d, protectedMode=%d", maskEvents, (int)protectedMode);
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
		@try {
			run_RCEngineRmainloop(0);
			keepInLoop = NO; // voluntary exit, break the loop
		}
		@catch (NSException *foo) {
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
    run_RCEngineRmainloop(1);
	/* in fact loopRunning is not determinable, because later longjmp may have re-started the loop, so we just keep it at YES */
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

- (NSMutableArray<RCSymbolicExpression*>*) Parse: (NSString*) str
{
    NSMutableArray<RCSymbolicExpression*>* results = [[NSMutableArray<RCSymbolicExpression*> alloc] init];
    
    ParseStatus parseStatus;
    SEXP cmdexpr, cmdSexp;
    
    if (!active) return nil;
    PROTECT(cmdSexp=allocVector(STRSXP, 1));
    SET_STRING_ELT(cmdSexp, 0, mkChar([str UTF8String]));
    cmdexpr = R_ParseVector(cmdSexp, -1, &parseStatus, R_NilValue);

    // If the vector is empty, return a nil response
    if (cmdexpr == nil || parseStatus != PARSE_OK) { return nil; }
    
    // With help from: http://www.hep.by/gnu/r-patched/r-exts/R-exts_121.html
    int errVal = 0;
    int exprLen = Rf_length(cmdexpr);
    for (R_len_t i = 0; i < exprLen; i++) {
        SEXP cmdElement = Rf_eval(VECTOR_ELT(cmdexpr, i), R_GlobalEnv);
        if (cmdElement == nil) { continue; }
        SEXP cmdEvalElement = R_tryEval(cmdElement, R_GlobalEnv, &errVal);
        if (cmdEvalElement == nil) { continue; }
        [results addObject:[[RCSymbolicExpression alloc] initWithEngineAndExpression: self expression: cmdEvalElement]];
    }
    
    UNPROTECT(1);
    return results;
}

- (RCSymbolicExpression*) Evaluate: (NSString*) str
{
    // Don't process anything if we haven't activated the engine yet
    if (!active) {
        return nil;
    }

    // Internally, this will take a string expression (which may be multiple commands).  Similar to the R.NET library, we
    // will only return the last evaluated expression, or nil if there are no results.
    NSMutableArray<RCSymbolicExpression*>* parsedExpressions = [self Parse: str];
    if (parsedExpressions == nil) { return nil; }
    RCSymbolicExpression* lastExpression = [parsedExpressions lastObject];
	if ([lastExpression Type] == NILSXP) {
        [parsedExpressions release];
        return nil;
    }
	[parsedExpressions release];
    return lastExpression;
}

- (RCSymbolicExpression*) NilValue
{
    return [[RCSymbolicExpression alloc] initWithEngineAndExpression:self expression:R_NilValue];
}

- (RCSymbolicExpression*) NaString
{
    return [[RCSymbolicExpression alloc] initWithEngineAndExpression:self expression:R_NaString];
}

@end
