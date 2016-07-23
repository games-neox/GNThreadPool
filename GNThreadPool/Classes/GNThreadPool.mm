//
//  GNThreadPool.m
//  GNThreadPool
//
//  Created by Games Neox - 2016
//  Copyright © 2016 Games Neox. All rights reserved.
//

#import "GNThreadPool.h"

#import <GNExceptions/GNIllegalArgumentException.h>
#import <GNExceptions/GNIllegalStateException.h>
#import <GNLog/GNLog.h>
#import <GNPreconditions/GNPreconditions.h>

#import <condition_variable>
#import <functional>
#import <future>
#import <memory>
#import <mutex>
#import <queue>



@interface GNThreadPool ()
{
@private
    // need to keep track of threads so we can join them
    NSMutableArray<NSThread*>* workers_;
    // the task queue
    std::queue<std::function<void()>> tasks_;

    // synchronization
    std::mutex queueMutex_;
    std::condition_variable condition_;
    bool stop_;
}

- (void)workerMethod:(id)parameter;

- (void)joinWorkers;

@end


static const NSString* const LOG_TAG = @"ThreadPool";


@implementation GNThreadPool

- (instancetype _Nonnull)initWithThreadsAmount:(uint)threadsAmount withPriority:(GNThreadPriority)priority
{
    [GNPreconditions checkCondition:(0 < threadsAmount) :[GNIllegalArgumentException class] :@"0 < threadsAmount!"];

    self = [super init];
    if (nil != self) {
        workers_ = [[NSMutableArray alloc] init];

        for (uint i = 0; i < threadsAmount; ++i) {
            NSThread* newThread = [[NSThread alloc] initWithTarget:self selector:@selector(workerMethod:) object:nil];
            [workers_ addObject:newThread];
            if (GNThreadPriorityHigher == priority) {
                newThread.threadPriority = 1.f;
            }
            [newThread start];
        }
    }

    return self;
}


- (void)dealloc
{
    {
        std::lock_guard<std::mutex> queueLock(queueMutex_);
        if (!stop_) {
            stop_ = true;
        } else {
            return;
        }
    }

    [self joinWorkers];
}


- (void)workerMethod:(id)parameter
{
    for (;;) {
        std::function<void()> task;

        {
            std::unique_lock<std::mutex> queueLock(queueMutex_);
            condition_.wait(queueLock, [self]() { return self->stop_ || !self->tasks_.empty(); });

            if (stop_ && tasks_.empty()) {
                return;
            }

            task = std::move(tasks_.front());
            tasks_.pop();
        }

        task();
    }
}


- (BOOL)enqueue:(void (^ _Nonnull)())task
{
    [GNPreconditions checkNotNil:task :@"task!"];

    auto taskWrapper = std::make_shared<std::packaged_task<void()>>([task] {
        task();
    });

    {
        std::lock_guard<std::mutex> queueLock(queueMutex_);

        // don't allow enqueueing after stopping the pool
        if (stop_) {
            // enqueue on stopped ThreadPool
            return NO;
        }

        tasks_.emplace([taskWrapper]() { (*taskWrapper)(); });
    }
    condition_.notify_one();

    return YES;
}


- (NSArray<NSString*>* _Nonnull)getThreadNames
{
    LOG_WRITE_VERBOSE(LOG_TAG, @"getThreadNames(): Enter");

    std::unique_lock<std::mutex> queueLock(queueMutex_);

    NSMutableArray<NSString*>* workerNames = [[NSMutableArray alloc] init];

    for (NSThread* worker : workers_) {
        [workerNames addObject:worker.name];
    }

    queueLock.unlock();

    LOG_PRINT_VERBOSE(LOG_TAG, @"getThreadNames(): Exit(%@)", workerNames);

    return workerNames;
}


- (void)clear
{
    {
        std::lock_guard<std::mutex> queueLock(queueMutex_);
        [GNPreconditions checkCondition:!stop_ :[GNIllegalStateException class] :@"!stop!"];
        stop_ = true;
        std::queue<std::function<void()>> emptyQueue;
        tasks_.swap(emptyQueue);
    }

    [self joinWorkers];
}


- (void)joinWorkers
{
    condition_.notify_all();
    
    workers_ = [@[] mutableCopy];
}

@end
