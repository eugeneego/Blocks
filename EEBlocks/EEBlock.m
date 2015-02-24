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

+ (void)onQueue:(dispatch_queue_t)queue do:(EEBlockEmpty)block
{
  dispatch_async(queue, block);
}

+ (void)onMainQueueDo:(EEBlockEmpty)block
{
  [self onQueue:[self mainQueue] do:block];
}

+ (void)afterDelay:(NSTimeInterval)delay onQueue:(dispatch_queue_t)queue do:(EEBlockEmpty)block
{
  int64_t delta = (int64_t)(NSEC_PER_SEC * delay);
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), queue, block);
}

+ (void)afterDelay:(NSTimeInterval)delay onMainQueueDo:(EEBlockEmpty)block
{
  [self afterDelay:delay onQueue:[self mainQueue] do:block];
}

#pragma mark - Background tasks

+ (void)withBackgroundTaskDo:(void (^)(EEBlockEmpty completionHandler))block
{
  __block UIBackgroundTaskIdentifier bgTask;

  EEBlockEmpty completionHandler = ^{
    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
  };

  bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:completionHandler];

  block(completionHandler);
}

+ (void)onQueue:(dispatch_queue_t)queue withBackgroundTaskDo:(void (^)(EEBlockEmpty completionHandler))block
{
  __block UIBackgroundTaskIdentifier bgTask;

  EEBlockEmpty completionHandler = ^{
    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
  };

  bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:completionHandler];

  [self onQueue:queue do:^{
    block(completionHandler);
  }];
}

+ (void)onMainQueueWithBackgroundTaskDo:(void (^)(EEBlockEmpty completionHandler))block
{
  [self onQueue:[self mainQueue] withBackgroundTaskDo:block];
}

@end