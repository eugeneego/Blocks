//
// EEBlockChain.m
// EEBlocks
//
// Copyright (c) 2014 Eugene Ego. All rights reserved.
//

#import "EEBlockChain.h"
#import "EEBlock.h"

@implementation EEBlockChain
{
  dispatch_queue_t _queue;
  NSMutableArray *_callbacks;
  EEBlockChainErrorCallback _errorCallback;

  BOOL _started;
  BOOL _paused;
  BOOL _stopped;

  id _previousResult;
  NSError *_previousError;
  EEBlockChainResultCallback _currentCallback;
}

+ (instancetype)blockChain
{
  return [[self alloc] initWithQueue:nil];
}

+ (instancetype)blockChainWithQueue:(dispatch_queue_t)queue
{
  return [[self alloc] initWithQueue:queue];
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue
{
  self = [super init];
  if(self) {
    _queue = queue ? queue : dispatch_get_main_queue();
    _callbacks = [NSMutableArray array];
  }
  return self;
}

- (instancetype)first:(EEBlockChainResultCallback)resultCallback
{
  [_callbacks insertObject:resultCallback atIndex:0];
  return self;
}

- (instancetype)then:(EEBlockChainResultCallback)resultCallback
{
  [_callbacks addObject:resultCallback];
  return self;
}

- (instancetype)error:(EEBlockChainErrorCallback)errorCallback
{
  _errorCallback = errorCallback;
  return self;
}

- (void)start
{
  [self startWithResult:_previousResult error:_previousError];
}

- (void)startWithResult:(id)initialResult error:(NSError *)initialError
{
  if(!_started && _callbacks.count > 0) {
    dispatch_async(_queue, ^
    {
      if(!_started && _callbacks.count > 0) {
        _started = YES;
        [self nextWithResult:initialResult error:initialError];
      }
    });
  }
}

- (void)stop
{
  if(_started) {
    _stopped = YES;
  }
}

- (void)pause
{
  if(_started) {
    _paused = YES;
  }
}

- (void)resume
{
  if(_started && _paused) {
    [EEBlock doOnQueue:_queue block:^
    {
      if(_started && _paused) {
        _paused = NO;
        [self nextWithResult:_previousResult error:_previousError];
      }
    }];
  }
}

- (void)retry
{
  if(_currentCallback) {
    [_callbacks insertObject:_currentCallback atIndex:0];
  }
}

- (void)nextWithResult:(id)previousResult error:(NSError *)previousError
{
  _previousResult = previousResult;
  _previousError = previousError;

  if(_stopped || _callbacks.count == 0) {
    [self finish];
  } else if(previousError) {
    if(_errorCallback) {
      _errorCallback(self, previousError);
    }
    [self finish];
  } else if(!_paused) {
    _currentCallback = _callbacks.firstObject;
    [_callbacks removeObjectAtIndex:0];

    _currentCallback(self, previousResult, ^(id result, NSError *error)
    {
      [EEBlock doOnQueue:_queue block:^
      {
        [self nextWithResult:result error:error];
      }];
    });
  }
}

- (void)finish
{
  _started = NO;
  _paused = NO;
  _stopped = NO;
  _previousResult = nil;
  _previousError = nil;
  _currentCallback = nil;
}

@end