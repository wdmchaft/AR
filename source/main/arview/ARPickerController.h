
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Hardware.h"
#import "XYZLowPassFilter.h"
#import "OverlayView.h"
#import "CMMMSingleton.h"
#import "ARState.h"
#import "Macros.h"
#import "Device.h"

// Times per seconds the sensors are reporting a value.
// Accelerometer update rate is up to 100Hz, Gyroscope is between 58Hz and 76Hz.
#define SENSORS_UPDATE_HERTZ 30.0

/* Value for the formula (screen_refresh_rate/FRAMES_DIVIDER)=FPS, which
 * decides the number of frames to paint per second. Given that screen_refresh 
 * is 60Hz on all iOS devices, a value of 6 means 60/6=10 FPS.
 * Each frame requested with a call to the method drawView: of ARPickerController.
 */
#define FRAMES_DIVIDER 2.0 // 60/FRAMES_DIVIDER = FPS, 2=30


@interface ARPickerController : UIImagePickerController <UIAccelerometerDelegate, CLLocationManagerDelegate> {
@private 
    CADisplayLink *displayLink;
}

// configuration
@property (nonatomic, assign) BOOL showFPS; // whether to show FPS
@property (nonatomic, assign) short framesPerSecond; // stores the current frames per second
@property (nonatomic, assign) BOOL accelMode;

@property (nonatomic, retain) OverlayView *overlayView; //UI

// heading and stuff
@property (nonatomic, retain) ARState *state;

// sensors source
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CMMotionManager *motionManager;

// filter
@property (nonatomic, retain) XYZLowPassFilter *accelerationLowPassFilter;
@property (nonatomic, assign) LowPassFilterMode lowPassFilterMode;

@property (nonatomic, retain) Device *device;

- (void) drawFPSCounter;

/*
// returns true 'UI_UPDATE_HERTZ' times per second
-(BOOL) allowUpdate:(NSTimeInterval)timeIntervalSinceReferenceDate;

// creates the view if needed
-(UIView*) uiOverlayView;

-(void) startSensorUpdates;
-(void) stopSensorUpdates;
*/

@end

@interface ARPickerController (gyroscope) 
@end


