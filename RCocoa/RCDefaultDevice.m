//
//  RCDefaultDevice.m
//  RCocoa
//
//  Created by Luke Rasmussen on 7/7/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "RCDefaultDevice.h"

@implementation RCDefaultDevice


-(void)WriteConsole:(const char*)buffer length:(int)length
{
    // The default implementation does nothing
}

-(void) WriteConsoleEx:(const char*)buffer length:(int)length otype:(int)otype
{
    // The default implementation does nothing
}
@end