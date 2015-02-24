#import <Foundation/Foundation.h>

typedef void (^EEUIAlertViewSetupBlock)(UIAlertView *alertView);
typedef void (^EEUIAlertViewCompletionBlock)(UIAlertView *alertView, NSInteger buttonIndex);

@interface UIAlertView (EEBlocks)

+ (void)showWithSetup:(EEUIAlertViewSetupBlock)setup completion:(EEUIAlertViewCompletionBlock)completion;

@end