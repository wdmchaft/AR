
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Hardware.h"
#import "XYZLowPassFilter.h"

// times per second we are updating the UI
#define UI_UPDATE_HERTZ 25;

// Radians to Degrees. Usage: RADIANS_TO_DEGREES(0.785398)
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

// Degrees to radians. Usage: DEGREES_TO_RADIANS(45)
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)



@interface ARPickerController : UIImagePickerController <UIAccelerometerDelegate, CLLocationManagerDelegate>

// configuration
@property (nonatomic, assign) FieldOfView        fieldOfView;       // camera field of view
@property (nonatomic, retain) CLLocation        *locationTarget;    // target location
@property (nonatomic, retain) CLLocation        *locationCurrent;   // current location
@property (nonatomic, assign) LowPassFilterMode  lowPassFilterMode; // filter mode
@property (nonatomic, assign) BOOL               showFPS;           // whether to show FPS

// UI
@property (nonatomic, retain) UILabel      *uiFpsLabel;      // fps label
@property (nonatomic, retain) UIView       *uiOverlayView;   // parent overlay view
@property (nonatomic, retain) UILabel      *uiSensorsLabel;  // top bar with sensors
@property (nonatomic, retain) UIImageView  *uiTargetIcon;    // marker for the target (laughingman)

// derived configuration (calculated once from the configuration data)
@property (nonatomic, assign) float horizontalPointsPerDegree;  // h points per degree
@property (nonatomic, assign) float horizontalDegreesPerPoint;  // h degrees per point
@property (nonatomic, assign) float verticalPointsPerDegree;    // v points per degree
@property (nonatomic, assign) float verticalDegreesPerPoint;    // v degrees per point

// sensors source
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CMMotionManager   *motionManager;

// state
@property (nonatomic, assign) short framesPerSecond;  // frames per second
@property (nonatomic, assign) CLLocationDirection magCompassHeadingInDeg; // heading
@property (nonatomic, assign) CLLocationDirection offsetToTargetInDeg;    // offset to target
@property (nonatomic, assign) double zAxisAngle;      // z angle from the accelerometer
@property (nonatomic, assign) double xAxisAngle;      // x angle from the accelerometer

// filter
@property (nonatomic, retain) XYZLowPassFilter *accelerationLowPassFilter;


// returns true 'UI_UPDATE_HERTZ' times per second
-(BOOL) allowUpdate:(NSTimeInterval)timeIntervalSinceReferenceDate;

// creates the view if needed
-(UIView*) uiOverlayView;

-(void) startSensorUpdates;
-(void) stopSensorUpdates;

@end
