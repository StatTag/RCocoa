//
//  RCCharacterDeviceAdapter.m
//  RCocoa
//
//  Created by Luke Rasmussen on 7/6/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "RCCharacterDeviceAdapter.h"
#include "RCICharacterDevice.h"
#import <R.h>

// Forward declaration of the R interface functions
extern void (*ptr_R_WriteConsole)(const char *, int);
extern void (*ptr_R_WriteConsoleEx)(const char *, int, int);

extern FILE * R_Consolefile;
extern FILE * R_Outputfile;
extern Rboolean R_Interactive;	/* TRUE during interactive use*/


static RCICharacterDevice* _device;

void WriteConsoleEx(const char* buffer, int length, int otype)
{
    @synchronized(_device) {
        [_device WriteConsoleEx:buffer length:length otype:otype];
    }
}

void WriteConsole(const char* buffer, int length)
{
    @synchronized(_device) {
        [_device WriteConsole:buffer length:length];
    }
}


@implementation RCCharacterDeviceAdapter

-(id) initWithDevice:(RCICharacterDevice*)device
{
    if (device == nil) {
        NSException* exc = [NSException
                            exceptionWithName:@"ArgumentNullException"
                            reason:@"The device cannot be null"
                            userInfo:nil];
        @throw exc;
    }

    self = [super init];
    @synchronized(_device) {
        _device = device;
    }
    return self;
}

-(void) Install: (RCEngine*)engine
{
    _engine = engine;
    [self SetupDevice];
}

-(void) SetupDevice
{
    ptr_R_WriteConsole = &WriteConsole;
    ptr_R_WriteConsoleEx = &WriteConsoleEx;

    R_Interactive = (Rboolean)0;
    R_Outputfile = NULL;
    R_Consolefile = NULL;
}



@end
