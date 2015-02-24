#import "EEBlockChain.h"

@interface EEBlockChainCallbackHolder: NSObject

@property (nonatomic, copy) id callback;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation EEBlockChainCallbackHolder

- (instancetype)initWithCallback:(id)callback queue:(dispatch_queue_t)queue
{
  self = [super init];
  if(self) {
    self.callback = callback;
    self.queue = queue;
  }
  return self;
}

@end

@implementation EEBlockChain
{
  dispatch_queue_t _queue;
  NSMutableArray *_callbacks;
  EEBlockChainCallbackHolder *_finishCallback;

  BOOL _started;
  BOOL _paused;
  BOOL _stopped;

  id _previousResult;
  NSError *_previousError;
  EEBlockChainCallbackHolder *_currentCallback;

  EEBlockEmpty bgTaskCompletion;
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
    _queue = queue ?: dispatch_get_main_queue();
    _callbacks = [NSMutableArray array];
  }
  return self;
}

#pragma mark - Blocks

- (instancetype)firstDo:(EEBlockChainResultCallback)resultCallback
{
  return [self firstOnQueue:_queue do:resultCallback];
}

- (instancetype)firstOnQueue:(dispatch_queue_t)queue do:(EEBlockChainResultCallback)resultCallback
{
  [_callbacks insertObject:[[EEBlockChainCallbackHolder alloc] initWithCallback:resultCallback queue:queue] atIndex:0];
  return self;
}

- (instancetype)thenDo:(EEBlockChainResultCallback)resultCallback
{
  return [self thenOnQueue:_queue do:resultCallback];
}

- (instancetype)thenOnQueue:(dispatch_queue_t)queue do:(EEBlockChainResultCallback)resultCallback
{
  [_callbacks addObject:[[EEBlockChainCallbackHolder alloc] initWithCallback:resultCallback queue:queue]];
  return self;
}

- (instancetype)onFinishDo:(EEBlockChainFinishCallback)finishCallback
{
  return [self onFinishOnQueue:_queue do:finishCallback];
}

- (instancetype)onFinishOnQueue:(dispatch_queue_t)queue do:(EEBlockChainFinishCallback)finishCallback
{
  _finishCallback = [[EEBlockChainCallbackHolder alloc] initWithCallback:finishCallback queue:queue];
  return self;
}

#pragma mark - Logic

- (void)start
{
  [self startWithResult:_previousResult error:_previousError withBackgroundTask:NO];
}

- (void)startWithBackgroundTask
{
  [self startWithResult:_previousResult error:_previousError withBackgroundTask:YES];
}

- (void)startWithResult:(id)initialResult error:(NSError *)initialError withBackgroundTask:(BOOL)backgroundTask
{
  if(!_started && _callbacks.count > 0) {
    dispatch_async(_queue, ^{
      if(!_started && _callbacks.count > 0) {
        if(backgroundTask) {
          __block UIBackgroundTaskIdentifier bgTask;
          bgTaskCompletion = ^{
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
          };
          bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:bgTaskCompletion];
        }

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
    [EEBlock onQueue:_queue do:^{
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

  if(_stopped || _callbacks.count == 0 || previousError) {
    if(_finishCallback) {
      [EEBlock onQueue:_finishCallback.queue do:^{
        ((EEBlockChainFinishCallback)_finishCallback.callback)(self, previousResult, previousError, ^{
          if(bgTaskCompletion) {
            bgTaskCompletion();
            bgTaskCompletion = nil;
          }
        });
      }];
    }
    [self finishAndEndBGTask:!_finishCallback];
  } else if(!_paused) {
    _currentCallback = _callbacks.firstObject;
    [_callbacks removeObjectAtIndex:0];

    [EEBlock onQueue:_currentCallback.queue do:^{
      ((EEBlockChainResultCallback)_currentCallback.callback)(self, previousResult, ^(id result, NSError *error) {
        [EEBlock onQueue:_queue do:^{
          [self nextWithResult:result error:error];
        }];
      });
    }];
  }
}

- (void)finishAndEndBGTask:(BOOL)endBGTask
{
  if(endBGTask && bgTaskCompletion) {
    bgTaskCompletion();
    bgTaskCompletion = nil;
  }

  _started = NO;
  _paused = NO;
  _stopped = NO;
  _previousResult = nil;
  _previousError = nil;
  _currentCallback = nil;
}

@end