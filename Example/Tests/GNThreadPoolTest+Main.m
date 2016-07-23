//
//  GNThreadPoolTest+Main.m
//  GNThreadPool
//
//  Created by Games Neox - 2016
//  Copyright © 2016 Games Neox. All rights reserved.
//

#import "GNThreadPoolTest.h"

#import "GNAsyncTaskToken.h"



@implementation GNThreadPoolTest (Main)

/**
 * correct flow
 */
- (void)testClear
{
    [threadPool_ clear];
}


/**
 * correct flow
 */
- (void)testGetThreadNames0
{
    NSArray<NSString*>* threadNames = [threadPool_ getThreadNames];

    XCTAssertNotNil(threadNames);
    XCTAssertEqual(1, threadNames.count);
    XCTAssertEqual(defaultThreadName_, [threadNames objectAtIndex:0]);

    [threadPool_ clear];
}


/**
 * correct flow
 */
- (void)testGetThreadNames1
{
    [threadPool_ clear];

    NSArray<NSString*>* threadNames = [threadPool_ getThreadNames];

    XCTAssertNotNil(threadNames);
    XCTAssertEqual(0, threadNames.count);
}


/**
 * correct flow
 */
- (void)testEnqueue
{
    __block GNAsyncTaskToken* asyncTaskToken = [GNAsyncTaskToken createNew];

    [threadPool_ enqueue:^{
        XCTAssertEqual(self->defaultThreadName_, [NSThread currentThread].name);

        [asyncTaskToken unlock];
    }];
    [asyncTaskToken lock:DEFAULT_TESTING_SHORT_TIMEOUT];

    [threadPool_ clear];
}

@end
