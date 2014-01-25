
//  AOPInterceptorInfo.h  InnoliFoundation
//  Created by Szilveszter Molnar on 1/7/11.   Copyright 2011 Innoli Kft. All rights reserved.

@interface AOPInterceptorInfo : NSObject

@property(unsafe_unretained) id interceptorTarget;
@property SEL interceptedSelector,
              interceptorSelector;
@end
