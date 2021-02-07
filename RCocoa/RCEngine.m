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
#import <R/R.h>

//R#include "Rinit.h"
//#include <R.h>
//#include <Rinternals.h>
//#include <R_ext/Parse.h>

#import "RCDefaultDevice.h"

#include <Rversion.h>
#if R_VERSION < R_Version(3,0,0)
#error R >= 3.0.0 is required
#endif

#define R_INTERFACE_PTRS 1
#define CSTACK_DEFNS 1

#include <R.h>
#include <Rinternals.h>
//#include "Rinit.h"
#include <R_ext/Parse.h>
#include <Rembedded.h>

/* This constant defines the maximal length of single ReadConsole input, which usually corresponds to the maximal length of a single line. The buffer is allocated dynamically, so an arbitrary size is fine. */
#ifndef MAX_R_LINE_SIZE
#define MAX_R_LINE_SIZE 32767
#endif

#include <Rinterface.h>

//#define Rinit_save_yes 0
//#define Rinit_save_no  1
//#define Rinit_save_ask 2
/* and SaveAction is not officially exported */
extern SA_TYPE SaveAction;

extern Rboolean R_Visible;

#import "RCEngine.h"

// Used by R to allow multiple statements on a single line (e.g., "x <- 2; x + 1")
NSString* const R_STATEMENT_DELIMITER = @";";

NSString* const R_COMMENT = @"#";

// this flag causes some parts of the code to not use RCEngine if that would cause re-entrance
// it is meant for the user-level code, not for RCEngine itself - such that the UI can react and display appropriate warnings
BOOL preventReentrance = NO;

@implementation RCEngine

static RCEngine* _mainRengine = nil;
static BOOL _activated = FALSE;

static BOOL _RIsInstalled = FALSE;
static NSString* _RHome;

+ (RCEngine*) GetInstance
{
    return [RCEngine GetInstance:nil];
}

+ (RCEngine*) GetInstance:(RCICharacterDevice*) device
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mainRengine = [[RCEngine alloc] init];
        [_mainRengine disableRSignalHandlers:TRUE];
        if (![_mainRengine activate:device]) {
            [RCEngine shutdown];
        }
    });

    return _mainRengine;
}

//+ (RCEngine*) mainEngine
//{
//  static dispatch_once_t onceToken;
//  dispatch_once(&onceToken, ^{
//      _mainRengine = [[RCEngine alloc] init];
//      [_mainRengine disableRSignalHandlers:TRUE];
//      if (![_mainRengine activate]) {
//        [RCEngine shutdown];
//      }
//  });
//  
//  return _mainRengine;
//  
//  //https://stackoverflow.com/questions/9119042/why-does-apple-recommend-to-use-dispatch-once-for-implementing-the-singleton-pat
//  /*
//  @synchronized(self) {
//    if (_mainRengine == nil) {
//      _mainRengine = [[RCEngine alloc] init];
//      [_mainRengine disableRSignalHandlers:TRUE];
//      if (![_mainRengine activate]) {
//        [RCEngine shutdown];
//        return nil;
//      }
//    };
//  }
//  */
//}

+ (void) shutdown
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      if (_mainRengine != nil) {
        [_mainRengine release];
        _mainRengine = nil;
        R_RunExitFinalizers();
      }
  });

  /*
  @synchronized(self) {
    if (_mainRengine != nil) {
      [_mainRengine release];
      _mainRengine = nil;
      R_RunExitFinalizers();
    }
  }
  */
}

+ (NSString*)RHome {
  return _RHome;
}

- (id) init
{
  self->autoPrint = true;
  [self initREnvironment];
  if(_RIsInstalled){
    char *args[4]={ "r_cocoa", "--no-save", "--quiet", 0 };
    return [self initWithArgs: args];
  } else {
    return nil;
  }
}

- (void) initREnvironment
{
    if(!getenv("LANG"))
    {
      setenv("LANG", "en", 1);
    }

    if (!getenv("R_HOME")) {
        NSBundle *rfb = [NSBundle bundleWithIdentifier:@"org.r-project.R-framework"];
        if (!rfb) {
            NSLog(@" * problem: R_HOME is not set and I can't find the framework bundle");
            NSFileManager *fm = [[NSFileManager alloc] init];
            if ([fm fileExistsAtPath:@"/Library/Frameworks/R.framework/Resources/bin/R"]) {
                NSLog(@" * I'm being desperate and I found R at /Library/Frameworks/R.framework - so I'll use it, wish me luck");
                setenv("R_HOME", "/Library/Frameworks/R.framework/Resources", 1);
               _RIsInstalled = YES;
            } else {
              NSLog(@" * I didn't even find R framework in the default location, I'm giving up - you're on your own");
              _RIsInstalled = NO;
              return;
            }
            [fm release];
        } else {
            NSLog(@"   %s", [[rfb resourcePath] UTF8String]);
            setenv("R_HOME", [[rfb resourcePath] UTF8String], 1);
           _RIsInstalled = YES;
        }
    }
    NSString* home = @"";
    if (getenv("R_HOME")) {
      home = [[NSString alloc] initWithUTF8String:getenv("R_HOME")];
      _RIsInstalled = YES;
    }
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
    
  _RHome = home;
  
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

	active=NO;
	maskEvents=0;
	saveAction=@"ask";
	
	return self;
}

- (BOOL) activate:(RCICharacterDevice*) device
{
    // If the engine has already been activated, don't allow it to be activated again.
    if (_activated) {
        return _activated;
    }

    if (device == nil) {
      device = (RCICharacterDevice*)[[RCDefaultDevice alloc] init];
    }
    adapter = [[RCCharacterDeviceAdapter alloc] initWithDevice:device];

    if (!getenv("R_HOME")) {
        return NO;
    }

    R_setStartTime();

    int initialized = Rf_initialize_R(argc, argv);
    if (initialized < 0) {
        return NO;
    }

    // http://grokbase.com/t/r/r-devel/0776ak67sd/rd-how-to-disable-rs-c-stack-checking
    R_CStackLimit=-1;

    SaveAction = ([saveAction isEqual:@"yes"]) ? SA_SAVE :
        ([saveAction isEqual:@"no"] ? SA_NOSAVE : SA_SAVEASK);

    // Create our adapter
    [adapter Install:self];

    // Needs to be set again after installing the device adapter
    R_CStackLimit=-1;

    setup_Rmainloop();

    _activated = YES;
    active = _activated;
    return _activated;
}

- (NSString*) lastError
{
	return lastError;
}

- (BOOL) isActive { return active; }

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
    R_SignalHandlers = (disable?0:1);
}

// The approach for this method derived from: https://stackoverflow.com/questions/4158646/most-efficient-way-to-iterate-over-all-the-chars-in-an-nsstring/25938062#25938062
- (NSArray<NSNumber*>*) IndexOfAll: (NSString*)line search:(NSString*)search
{
    NSMutableArray* foundIndices = [NSMutableArray array];

    [line enumerateSubstringsInRange: NSMakeRange(0, [line length]) options: NSStringEnumerationByComposedCharacterSequences
                          usingBlock: ^(NSString *inSubstring, NSRange inSubstringRange, NSRange inEnclosingRange, BOOL *outStop) {
                              if ([inSubstring isEqualToString:search]) {
                                  [foundIndices addObject:[NSNumber numberWithInteger:inEnclosingRange.location]];
                              }
                          }];
    return foundIndices;
}

- (BOOL) IsClosedString: (NSString*) string
{
    BOOL inSingleQuote = FALSE;
    BOOL inDoubleQuotes = FALSE;

    for (int index = 0; index < [string length]; index++) {
        if ([[string substringWithRange:NSMakeRange(index, 1)] isEqualToString:@"'"]) {
            if (index > 0 && [[string substringWithRange:NSMakeRange(index - 1, 1)] isEqualToString:@"\\"]) {
                continue;
            }
            if (inDoubleQuotes) {
                continue;
            }
            inSingleQuote = !inSingleQuote;
        }
        else if ([[string substringWithRange:NSMakeRange(index, 1)] isEqualToString:@"\""]) {
            if (index > 0 && [[string substringWithRange:NSMakeRange(index - 1, 1)] isEqualToString:@"\\"]) {
                continue;
            }
            if (inSingleQuote) {
                continue;
            }
            inDoubleQuotes = !inDoubleQuotes;
        }
    }

    return (!inSingleQuote) && (!inDoubleQuotes);
}

- (NSInteger) EvenStringDelimiters: (NSString*)statement whereHash:(NSArray<NSNumber*>*)whereHash
{
    for (int index = 0; index < [whereHash count]; index++) {
        NSString* subString = [statement substringToIndex:[whereHash[index] integerValue]];
        if ([self IsClosedString:subString]) {
            return [whereHash[index] integerValue];
        }
    }

    return -1;
}

// This method assumes you have already called PreProcessStatement, and are feeding in a line from that collection.
- (NSArray<NSString*>*) ProcessLine: (NSString*)line
{
    if ([line hasPrefix:R_COMMENT]) {
        return @[ line ];
    }

    // Split the string to account for multiple statements on a single line
    NSArray<NSString*>* statements = [line componentsSeparatedByString:R_STATEMENT_DELIMITER];

    NSMutableArray<NSString*>* results = [[NSMutableArray alloc] init];
    for (int index = 0; index < [statements count]; index++) {
        NSString* statement = statements[index];
        if (![statement containsString:R_COMMENT]) {
            [results addObject:[statement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        else {
            NSArray<NSNumber*>* whereHash = [self IndexOfAll:statement search:R_COMMENT];
            NSInteger firstComment = [self EvenStringDelimiters:statement whereHash:whereHash];
            if (firstComment < 0) {
                // Incomplete statement?  such as:
                // paste('this is the # ', ' start of an incomplete # statement
                [results addObject:statement];
            }
            else {
                [results addObject:[statement substringToIndex:firstComment]];
                // firstComment is a valid comment marker - not need to process "the rest"
            }
        }
    }

    return results;
}

- (NSMutableArray<NSString*>*) PreProcessStatement: (NSString*)statement
{
    if (statement == nil) {
        return nil;
    }

    // Clean up newlines within the string, so we can simplify breaking it apart later.  We don't know what we'll get... so we
    // assume \r\n or \n\r are supposed to be considered a combined newline, and any remaining \r should be converted to \n.
    // In the end we will just split the string using \n.
    NSString* cleanParseString = [[[statement stringByReplacingOccurrencesOfString:@"\n\r" withString:@"\n"] stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"] stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    NSArray<NSString*>* stringComponents = [cleanParseString componentsSeparatedByString:@"\n"];
    if (stringComponents == nil || [stringComponents count] == 0) {
        return nil;
    }
    NSMutableArray<NSString*>* cleanStringComponents = [stringComponents mutableCopy];
    for (int index = 0; index < [cleanStringComponents count]; index++) {
        cleanStringComponents[index] = [cleanStringComponents[index] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return cleanStringComponents;
}

// Given a string, break it into valid statements that R can interpret.  This includes some
// manipulation of the string to break it apart by lines and expression termination delimiters, and
// ensure that complete, valid expressions are passed by tracking expression fragments over multiple
// lines.
// This code and helper methods are ported directly from the R.NET library.
- (NSMutableArray<RCSymbolicExpression*>*) Parse: (NSString*) str
{
    if (!active) return nil;

    NSMutableArray<RCSymbolicExpression*>* results = [[NSMutableArray<RCSymbolicExpression*> alloc] init];
    NSMutableArray<NSString*>* preProcessedLines = [self PreProcessStatement:str];
    if (preProcessedLines == nil || [preProcessedLines count] == 0) {
        return results;
    }

    // For the pre-processed lines, we will now go through and try to do the parsing and evaluation
    // with R.  We will need to check as we go along if we have incomplete statements, and if so we'll
    // get the next line and include that.  If it is a complete statement, we'll proceed with processing
    // it and incorporating the results.
    NSMutableString* incompleteStatement = [[NSMutableString alloc] init];
    ParseStatus parseStatus = PARSE_NULL;
    for (int index = 0; index < [preProcessedLines count]; index++) {
        NSArray<NSString*>* processedLineResults = [self ProcessLine:preProcessedLines[index]];
        long segmentCount = [processedLineResults count];
        for (long processedIndex = 0; processedIndex < segmentCount; processedIndex++) {
            [incompleteStatement appendString:processedLineResults[processedIndex]];
            if (processedIndex == segmentCount - 1) {
              if (![processedLineResults[processedIndex] isEqualToString:@""]) {
                [incompleteStatement appendString:@"\n"];
              }
            }
            else {
              [incompleteStatement appendString:@";"];
            }
            id cmdSexp = PROTECT(allocVector(STRSXP, 1));
            id statementExp = (mkChar([incompleteStatement UTF8String]));
            SET_STRING_ELT(cmdSexp, 0, statementExp);
            id cmdexpr = PROTECT(R_ParseVector(cmdSexp, -1, &parseStatus, R_NilValue));
            if (parseStatus == PARSE_OK) {
                [incompleteStatement release];
                incompleteStatement = [[NSMutableString alloc] init];

                // With help from: http://www.hep.by/gnu/r-patched/r-exts/R-exts_121.html
                int exprLen = Rf_length(cmdexpr);
                for (R_len_t i = 0; i < exprLen; i++) {
                    int err = 0;
                    id cmdElement = R_tryEval(VECTOR_ELT(cmdexpr, i), R_GlobalEnv, &err);
                    if(err) {
                      // Sometimes the error buffer comes back empty.  If that happens, we still want to show something to the user,
                      // so our backup is to display the input command.
                      NSString* rErrMsg = [NSString stringWithUTF8String: R_curErrorBuf()];
                      if (rErrMsg == nil) {
                        rErrMsg = processedLineResults[processedIndex];
                      }
                      NSException* exc = [NSException
                                          exceptionWithName:@"ParseException"
                                          reason:[NSString stringWithFormat:@"There was an error interpreting the expression.\n%@", rErrMsg]
                                          userInfo: [[NSDictionary alloc] initWithObjectsAndKeys: rErrMsg, @"ErrorDescription", nil]];
                      
                      @throw exc;
                    } else {
                      // Grab the R_Visible value right now.  Our subsequent calls will reset this from the
                      // value we should keep after Rf_eval
                      BOOL isResultVisible = R_Visible;

                      id cmdEvalElement = Rf_eval(cmdElement, R_GlobalEnv);
                      if (cmdEvalElement == nil) { continue; }
                      if (self->autoPrint && isResultVisible == TRUE) {
                        Rf_PrintValue(cmdEvalElement);
                      }
                      [results addObject:[[RCSymbolicExpression alloc] initWithEngineAndExpression: self expression: cmdEvalElement]];
                    }
                }
            }
            else if (parseStatus == PARSE_INCOMPLETE) {
                // Purposely blank - we don't want to throw an exception, and we don't want to handle
                // the expression as if it were valid.  There's a check at the end to handle if an
                // incomplete expression was the last status we had.
            }
            else {
                UNPROTECT(2);

                NSException* exc = [NSException
                                    exceptionWithName:@"ParseException"
                                    reason:[NSString stringWithFormat:@"There was an error interpreting the expression:\r\n'%@'", [incompleteStatement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]
                                    userInfo:[[NSDictionary alloc] initWithObjectsAndKeys: incompleteStatement, @"ErrorDescription", nil]];
                @throw exc;
            }
            
            UNPROTECT(2);
        }
    }

    if (parseStatus == PARSE_INCOMPLETE) {
        NSException* exc = [NSException
                            exceptionWithName:@"ParseException"
                            reason:[NSString stringWithFormat:@"The following expression appears to be incomplete:\r\n'%@'", [incompleteStatement stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]
                            userInfo:[[NSDictionary alloc] initWithObjectsAndKeys: incompleteStatement, @"ErrorDescription", nil]];
        @throw exc;
    }

    return results;
}

// Given a block of code, parse the string into individual statements and evaluate them against
// the R engine.  If there are multiple statements are sent, only the results of the last statement
// are returned.  If nothing is evaluated, nil is returned.  If there is an error in the parse/
// evaluate process, an exception will be thrown.
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
  	[parsedExpressions release];
    return lastExpression;
}

// Return the internal R NilValue expression as an RCocoa expression
- (RCSymbolicExpression*) NilValue
{
    return [[RCSymbolicExpression alloc] initWithEngineAndExpression:self expression:R_NilValue];
}

// Return the internal R NaString expression as an RCocoa expression
- (RCSymbolicExpression*) NaString
{
    return [[RCSymbolicExpression alloc] initWithEngineAndExpression:self expression:R_NaString];
}

@end
