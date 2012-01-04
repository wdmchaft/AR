
#import "ARPickerController.h"


@implementation ARPickerController (gyroscope)

/** 
 * Reset heading to a value from the compass 
 * if the given amount of seconds have gone by since the last call to this method,
 * otherwise the update is discarded.
 *
 * @param state    State
 * @param interval Interval in seconds.
 */
-(void) resetHeadingIn:(ARState*)state 
                 after:(double)interval 
{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    static NSTimeInterval lastHeadingReset = 0;
    if ((now-lastHeadingReset)>interval) {
        lastHeadingReset=now;
        state.headingPlusGyrosInDeg = state.heading.trueHeading;
    }
}


/**
 * Update heading with the rotation rate from the gyroscope.
 *
 * @param state        State
 * @param interval     Interval in seconds.
 * @param rotationRate Rotation rate in radians/s.
 */
-(void) updateHeadingIn:(ARState*)state 
                  after:(double)interval 
           rotationRate:(double)rotationRate 
{
    static double totalRotation = 0;
    static NSTimeInterval thisSecond = -1;
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if (now-thisSecond > interval){
        state.headingPlusGyrosInDeg += (RADIANS_TO_DEGREES(totalRotation))/interval;
        totalRotation=0;
        thisSecond=now;
    }
    totalRotation += rotationRate;
}

@end



@implementation ARPickerController

@synthesize overlayView;
@synthesize state;
@synthesize lowPassFilterMode, showFPS, accelMode;
@synthesize locationManager, motionManager;
@synthesize framesPerSecond;
@synthesize accelerationLowPassFilter, device;

/** Set the value of the FPS counter label. */
-(void) drawFPSCounter {
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if (self.showFPS) {
        // count fps
        static short fps = 0;
        static NSTimeInterval thisSecond = -1;
        if (now-thisSecond > 1){
            thisSecond = now;
            self.framesPerSecond=fps;
            fps=1;
        } else {
            fps++;
        }
        self.overlayView.guiFpsLabel.text = [NSString stringWithFormat:@"%d",self.framesPerSecond];
    }
}


- (void) drawView:(id)sender {

    [self drawFPSCounter];
 
    
    // HEADING TO THE TARGET
    double offsetToTargetInDeg = 0;
    {   
        // degrees away from the exact heading to the target
        if (self.accelMode){
            // using the compass only
            offsetToTargetInDeg = self.state.heading.trueHeading - self.state.headingToTargetInDeg;
        } else {
            // reset the heading to the compass value every .1 seconds
            [self resetHeadingIn:self.state after:.1];
            // update the value of the heading with the gyroscope
            [self updateHeadingIn:self.state after:.05 rotationRate:motionManager.gyroData.rotationRate.y];
            offsetToTargetInDeg = self.state.headingPlusGyrosInDeg - self.state.headingToTargetInDeg;        
        }
    }

    
    BOOL isPortrait = FALSE;
    double pitchInDeg = 0;
    {
        // APPLY THE EFFECTS OF PITCH
        // what is pitch? see http://en.wikipedia.org/wiki/Aircraft_principal_axes
        
        // calculate pitch
        double x,y;
        [self.accelerationLowPassFilter addAcceleration:motionManager.accelerometerData.acceleration];
        x = self.accelerationLowPassFilter.x;
        y = self.accelerationLowPassFilter.y;
        double newZAxisAngle = -atan2(y,x);
        
        // keep it cw
        const double const TWO_M_PI = 2*M_PI;
        if (newZAxisAngle<0) newZAxisAngle = TWO_M_PI + newZAxisAngle;
        
        // counter rotate the image so it stays vertical
        self.overlayView.guiTargetIcon.transform = CGAffineTransformMakeRotation(newZAxisAngle-M_PI_2);
        double pitchInDeg = RADIANS_TO_DEGREES(newZAxisAngle-M_PI_2);
        
        // at 25º we assume the user changed from portrait to landscape
        isPortrait = pitchInDeg>25;        
        if (isPortrait){
            offsetToTargetInDeg += pitchInDeg;
            if (offsetToTargetInDeg>360) offsetToTargetInDeg = fmod(360.0, offsetToTargetInDeg);
        }
    }
    
    
    {
        // UPDATE THE POSITION OF THE IMAGE
        // The angular distance where the image is visible is the angular distance of the camera plus half the size of the image.
        // Explanation: the center of the image is in the center of the image (width/2,height/2) so even when the image is painted 
        // out of the frame, half of it extends towards the frame.
        const float visibleAngularDistanceInDeg = self.device.visibleAngularDistanceInDeg 
                            + fabs(self.overlayView.guiTargetIcon.image.size.width/2 * self.device.horizontalDegreesPerPoint);
        BOOL visibleHorizontal = offsetToTargetInDeg < visibleAngularDistanceInDeg;    
        // hidden attribute of the marker image
        self.overlayView.guiTargetIcon.hidden = !visibleHorizontal;
        if (visibleHorizontal){
            CGPoint newCenter = { 0.0,0.0 };
            if (isPortrait){
                // apply the offset vertically
                newCenter.y = self.device.screenSizeInPoints.height/2 - self.device.verticalPointsPerDegree*offsetToTargetInDeg;
                newCenter.x = self.device.screenSizeInPoints.width/2;
            } else {
                // apply the offset horizontally
                newCenter.x = self.device.screenSizeInPoints.width/2 - self.device.horizontalPointsPerDegree*offsetToTargetInDeg;
                newCenter.y = self.device.screenSizeInPoints.height/2;
            }
            [self.overlayView.guiTargetIcon setCenter:newCenter];
        } 
    }

    
    {   
        // UPDATE THE SENSORS LABEL
        self.overlayView.guiSensorsLabel.backgroundColor = isPortrait ? [UIColor yellowColor] : [UIColor purpleColor];
        self.overlayView.guiSensorsLabel.textColor = isPortrait ? [UIColor blackColor] : [UIColor whiteColor];
        NSString *labelText = [NSString stringWithFormat:@"uh:%4.2fº   th:%4.2fº   o:%4.2fº   z:%4.2fº",
                               self.accelMode ? self.state.heading.trueHeading : self.state.headingPlusGyrosInDeg,
                               self.state.headingToTargetInDeg, 
                               offsetToTargetInDeg,
                               pitchInDeg
                              ];
        self.overlayView.guiSensorsLabel.text = labelText;
    }
    
}


/**
 * Start updating the screen.
 */
- (void) startAR {
    
    // update motion and acceleration
    [self.motionManager startDeviceMotionUpdates];
    [self.motionManager startAccelerometerUpdates];

    // update location and heading
	self.locationManager = [[[CLLocationManager alloc] init] autorelease];
	self.locationManager.delegate = self;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
	self.locationManager.distanceFilter = kCLDistanceFilterNone;
	self.locationManager.headingFilter = kCLHeadingFilterNone; // 5=report only changes>5 degrees, kCLHeadingFilterNone=report all
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    
    // start refreshing the view
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
    [displayLink setFrameInterval:FRAMES_DIVIDER]; // 60/x=FPS, x=2 means 60Hz/2=30 frames per second
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}


/**
 * Stop updating the screen.
 */
- (void)stopAR {
    if ([motionManager isDeviceMotionActive]){
        [self.motionManager stopAccelerometerUpdates];
        [self.motionManager stopDeviceMotionUpdates];
    }
    if (displayLink!=nil){
        [displayLink invalidate];
        displayLink = nil;
    }
}


#pragma mark - CLLocationManagerDelegate


- (void)locationManager:(CLLocationManager *) manager
    didUpdateToLocation:(CLLocation *) newLocation
           fromLocation:(CLLocation *) oldLocation {
    self.state.locationCurrent=newLocation;
}  


- (void)locationManager:(CLLocationManager *) manager 
       didUpdateHeading:(CLHeading *) newHeading {
    BOOL invalid = newHeading.headingAccuracy<0;
    if (!invalid){
        self.state.heading=newHeading;
    }
}


#pragma mark - View lifecycle


/** 
 * Dismiss this modal view controller.
 * Called from the info button in the camera screen. 
 */
- (void)backToConfigScreen:(id)sender {
    [self stopAR];
    [self dismissModalViewControllerAnimated:YES];
}


/**
 * Create the overlay GUI.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    trace(@"  Configuration:"); 
    trace(@"    filter=%d",self.lowPassFilterMode);
    trace(@"    show FPS=%@",self.showFPS?@"yes":@"no");
    trace(@"    target location={%f,%f}",self.state.locationTarget.coordinate.latitude,self.state.locationTarget.coordinate.longitude);

    {
        // overlay UI
        self.overlayView = [[OverlayView alloc] initWithFrame:self.view.frame];
        [self.overlayView.infoButton addTarget:self action:@selector(backToConfigScreen:) forControlEvents:UIControlEventTouchUpInside]; 
        self.cameraOverlayView = overlayView;

        // @hack
        // How many degrees to go beyond the border of the screen until half the image disappears.
        // We need to do this because when the center reaches the border, half the image is still visible.
        float halfImageHorizontalDegrees = self.overlayView.guiTargetIcon.image.size.width/2 * self.device.horizontalDegreesPerPoint;
        self.device.visibleAngularDistanceInDeg = fabs(self.device.fieldOfView.horizontal/2) + fabs(halfImageHorizontalDegrees);
    }
        
    {
        // subscribe to motion updates
        self.motionManager = (CMMotionManager*)[CMMMSingleton singleton];
        self.motionManager.deviceMotionUpdateInterval = 1.0 / SENSORS_UPDATE_HERTZ;
        self.motionManager.accelerometerUpdateInterval = 1.0 / SENSORS_UPDATE_HERTZ;
    }
    
    [self startAR];
}


- (void)viewDidUnload {
    [self stopAR];
    self.motionManager=nil; // singleton
    [self.overlayView release], overlayView=nil;
    [super viewDidUnload];
}


#pragma mark - object lifecycle


/**
 * Initialize this UIImagePickerView.
 *
 * This is called from [ARPickerController search] before presenting this controller.
 */
-(id) init {
    self = [super init];
    
    if (self!=nil){

        // Configure this UIImagePickerController to show camera full screen.
        // To cover the camera controls at the bottom I had to distort the image proportions.
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.showsCameraControls = NO;
        self.navigationBarHidden = YES;
        self.wantsFullScreenLayout = NO;
        self.cameraViewTransform = CGAffineTransformScale(self.cameraViewTransform, 1.0f, 1.26f);

        // Note: you can force this controller to appear over other gui elements if you manually
        // call viewWillAppear and viewDidAppear. This trickery produced a white strip at the top, 
        // I didn't investigate this any further.
        
        // Read the device information (field of view, screen size, ...)
        self.device = [[Device alloc] init];
        
        // State of the AR animation (location, heading, zAngle, ...)
        self.state = [[ARState alloc] init];
        
        // set default mode of operation
        self.showFPS = TRUE;
        self.accelMode = TRUE;
        self.accelerationLowPassFilter = [[XYZLowPassFilter alloc] initWithSampleRate:60. cutoffFrequency:5.];
    }
    
    return self;
}


- (void)dealloc {
    // dealloc stuff from init
    [self.device release], device=nil;
    [self.state release], state=nil;
    [self.accelerationLowPassFilter release], accelerationLowPassFilter=nil;
    [super dealloc];
}


@end