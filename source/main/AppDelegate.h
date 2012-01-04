
#import <UIKit/UIKit.h>
#import "ATMHud.h"

@class ARViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ARViewController *viewController;

@end