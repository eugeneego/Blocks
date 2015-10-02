//
// EEBlock.h
// EEBlocks
//
// Copyright (c) 2014 Eugene Egorov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^EEBlockEmpty)(void);

@interface EEBlock: NSObject

// Queues
+ (dispatch_queue_t)mainQueue;
+ (dispatch_queue_t)queueWithPriority:(dispatch_queue_priority_t)priority;
+ (dispatch_queue_t)queueWithDefaultPriority;
+ (dispatch_queue_t)queueWithHighPriority;
+ (dispatch_queue_t)queueWithLowPriority;
+ (dispatch_queue_t)queueWithBackgroundPriority;

// Async
+ (void)onQueue:(dispatch_queue_t)queue do:(EEBlockEmpty)block;
+ (void)onMainQueueDo:(EEBlockEmpty)block;
+ (void)afterDelay:(NSTimeInterval)delay onQueue:(dispatch_queue_t)queue do:(EEBlockEmpty)block;
+ (void)afterDelay:(NSTimeInterval)delay onMainQueueDo:(EEBlockEmpty)block;

// Background tasks
+ (void)withBackgroundTaskDo:(void (^)(EEBlockEmpty completionHandler))block;
+ (void)onQueue:(dispatch_queue_t)queue withBackgroundTaskDo:(void (^)(EEBlockEmpty completionHandler))block;
+ (void)onMainQueueWithBackgroundTaskDo:(void (^)(EEBlockEmpty completionHandler))block;

@end