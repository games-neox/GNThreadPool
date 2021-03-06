//
//  GNThreadPoolTest+Death.m
//  GNThreadPool
//
//  Created by Games Neox - 2016
//  Copyright © 2016 Games Neox. All rights reserved.
//

#import "GNThreadPoolTest.h"

#import <GNExceptions/GNIllegalArgumentException.h>
#import <GNExceptions/GNIllegalStateException.h>
#import <GNExceptions/GNNilPointerException.h>
#import <GNTesting/GNAsyncTaskToken.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"



@implementation GNThreadPoolTest (Death)

/**
 * invalid ({@code zero}) threadAmount provided
 */
- (void)testDeathInitWithThreadsAmountWithPriority0
{
    XCTAssertThrowsSpecificNamed([[GNThreadPool alloc] initWithThreadsAmount:0 withPriority:defaultThreadPriority_],
            GNIllegalArgumentException, [GNIllegalArgumentException defaultName]);

    [threadPool_ clear];
}


/**
 * invalid priority provided
 */
- (void)testDeathInitWithThreadsAmountWithPriority1
{
    XCTAssertThrowsSpecificNamed([[GNThreadPool alloc] initWithThreadsAmount:3 withPriority:45],
            GNIllegalArgumentException, [GNIllegalArgumentException defaultName]);

    [threadPool_ clear];
}


/**
 * invalid ({@code nil}) task provided
 */
- (void)testDeathEnqueue
{
    XCTAssertThrowsSpecificNamed([threadPool_ enqueue:nil], GNNilPointerException, [GNNilPointerException defaultName]);

    [threadPool_ clear];
}


/**
 * method called twice in a row
 */
- (void)testDeathClear
{
    [threadPool_ clear];

    XCTAssertThrowsSpecificNamed([threadPool_ clear], GNIllegalStateException, [GNIllegalStateException defaultName]);
}

@end


#pragma clang diagnostic pop
