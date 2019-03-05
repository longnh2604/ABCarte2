//
//  OCCatch.h
//  ABCarte2
//
//  Created by Long on 2019/01/21.
//  Copyright © 2019 Oluxe. All rights reserved.
//

#ifndef OCCatch_h
#define OCCatch_h

#import <Foundation/Foundation.h>

NS_INLINE NSException * _Nullable tryBlock(void(^_Nonnull tryBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}

#endif /* OCCatch_h */
