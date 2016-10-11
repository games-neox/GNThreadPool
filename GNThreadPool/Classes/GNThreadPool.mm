//
//  GNThreadPool.m
//  GNThreadPool
//
//  Created by Games Neox - 2016
//  Copyright © 2016 Games Neox. All rights reserved.
//

#import <GNThreadPool/GNThreadPool.h>

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
    NSArray<NSThread*>* workers_;
    std::queue<std::function<void()>> tasks_;

    std::mutex queueMutex_;
    std::condition_variable condition_;
    bool stop_;
}

- (void)workerMethod:(id)parameter;

- (void)joinWorkers;

@end


static const NSString* const LOG_TAG = @"GNThreadPool";


@implementation GNThreadPool

- (nonnull instancetype)initWithThreadsAmount:(uint)threadsAmount withPriority:(GNThreadPriority)priority
{
    [GNPreconditions checkCondition:(0 < threadsAmount) :[GNIllegalArgumentException class] :@"0 < threadsAmount!"];
    [GNPreconditions checkCondition:((GNThreadPriorityNormal == priority) || (GNThreadPriorityHigher == priority))
            :[GNIllegalArgumentException class] :@"priority!"];

    self = [super init];
    if (nil != self) {
        NSMutableArray<NSThread*>* workers = [[NSMutableArray alloc] init];

        for (uint i = 0; i < threadsAmount; ++i) {
            NSThread* newThread = [[NSThread alloc] initWithTarget:self selector:@selector(workerMethod:) object:nil];
            [workers addObject:newThread];
            if (GNThreadPriorityHigher == priority) {
                newThread.threadPriority = 1.f;
            }
            [newThread start];
        }

        workers_ = workers;
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


- (BOOL)enqueue:(nonnull void (^)())task
{
    [GNPreconditions checkNotNil:task :@"task!"];

    auto taskWrapper = std::make_shared<std::packaged_task<void()>>([task] {
        task();
    });

    {
        std::lock_guard<std::mutex> queueLock(queueMutex_);

        if (stop_) {
            return NO;
        }

        tasks_.emplace([taskWrapper]() { (*taskWrapper)(); });
    }
    condition_.notify_one();

    return YES;
}


- (nonnull NSArray<NSString*>*)getThreadNames
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

    workers_ = @[];
}

@end
