//
//  GNThreadPoolTest+Death.m
//  GNThreadPool
//
//  Created by Games Neox - 2016
//  Copyright © 2016 Games Neox. All rights reserved.
//

#import "GNThreadPoolTest.h"

#import "GNIllegalArgumentException.h"
#import "GNIllegalStateException.h"
#import "GNNilPointerException.h"
#import "GNAsyncTaskToken.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"



@implementation GNThreadPoolTest (Death)

/**
 * invalid ({@code zero}) threadAmount provided
 */
- (void)testDeathInitWithThreadsAmountWithPriority
{
    XCTAssertThrowsSpecificNamed([[GNThreadPool alloc] initWithThreadsAmount:0 withPriority:defaultThreadPriority_],
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
