
#import <GHUnitIOS/GHUnit.h>
#import "Hardware.h"


@interface HardwareTest : GHTestCase { }
@end


@implementation HardwareTest

- (void)testIsAvailableAR {
    [Hardware isAvailableAR];
}

- (void) testIsAvailableHeading {
    BOOL headingAvailable = [CLLocationManager headingAvailable];
    trace(@"headingAvailable: %@", headingAvailable?@"YES":@"NO");
}

- (void)testPixelSizeOfScreen {
    CGSize pixelSizeOfScreen = [Hardware pixelSizeOfScreen];
    trace(@"pixelSizeOfScreen: {%f,%f}", pixelSizeOfScreen.width, pixelSizeOfScreen.height);
}

- (void)testIsEnabledLocationServices {
    BOOL isEnabledLocationServices = [Hardware isEnabledLocationServices];
    trace(@"isEnabledLocationServices: %@", isEnabledLocationServices?@"YES":@"NO");
}

@end