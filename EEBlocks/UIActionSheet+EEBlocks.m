#import <objc/runtime.h>
#import "UIActionSheet+EEBlocks.h"

static char EEUIActionSheetBlockDelegateKey;

@interface UIActionSheet ()<UIActionSheetDelegate>
@end

@implementation UIActionSheet (EEBlocks)

+ (void)setup:(EEUIActionSheetBlock)setup show:(EEUIActionSheetBlock)show completion:(EEUIActionSheetCompletionBlock)completion
{
  UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
  if(setup)
    setup(actionSheet);
  actionSheet.block = completion;
  if(show)
    show(actionSheet);
}

- (void)setBlock:(EEUIActionSheetCompletionBlock)block
{
  self.delegate = block ? self : nil;
  objc_setAssociatedObject(self, &EEUIActionSheetBlockDelegateKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  EEUIActionSheetCompletionBlock block = objc_getAssociatedObject(actionSheet, &EEUIActionSheetBlockDelegateKey);
  if(block)
    block(actionSheet, buttonIndex);
}

@end