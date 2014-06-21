//
// EEBlock.h
// EEBlocks
//
// Copyright (c) 2014 Eugene Ego. All rights reserved.
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
+ (void)doOnQueue:(dispatch_queue_t)queue block:(EEBlockEmpty)block;
+ (void)doOnQueue:(dispatch_queue_t)queue block:(EEBlockEmpty)block afterDelay:(NSTimeInterval)delay;
+ (void)doOnMainQueue:(EEBlockEmpty)block;
+ (void)doOnMainQueue:(EEBlockEmpty)block afterDelay:(NSTimeInterval)delay;

// Background tasks
+ (void)doWithBackgroundTask:(void (^)(EEBlockEmpty completionHandler))block;
+ (void)doOnQueue:(dispatch_queue_t)queue withBackgroundTask:(void (^)(EEBlockEmpty completionHandler))block;
+ (void)doOnMainQueueWithBackgroundTask:(void (^)(EEBlockEmpty completionHandler))block;

@end