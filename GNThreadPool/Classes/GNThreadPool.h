//
//  GNThreadPool.h
//  GNThreadPool
//
//  Created by Games Neox - 2016
//  Copyright © 2016 Games Neox. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSUInteger, GNThreadPriority) {
    GNThreadPriorityNormal,
    GNThreadPriorityHigher
};


__attribute__((objc_subclassing_restricted))
@interface GNThreadPool : NSObject

/**
 * @pre {@code threadsAmount} is positive
 */
- (instancetype _Nonnull)initWithThreadsAmount:(uint)threadsAmount withPriority:(GNThreadPriority)priority;

/**
 * @pre {@code task} is not a {@code nil} pointer
 *
 * @return {code YES} if the provided {@code task} has successfully been enqueued, otherwise - {@code NO}
 */
- (BOOL)enqueue:(void (^ _Nonnull)())task;

/**
 * @return a non-empty container of threads' names.
 */
- (NSArray<NSString*>* _Nonnull)getThreadNames;

/**
 * @pre this method has not been called before
 *
 * @post any scheduled (by the {@code enqueue} method) task to be executed by this thread pool will be immediately
 *         rejected
 */
- (void)clear;

@end
