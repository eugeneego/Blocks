//
// EEBlockChain.h
// EEBlocks
//
// Copyright (c) 2014 Eugene Egorov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EEBlock.h"

@class EEBlockChain;

typedef void (^EEBlockChainCompletionCallback)(id result, NSError *error);
typedef void (^EEBlockChainResultCallback)(EEBlockChain *blockChain, id previousResult, EEBlockChainCompletionCallback completion);
typedef void (^EEBlockChainFinishCallback)(EEBlockChain *blockChain, id result, NSError *error, EEBlockEmpty completion);

@interface EEBlockChain: NSObject

+ (instancetype)blockChain;
+ (instancetype)blockChainWithQueue:(dispatch_queue_t)queue;

- (instancetype)initWithQueue:(dispatch_queue_t)queue;

- (instancetype)firstDo:(EEBlockChainResultCallback)resultCallback;
- (instancetype)firstOnQueue:(dispatch_queue_t)queue do:(EEBlockChainResultCallback)resultCallback;
- (instancetype)thenDo:(EEBlockChainResultCallback)resultCallback;
- (instancetype)thenOnQueue:(dispatch_queue_t)queue do:(EEBlockChainResultCallback)resultCallback ;
- (instancetype)atFinishDo:(EEBlockChainFinishCallback)finishCallback;
- (instancetype)atFinishOnQueue:(dispatch_queue_t)queue do:(EEBlockChainFinishCallback)finishCallback;

- (void)start;
- (void)startWithBackgroundTask;
- (void)startWithResult:(id)initialResult error:(NSError *)initialError withBackgroundTask:(BOOL)backgroundTask;
- (void)stop;
- (void)pause;
- (void)resume;
- (void)retry;

@end
