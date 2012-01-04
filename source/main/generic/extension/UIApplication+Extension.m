
#import "UIApplication+Extension.h"

@implementation UIApplication (Extension)

static NSInteger __activityCount = 0;

- (void)showNetworkActivityIndicator {
    if ( __activityCount == 0 ) {
        [self setNetworkActivityIndicatorVisible:YES];
    }
    __activityCount++;
}

- (void)hideNetworkActivityIndicator {
    __activityCount--;
    if ( __activityCount == 0 ) {
        [self setNetworkActivityIndicatorVisible:NO];
    }    
}


@end
