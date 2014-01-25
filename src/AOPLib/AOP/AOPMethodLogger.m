
//  AOPMethodLogger.m  InnoliFoundation
//  Created by Szilveszter Molnar on 1/7/11.  Copyright 2011 Innoli Kft. All rights reserved.

#import "AOPMethodLogger.h"

@implementation AOPMethodLogger

- (void)invokeOriginalMethod:(NSInvocation *)inv
{

    NSString *selString = NSStringFromSelector(inv.selector);
    NSLog(@"Method START: %@", selString);
    [super invokeOriginalMethod:inv];
    NSLog(@"Method END: %@", selString);
}

@end
