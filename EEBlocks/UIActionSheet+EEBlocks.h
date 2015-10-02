//
// UIActionSheet+EEBlocks.h
// EEBlocks
//
// Copyright (c) 2014 Eugene Egorov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^EEUIActionSheetBlock)(UIActionSheet *actionSheet);
typedef void (^EEUIActionSheetCompletionBlock)(UIActionSheet *actionSheet, NSInteger buttonIndex);

@interface UIActionSheet (EEBlocks)

+ (void)setup:(EEUIActionSheetBlock)setup show:(EEUIActionSheetBlock)show completion:(EEUIActionSheetCompletionBlock)completion;

@end