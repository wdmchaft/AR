
#import "ARPickerController.h"

/* Usage:
 *     ARPickerController *picker = [ARPickerController alloc] init];
 *     picker.targetLocation = ...; // CLLocation
 * 
 * - init: initialize the picker as video feed
 * - viewDidLoad: adds the location manager and the overlay, starts sensor updates
 * - viewDidUnload: stop sensor updates
 */


@implementation ARPickerController

// changes with each update
@synthesize offsetToTargetInDeg, locationCurrent, magCompassHeadingInDeg, zAxisAngle, xAxisAngle, uiSensorsLabel, uiFpsLabel;
// set in startSensors
@synthesize locationManager;
// set before calling this class
@synthesize locationTarget;
// set once at viewDidLoad
@synthesize uiTargetIcon, uiOverlayView=_overlayView;
@synthesize fieldOfView, horizontalPointsPerDegree, horizontalDegreesPerPoint, verticalPointsPerDegree, verticalDegreesPerPoint;

@synthesize accelerationLowPassFilter;
@synthesize lowPassFilterMode;

@synthesize framesPerSecond, showFPS;

@synthesize motionManager;


/** 
 * Dismiss this modal view controller.
 * Called from the info button in the camera screen. 
 */
- (void)backToConfigScreen:(id)sender {
    [self stopSensorUpdates];
    [self dismissModalViewControllerAnimated:YES];
}


/** 
 * Returns TRUE 'UI_UPDATE_HERTZ' times per second. 
 * This is called from updateUI to decide if the update should be allowed.
 */
-(BOOL) allowUpdate:(NSTimeInterval)timeIntervalSinceReferenceDate {
    
    // limit updates to 'hertz' updates per second
    const float hertz = UI_UPDATE_HERTZ;
    
    // that is, allow only one update per 'period' seconds
    const double period = 1/hertz;
    
    // time of the last update
    static double lastUpdate = -1; 
    
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    BOOL tooFast = now - lastUpdate < period;
    if (tooFast){
        // discard update
        return NO;
    } else {
        // allow update
        lastUpdate = now;
        return YES;   
    }
}



/**
 * Called from didAccelerate, didUpdateHeading, didUpdateToLocation.
 */
-(void) updateUI {
    
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    // restrict the number of updates per second
    if (![self allowUpdate:now]) {
        return;
    } 
    
    if (self.showFPS) {
        // count fps
        static short fps = 0;
        static double thisSecond = -1;
        if (now-thisSecond > 1){
            thisSecond = floor(now);
            self.framesPerSecond=fps;
            fps=1;
        } else {
            fps++;
        }
        self.uiFpsLabel.text = [NSString stringWithFormat:@"%d",self.framesPerSecond];
    }
    
    
    // update angles
    double dx = self.locationTarget.coordinate.longitude - self.locationCurrent.coordinate.longitude;
    double dy = self.locationTarget.coordinate.latitude - self.locationCurrent.coordinate.latitude;
    double angleBetweenPositionsInDeg = RADIANS_TO_DEGREES(atan2(dy,dx));
    // change the angle to positive, eg: -80 is 360+ -80 = +280º
    if (angleBetweenPositionsInDeg<0) angleBetweenPositionsInDeg = 360 + angleBetweenPositionsInDeg;
    
    //trace(@"target is at %fº, offset is %f", angleBetweenPositionsInDeg, offsetToTargetInDeg);
    
    // h = h - z - 90;
    magCompassHeadingInDeg = magCompassHeadingInDeg + (zAxisAngle - 90);
    
    offsetToTargetInDeg = magCompassHeadingInDeg - angleBetweenPositionsInDeg;
    
    /*
     trace(@"target {%f, %f}, current {%f, %f}, atan2(dy,dx) = atan2(%f,%f) = %f",
     self.targetLocation.coordinate.latitude, self.targetLocation.coordinate.longitude, 
     self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude, 
     dy, dx,
     RADIANS_TO_DEGREES(atan2(dy,dx))
     );
     */
    
    // How many degrees to go beyond the border of the screen until half the image disappears.
    // We need to do this because when the center reaches the border, half the image is still visible.
    // TODO: this value is fixed, set it out of this loop
    float halfImageHorizontalDegrees = overlayedImageView.image.size.width/2 * horizontalDegreesPerPoint;
    //float halfImageVerticalDegrees = overlayedImageView.image.size.height/2 * verticalDegreesPerPixel;  
    
    // the object is visible during 'visibleOffsetInDeg' degrees away from the exact heading to the object
    float visibleOffsetInDeg = fabs(fieldOfView.horizontal/2) + fabs(halfImageHorizontalDegrees);
    BOOL visibleHorizontal = fabs(offsetToTargetInDeg) < visibleOffsetInDeg;
    
    //trace(@"%f < %f = %@", fabs(offsetToTargetInDeg), visibleOffsetInDeg, visibleHorizontal?@"YES":@"NO");
    
    overlayedImageView.hidden = !visibleHorizontal;
    
    if (visibleHorizontal){
        
        //trace(@"visible horizontal");
        
        // Counter rotation for the graphic overlay when the device rotates in the z axis.
        // This preserves the vertical orientation of the object.
        overlayedImageView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(zAxisAngle) - M_PI/2);
        
        // set the center
        CGPoint overlayedImageCenter = [overlayedImageView center];
        CGSize sizeOfScreenInPoints = [Hardware pointSizeOfScreen];
        float posX = sizeOfScreenInPoints.width/2 - horizontalPointsPerDegree * offsetToTargetInDeg;
        overlayedImageCenter.x = posX;
        //float posY = sizeOfScreenInPoints.height/2 - verticalPixelsPerDegree * (xAxisAngleDeg-90);
        //overlayCenter.y = posY;
        [overlayedImageView setCenter:overlayedImageCenter];       
    }
    
    // Top label. Note that I'm converting the x and z angles to degrees.
    [sensorsLabel setText: [NSString stringWithFormat:@"x:%5.1f   z:%5.1f   h:%5.1f   t:%5.1f   visible? %5.1f < %5.1f",
                            xAxisAngle, zAxisAngle,     // angles in axis x, z
                            magCompassHeadingInDeg,     // heading
                            angleBetweenPositionsInDeg, // angle to target
                            fabs(offsetToTargetInDeg), visibleOffsetInDeg ]]; // current offset and visible offset
    
}  


#pragma mark delegate: UIAccelerometerDelegate


/**
 * See graphic: 
 * http://developer.apple.com/library/ios/#documentation/uikit/reference/UIAcceleration_Class/Reference/UIAcceleration.html
 * 
 * This updates zAxisAngle and xAxisAngle.
 */
- (void)accelerometer:(UIAccelerometer *)accelerometer 
        didAccelerate:(UIAcceleration *)acceleration {
    
    double x,y,z;
    [self.accelerationLowPassFilter addAcceleration:acceleration];
    x = self.accelerationLowPassFilter.x;
    y = self.accelerationLowPassFilter.y;
    z = self.accelerationLowPassFilter.z;
    
    // The values returned by the accelerometer are Gs.
    
    // x goes from 0 (face up) to 180 (face down) to 360
    double newXAxisAngle = -atan2(y, z);
    newXAxisAngle = 180 - RADIANS_TO_DEGREES(newXAxisAngle);
    if (newXAxisAngle<0) newXAxisAngle = 180. - fabs(newXAxisAngle);
    
    // z goes from 0 (tilt right) to 180 (tilt left) to 360
    double newZAxisAngle = -atan2(y,x);
    newZAxisAngle = RADIANS_TO_DEGREES(newZAxisAngle);
    if (newZAxisAngle<0) newZAxisAngle = 180 + (180-fabs(newZAxisAngle));
    
    // update only for more than 2 degrees
    //if ((fabs(xAxisAngle-newXAxisAngle)>2) || (fabs(zAxisAngle-newZAxisAngle)>2)) {
    xAxisAngle = newXAxisAngle;
    zAxisAngle = newZAxisAngle;
    [self updateUI];
    //}
}


#pragma mark delegate: CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *) manager 
       didUpdateHeading:(CLHeading *) newHeading {
    
    if (newHeading.headingAccuracy<0) {
        warn(@"discarding invalid heading");
        return;
    }
    
    double h = newHeading.trueHeading;
    
    // IMPORTANT! trueHeading is the offset from the north (0º if I point 
    // exactly north) but Im changing this so north is 90º and east 0º
    CLLocationDirection newValue = fmod(h + 90., 360.);
    
    // update only if the value changes more than 2 degrees
    //if (fabs(magCompassHeadingInDeg-newValue)>2){
    magCompassHeadingInDeg = newValue;
    [self updateUI];
    //}
    
}


- (void)locationManager:(CLLocationManager *) manager
    didUpdateToLocation:(CLLocation *) newLocation
           fromLocation:(CLLocation *) oldLocation {
    self.locationCurrent=newLocation;
    [self updateUI];
}    



#pragma mark - Present the AR video feed

/**
 * Overlay view.
 * Any view over the video feed is a child of this view.
 */
-(UIView*) uiOverlayView {
    
    if (_overlayView==nil){
        trace(@"creating the overlayView");
        
        // Overlay view. This is the only view that goes over the camera image. 
        // Any other graphic or view needs to be a subview of this.
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.x = viewFrame.origin.y = 0.0;
        _overlayView = [[UIView alloc] initWithFrame:viewFrame];
        
        // create an image and add it as subview of the overlay
        UIImage *overlayGraphic = [UIImage imageNamed:@"laughingman.png"];
        overlayedImageView = [[UIImageView alloc] initWithImage:overlayGraphic];
        
        // we want to the origin to be in the center of the graphic, not in the top left corner
        CGSize screenPoints = [Hardware pointSizeOfScreen];
        overlayedImageView.frame = CGRectMake(screenPoints.width/2 - overlayGraphic.size.width/2, 
                                              screenPoints.height/2 - overlayGraphic.size.height/2, 
                                              overlayGraphic.size.width, 
                                              overlayGraphic.size.height);
        [_overlayView addSubview:overlayedImageView];
        
        {
            // fps label
            NSString *twoDigits = @"00";
            UIFont *font = [UIFont fontWithName:@"standard 07_53" size:20];
            CGSize size = [twoDigits sizeWithFont:font];
            fpsLabel = [[UILabel alloc] initWithFrame:
                        CGRectMake([Hardware pointSizeOfScreen].width-size.width, 40., size.width, size.height)];
            [fpsLabel setText:@"0"];
            [fpsLabel setBackgroundColor:[UIColor clearColor]];
            [fpsLabel setFont:font];
            [fpsLabel setTextColor:[UIColor whiteColor]];
            [_overlayView addSubview:fpsLabel];
            [fpsLabel release];
        }
        
        {
            // create a label and add it as subview of the overlay
            sensorsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0., 0., screenPoints.width, 30.)];
            [sensorsLabel setText:@"waiting for updates"];
            [sensorsLabel setBackgroundColor:[UIColor purpleColor]];
            [sensorsLabel setFont:[UIFont boldSystemFontOfSize:12]];
            [sensorsLabel setTextColor:[UIColor whiteColor]];
            [_overlayView addSubview:sensorsLabel];
            [sensorsLabel release];
        }
    }
    
    return _overlayView;
}


/**
 * Initialize as camera feed. 
 */
-(id) init {
    self = [super init];
    
    if (self!=nil){
        trace(@"creating the picker controller");
        
        // UIImagePickerController is an UIViewController that shows the camera full screen.
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.showsCameraControls = NO;
        self.navigationBarHidden = YES;
        self.wantsFullScreenLayout = NO;
        
        // You can force the controller to appear while other UI elements are present if you 
        // manually call viewWillAppear and viewDidAppear, but that hides the top bar with a
        // white strip.
        
        // Screen ratio and camera image ratio are different. When camera controls are not present
        // there is a black bar at the bottom. Next line distorts the camera image to cover that bar.
        self.cameraViewTransform = CGAffineTransformScale(self.cameraViewTransform, 1.0f, 1.26f);
        
        // target location starts as nil
        self.locationTarget = nil;
        
        self.magCompassHeadingInDeg = 0.;
        self.offsetToTargetInDeg = 0.;
        self.zAxisAngle = 0.;
        self.xAxisAngle = 0.;
    }
    
    return self;
}


#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [self.locationManager release];
    [self.locationTarget release];
    [self.uiTargetIcon release];
    [self.uiOverlayView release];
    [self.uiSensorsLabel release];
    [self.locationManager release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Sensors

/**
 * Start listening for heading, location, and acceleration updates.
 */
-(void) startSensorUpdates {
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    // 0.1 means 10 updates per second
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:0.1];
    // Apple recommends:
    //   - 10-20/s  detecting orientation
    //   - 30-60/s  tilt for games
    //   - 70-100/s shakes
    // Highest values use more battery.
    
    [locationManager startUpdatingHeading];
    [locationManager startUpdatingLocation];
    [locationManager setDelegate:self];
    debug(@"Listening for location and heading updates.");
    
    [self.motionManager startAccelerometerUpdates];
    motionManager.accelerometerUpdateInterval = 0.1;
    [self.motionManager startDeviceMotionUpdates];
    motionManager.deviceMotionUpdateInterval = 0.1;
}


/**
 * Stop listening for heading, location, and acceleration updates, set delegates to nil.
 */
-(void) stopSensorUpdates {
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
    [locationManager stopUpdatingHeading];
    [locationManager stopUpdatingLocation];
    [locationManager setDelegate:nil];
    
    [motionManager stopAccelerometerUpdates];
    [motionManager stopDeviceMotionUpdates];
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showFPS = TRUE;
    self.framesPerSecond = 0;
    
    // location sensor
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // create and set overlay
    self.uiOverlayView = [self uiOverlayView];     // create and save as local reference
    self.cameraOverlayView = self.uiOverlayView; // set on the controller
    
    // info button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [button setFrame:CGRectMake(282, 421, 18, 19)];
    [button addTarget:self action:@selector(backToConfigScreen:) forControlEvents:UIControlEventTouchUpInside]; 
    [self.uiOverlayView addSubview:button];
    
    // field of view, pixels per degree, degrees per pixel
    self.fieldOfView = [Hardware fieldOfView];
    CGSize size = [Hardware pixelSizeOfScreen];
    self.horizontalPointsPerDegree = size.width / fieldOfView.horizontal;
    self.horizontalDegreesPerPoint = fieldOfView.horizontal / size.width;
    self.verticalPointsPerDegree = size.height / fieldOfView.vertical;
    self.verticalDegreesPerPoint = fieldOfView.vertical / size.height;
    
    // low pass filter
    self.accelerationLowPassFilter = [[XYZLowPassFilter alloc] initWithSampleRate:60. cutoffFrequency:5.];
    self.accelerationLowPassFilter.filterMode = self.lowPassFilterMode;
    trace(@"Setting filter to %d", self.lowPassFilterMode);
    
    motionManager = [[CMMotionManager alloc] init];
    
    [self startSensorUpdates];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    [self stopSensorUpdates];
    [motionManager release], motionManager = nil;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
