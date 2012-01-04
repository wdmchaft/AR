
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import "CMMMSingleton.h"

struct FieldOfView {
    float horizontal;
    float vertical;
};
typedef struct FieldOfView FieldOfView;


/** Device capabilities. */
@interface Hardware : NSObject


/** @return TRUE if the accelerometer is available. */
+(BOOL) isAvailableAccelerometer;


/** @return TRUE If this device is able to run AR applications. */
+(BOOL) isAvailableAR;


/** @return TRUE if the camera is available. */
+(BOOL) isAvailableCamera;


/** @return TRUE if the gyroscope is available. */
+(BOOL) isAvailableGyro;


/** @return TRUE if the compass is available. */
+(BOOL) isAvailableHeading;


/** @return TRUE if location updates are enabled. */
+(BOOL) isEnabledLocationServices;


/** @return TRUE if the device has a retina display. */
+(BOOL) isRetinaDisplay;


/** 
 * Return the size in pixels of the entire screen (minus status bar if visible).
 * @return Size of the screen in pixels 
 */
+(CGSize) pixelSizeOfScreen;


/** 
 * Return the size in points of the entire screen (minus status bar if visible).
 * @return Size of the screen in points. 
 */
+(CGSize) pointSizeOfScreen;

/** 
 * Length of the diagonal from the center of the screen to one of the corners. 
 * @return Diagonal in points.
 */
+(double) diagonalFromCenter;


+(FieldOfView) fieldOfView;


// /**
//  * @return Screen size.
//  */
// +(CGSize)screenSizePortrait;

@end


@interface Hardware (private)
+ (NSString *) getSysInfoByName:(char *)typeSpecifier;
+ (BOOL) isIPod;
+ (BOOL) isIPad;
+ (BOOL) isIPhone;
@end

