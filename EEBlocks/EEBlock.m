//
// EEBlock.m
// EEBlocks
//
// Copyright (c) 2014 Eugene Ego. All rights reserved.
//

#import "EEBlock.h"

@implementation EEBlock

#pragma mark - Queues

+ (dispatch_queue_t)mainQueue
{
  return dispatch_get_main_queue();
}

+ (dispatch_queue_t)queueWithPriority:(dispatch_queue_priority_t)priority
{
  return dispatch_get_global_queue(priority, 0);
}

+ (dispatch_queue_t)queueWithDefaultPriority
{
  return [self queueWithPriority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
}

+ (dispatch_queue_t)queueWithHighPriority
{
  return [self queueWithPriority:DISPATCH_QUEUE_PRIORITY_HIGH];
}

+ (dispatch_queue_t)queueWithLowPriority
{
  return [self queueWithPriority:DISPATCH_QUEUE_PRIORITY_LOW];
}

+ (dispatch_queue_t)queueWithBackgroundPriority
{
  return [self queueWithPriority:DISPATCH_QUEUE_PRIORITY_BACKGROUND];
}

#pragma mark - Async

+ (void)doOnQueue:(dispatch_queue_t)queue block:(EEBlockEmpty)block
{
  dispatch_async(queue, block);
}

+ (void)doOnQueue:(dispatch_queue_t)queue block:(EEBlockEmpty)block afterDelay:(NSTimeInterval)delay
{
  int64_t delta = (int64_t)(NSEC_PER_SEC * delay);
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), queue, block);
}

+ (void)doOnMainQueue:(EEBlockEmpty)block
{
  [self doOnQueue:[self mainQueue] block:block];
}

+ (void)doOnMainQueue:(EEBlockEmpty)block afterDelay:(NSTimeInterval)delay
{
  [self doOnQueue:[self mainQueue] block:block afterDelay:delay];
}

#pragma mark - Background tasks

+ (void)doWithBackgroundTask:(void (^)(EEBlockEmpty completionHandler))block
{
  __block UIBackgroundTaskIdentifier bgTask;

  EEBlockEmpty completionHandler = ^
  {
    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
  };

  bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:completionHandler];

  block(completionHandler);
}

+ (void)doOnQueue:(dispatch_queue_t)queue withBackgroundTask:(void (^)(EEBlockEmpty completionHandler))block
{
  __block UIBackgroundTaskIdentifier bgTask;

  EEBlockEmpty completionHandler = ^
  {
    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
  };

  bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:completionHandler];

  [self doOnQueue:queue block:^
  {
    block(completionHandler);
  }];
}

+ (void)doOnMainQueueWithBackgroundTask:(void (^)(EEBlockEmpty completionHandler))block
{
  [self doOnQueue:[self mainQueue] withBackgroundTask:block];
}

@end