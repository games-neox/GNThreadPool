//
//  GNThreadPoolTest.m
//  GNThreadPool
//
//  Created by Games Neox - 2016
//  Copyright © 2016 Games Neox. All rights reserved.
//

#import "GNThreadPoolTest.h"

#import "GNAsyncTaskToken.h"



@implementation GNThreadPoolTest

- (void)setUp
{
    [super setUp];

    defaultThreadName_ = @"default_thread_name";

    defaultThreadPriority_ = GNThreadPriorityHigher;

    __weak GNThreadPoolTest* weakSelf = self;
    defaultFatalTaskBlock_ = ^{
        GNThreadPoolTest* self = weakSelf;
        if (nil != self) {
            XCTFail(@"defaultFatalTaskBlock_!");
        }
    };

    threadPool_ = [[GNThreadPool alloc] initWithThreadsAmount:1 withPriority:defaultThreadPriority_];

    __block GNAsyncTaskToken* asyncTaskToken = [GNAsyncTaskToken createNew];
    XCTAssertTrue([threadPool_ enqueue:^{
        [NSThread currentThread].name = self->defaultThreadName_;

        [asyncTaskToken unlock];
    }]);
    [asyncTaskToken lock:DEFAULT_TESTING_SHORT_TIMEOUT];
}


- (void)tearDown
{
    defaultFatalTaskBlock_ = nil;

    defaultThreadName_ = nil;

    threadPool_ = nil;
    
    [super tearDown];
}

@end

