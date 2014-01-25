
//  AOPThreadInvoker.h  InnoliFoundation
//  Created by Szilveszter Molnar on 1/7/11.  Copyright 2011 Innoli Kft. All rights reserved.

#import "AOPProxy.h"

@interface AOPThreadInvoker : AOPProxy

- (id) initWithInstance:(id)anObject thread:(NSThread *)aThread;

@end
