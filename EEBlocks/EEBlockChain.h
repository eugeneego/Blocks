//
// EEBlockChain.h
// EEBlocks
//
// Copyright (c) 2014 Eugene Ego. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EEBlockChain;

typedef void (^EEBlockChainCompletionCallback)(id result, NSError *error);
typedef void (^EEBlockChainResultCallback)(EEBlockChain *blockChain, id previousResult, EEBlockChainCompletionCallback completion);
typedef void (^EEBlockChainErrorCallback)(EEBlockChain *blockChain, NSError *error);

@interface EEBlockChain: NSObject

+ (instancetype)blockChain;
+ (instancetype)blockChainWithQueue:(dispatch_queue_t)queue;

- (instancetype)initWithQueue:(dispatch_queue_t)queue;

- (instancetype)first:(EEBlockChainResultCallback)resultCallback;
- (instancetype)then:(EEBlockChainResultCallback)resultCallback;
- (instancetype)error:(EEBlockChainErrorCallback)errorCallback;

- (void)start;
- (void)startWithResult:(id)initialResult error:(NSError *)initialError;
- (void)stop;
- (void)pause;
- (void)resume;
- (void)retry;

@end
