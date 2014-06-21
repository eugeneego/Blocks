//
// UIAlertView+EEBlocks.m
// EEBlocks
//
// Copyright (c) 2014 Eugene Ego. All rights reserved.
//

#import <objc/runtime.h>
#import "UIAlertView+EEBlocks.h"

static char EEUIAlertViewBlockDelegateKey;

@interface UIAlertView ()<UIAlertViewDelegate>
@end

@implementation UIAlertView (EEBlocks)

+ (void)showWithSetup:(EEUIAlertViewSetupBlock)setup completion:(EEUIAlertViewCompletionBlock)completion
{
  UIAlertView *alertView = [[UIAlertView alloc] init];
  if(setup)
    setup(alertView);
  alertView.block = completion;
  [alertView show];
}

- (void)setBlock:(EEUIAlertViewCompletionBlock)block
{
  self.delegate = block ? self : nil;
  objc_setAssociatedObject(self, &EEUIAlertViewBlockDelegateKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  EEUIAlertViewCompletionBlock block = objc_getAssociatedObject(alertView, &EEUIAlertViewBlockDelegateKey);
  if(block)
    block(alertView, buttonIndex);
}

@end