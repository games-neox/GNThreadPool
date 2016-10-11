//
//  GNThreadPoolTest.h
//  GNThreadPool
//
//  Created by Games Neox - 2016
//  Copyright © 2016 Games Neox. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <GNThreadPool/GNThreadPool.h>

#define DEFAULT_TESTING_SHORT_TIMEOUT ((NSTimeInterval) 5.f)



@interface GNThreadPoolTest : XCTestCase
{
@private
    GNThreadPool* threadPool_;

    NSString* defaultThreadName_;
    GNThreadPriority defaultThreadPriority_;
    void (^defaultFatalTaskBlock_)();
}

@end
