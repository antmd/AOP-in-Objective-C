
//  AOPThreadInvoker.m  InnoliFoundation
//  Created by Szilveszter Molnar on 1/7/11.  Copyright 2011 Innoli Kft. All rights reserved.

#import "AOPProxy.h"

@implementation AOPThreadInvoker { NSThread *serializerThread; }

- (id)initWithInstance:(id)anObject thread:(NSThread *)aThread {

    return self = [super initWithObject:anObject] ? serializerThread = aThread, self : nil;
}

- (void)invokeOriginalMethod:(NSInvocation*)anInvocation {

    [anInvocation performSelector:@selector(invoke)
                         onThread:serializerThread
                       withObject:nil
                    waitUntilDone:YES];
}

@end
