
#import "OldARViewController.h"

@implementation OldARViewController

@synthesize _picker=picker, _locationManager=locationManager;
@synthesize _sensorsLabel=sensorsLabel, _overlayGraphicView=overlayGraphicView;
@synthesize currentLocation;

static BOOL showDebug = TRUE;


-(void) updateUI {

    /* "Field vision" is the angular extent of the observable space. Humans have 160-200 wide and 135 high, 
     * while most cameras
     * have a much narrow angle. If you want a photo of the same area that your naked eyes can see, you
     * need to use a "full frame fisheye lens" and then remap the photo to rectilinear perspective.
     * Here is an example: http://en.wikipedia.org/wiki/File:Panotools5618.jpg
     *
     * Anyway.. you need to know the field vision of the camera to show the object only for a certain 
     * angular distance. My iPhone 3G camera has 53º vertically and 37.5º horizontally. 
     * This implies that when I point exactly to the object, the object will remain visible as long as 
     * I don't point beyond (37.5º/2) degrees to the left or right of the object.
     *
     * While the object is visible, we need to move it through the screen to give the impression it is 
     * floating on a fixed point of space.
     * To achieve this I'll need the "pixels per degree" and "degrees per pixel". 
     * On a retina display, the number of pixels should be exactly twice (640x960 instead 320x480).
     */
    static float horizontalPixelsPerDegree = 320 / 37.5;
    static float horizontalDegreesPerPixel = 37.5 / 320;
    static float verticalPixelsPerDegree = 320 / 53;
    static float verticalDegreesPerPixel = 53 / 320;
    
    
    // This is the top label. Note that I'm converting the x and z angles to degrees.
    [sensorsLabel setText: [NSString stringWithFormat:@"  xAxis:%5.1f   zAxis:%5.1f   Heading: %5.1f", 
                          xAxisAngle*180.0f/M_PI, zAxisAngle*180.0f/M_PI, magCompassHeadingInDeg]];
    
    
    /* Go to the "UIAcceleration class reference" and check the picture. I'll call zAxisAngle the 
     * rotation angle the iPhone would have when physically pierced by the z axis. 
     * If we tilt the iPhone left or right we need to rotate the objects in the opposite direction 
     * to create the illusion that they don't move. Next line does exactly that.
     */
    overlayGraphicView.transform = CGAffineTransformMakeRotation(zAxisAngle - M_PI/2);
    
    
    // I am in Madrid.
    // If you have a GPS, replace this with self.currentLocation. This is just for faster testing.
    CLLocationCoordinate2D first;
    first.latitude = 40.416691;
    first.longitude = -3.700345;
    
    // I'm heading to Alcobendas. For a random location use http://itouchmap.com/latlong.html 
    // Use Google's geocoding API if you need to get the location from a street address.
    CLLocationCoordinate2D second;
    second.latitude = 40.547544;
    second.longitude = -3.642091;
    
    // This is the angle from my current location to the point I'm heading.
    float angle = [ARUtils angleFromCoordinate:first toCoordinate:second];
    
    // How many degrees to go beyond the border of the screen until half the image disappears.
    // We need to do this because when the center reaches the border, half the image is still visible.
    float horizontalHalfImage = overlayGraphicView.image.size.width/2 * horizontalDegreesPerPixel;
    float verticalHalfImage = overlayGraphicView.image.size.height/2 * verticalDegreesPerPixel;

    // I'm converting this to degrees and setting east as 0º for no particular reason
    // How you set your reference point doesn't matter as long as you are consistent.
    float angleFixedDeg = (M_PI+angle)*180.0/M_PI;
    // the object is visible while in the camera field vision plus some degrees until the image is gone
    BOOL visibleHorizontal = (angleFixedDeg > magCompassHeadingInDeg- 37.5/2 - horizontalHalfImage) 
                             && (angleFixedDeg < magCompassHeadingInDeg + 37.5/2 + horizontalHalfImage);
    
    // Same thing vertically. Unless you are pointing to the sky, you can disregard altitudes.
    float xAxisAngleDeg = xAxisAngle*180.0/M_PI;
    BOOL visibleVertical = (xAxisAngleDeg > 90 - 53/2 - verticalHalfImage) 
                           && (xAxisAngleDeg < 90 + 53/2 + verticalHalfImage);    
    
    BOOL visible = visibleHorizontal && visibleVertical;
    overlayGraphicView.hidden = !visible;

    if (visibleHorizontal){
        
        // calculate new position
        CGPoint overlayCenter = [overlayGraphicView center];
        
        // x is horizontal center minus pixels_per_degree * (compass_heading - angle_to_target)
        float posX = 160.0 - horizontalPixelsPerDegree * (magCompassHeadingInDeg-angleFixedDeg);
        overlayCenter.x = posX;
        
        // Same thing for y, but using the x axis rotation angle minus 90º 
        // That -90º is so the object is not modified when the phone is in vertical position.
        float posY = 240.0 - verticalPixelsPerDegree * (xAxisAngleDeg-90);
        overlayCenter.y = posY;

        [overlayGraphicView setCenter:overlayCenter];  
        
    } 

    if (showDebug) {
        debug(@"The object will be hidden until you point xAxis to 90º and heading to %f degrees around %f.", 37.5/2, angleFixedDeg );
        if (![CLLocationManager headingAvailable]){ debug(@"I provided -- and ++ buttons for that because you don't have a compass."); }
        showDebug=FALSE;
    }
}




// TODO: when the user rotates the device points to a side but the user is still lookin on
// the same direction, so the angle needs adjustment.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}


#pragma mark setup camera screen


-(UIView*) overlayView {
    
    // Overlay view. This is the only view that goes over the camera image. 
    // Any other graphic or view needs to be a subview of this.
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.x = viewFrame.origin.y = 0.0;
    UIView *overlayView = [[UIView alloc] initWithFrame:viewFrame];
    
    // Create an image and add it as subview of the overlay
    UIImage *overlayGraphic = [UIImage imageNamed:@"laughingman.png"];
    overlayGraphicView = [[UIImageView alloc] initWithImage:overlayGraphic];
    // we want to the origin to be in the center of the graphic, not in the top left corner
    overlayGraphicView.frame = CGRectMake(320/2 - overlayGraphic.size.width/2, 
                                          450/2 - overlayGraphic.size.height/2, 
                                          overlayGraphic.size.width, 
                                          overlayGraphic.size.height);
    [overlayView addSubview:overlayGraphicView];
    
    // Create a label and add it as subview of the overlay
    sensorsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0., 0., 320., 30.)];
    [sensorsLabel setText:@"waiting for updates"];
    [sensorsLabel setBackgroundColor:[UIColor purpleColor]];
    [sensorsLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [sensorsLabel setTextColor:[UIColor whiteColor]];
    [overlayView addSubview:sensorsLabel];
    
    return overlayView;
}


// decrease/increase heading manually on my old iPhone 3G
-(void) decreaseHeading {
    magCompassHeadingInDeg = fmod(magCompassHeadingInDeg+1.,360);
    [self updateUI];
}
-(void) increaseHeading {
    magCompassHeadingInDeg = fmod(magCompassHeadingInDeg-1.,360);
    [self updateUI];
}


-(UIImagePickerController*) cameraViewController {
    
    /* UIImagePickerController is an UIViewController that shows the camera full screen.
     * You can force the controller to appear while other UI elements are present if you 
     * manually call viewWillAppear and viewDidAppear, but that hides the top bar and 
     * it's non standard behavior. 
     */
    
    picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.showsCameraControls = NO;
    picker.navigationBarHidden = YES;
    picker.wantsFullScreenLayout = NO;
    
    // Screen ratio and camera image ratio are different. When camera controls are not present
    // there is a black bar at the bottom. Next line distorts the camera image to cover that bar.
    picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, 1.0f, 1.24f);
    
    return picker;
}


- (void) go {

    // if the device has no AR capabilities (camera, accelerometers, A-GPS, and compass)
    // use a UIViewController instead of a UIImagePickerController so the application runs 
    // on my iPad 1 and iPhone 3G.
    
    // Note that if you use it in the simulator, the accelerometers will be 0. You can simulate
    // updates from the A-GPS reading a KML file, but I guess you'll need buttons to change the
    // accelerometer values. I already added a couple of buttons to change the heading.

    UIViewController *cameraController = nil;
    if ([Hardware isAvailableAR]){
        cameraController = [self cameraViewController];
        ((UIImagePickerController*) cameraController).cameraOverlayView = [self overlayView];
    } else {
        warn(@"I assume there is no camera so I'll replace the camera view with a normal UIViewController.");
        cameraController = [[UIViewController alloc] init];
        cameraController.view.backgroundColor = [UIColor yellowColor];
        [cameraController.view addSubview:[self overlayView]];
    }
    
    // if there is no compass, add a couple of buttons to change it manually
    if (![CLLocationManager headingAvailable]){
        
        // increase heading button
        UIButton *headingBtnIncrease = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [headingBtnIncrease setFrame:CGRectMake(20, 410, 130, 40)];
        [headingBtnIncrease setTitle:@"+++++++" forState:UIControlStateNormal];
        [headingBtnIncrease addTarget:self action:@selector(increaseHeading) forControlEvents:UIControlEventTouchUpInside];
        [headingBtnIncrease setBackgroundColor:[UIColor clearColor]];
        
        // decrease heading button
        UIButton *headingBtnDecrease = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [headingBtnDecrease setFrame:CGRectMake(170, 410, 130, 40)];
        [headingBtnDecrease setTitle:@"-------" forState:UIControlStateNormal];
        [headingBtnDecrease addTarget:self action:@selector(decreaseHeading) forControlEvents:UIControlEventTouchUpInside];
        [headingBtnDecrease setBackgroundColor:[UIColor clearColor]];
        
        [cameraController.view addSubview:headingBtnIncrease];
        [cameraController.view addSubview:headingBtnDecrease]; 
    }

    [self startSensorUpdates];
    [self presentModalViewController:cameraController animated:NO];
    
}


#pragma mark toggle location updates


/**
 * Start listening for heading, location, and acceleration updates.
 */
-(void) startSensorUpdates {
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    [locationManager startUpdatingHeading];
    [locationManager startUpdatingLocation];
    [locationManager setDelegate:self];
    debug(@"Listening for location and heading updates.");
}


/**
 * Stop listening for heading, location, and acceleration updates, set delegates to nil.
 */
-(void) stopSensorUpdates {
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
    [locationManager stopUpdatingHeading];
    [locationManager stopUpdatingLocation];
    [locationManager setDelegate:nil];
}


#pragma mark delegate: UIAccelerometerDelegate

/**
 * See graphic: 
 * http://developer.apple.com/library/ios/#documentation/uikit/reference/UIAcceleration_Class/Reference/UIAcceleration.html
 * 
 * This updates zAxisAngle and xAxisAngle.
 *
 * z axis: 180-90-0 (left 180, vertical 90, right 0)
 * 
 * x axis: 180-90-0 (face up 180, vertical 90, face down 0)
 * 
 */
- (void)accelerometer:(UIAccelerometer *)accelerometer 
        didAccelerate:(UIAcceleration *)acceleration {
    xAxisAngle = -atan2(acceleration.y, acceleration.z);
    zAxisAngle = -atan2(acceleration.y, acceleration.x);

    [self updateUI];
}


#pragma mark delegate: CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *) manager 
       didUpdateHeading:(CLHeading *) newHeading {
    magCompassHeadingInDeg = newHeading.trueHeading;
    [self updateUI];
}


- (void)locationManager:(CLLocationManager *) manager
    didUpdateToLocation:(CLLocation *) newLocation
           fromLocation:(CLLocation *) oldLocation {
    self.currentLocation=newLocation;
    [self updateUI];
}    


#pragma mark - View lifecycle


- (void)dealloc {
    [picker release];
    [currentLocation release]; currentLocation = nil;
    [locationManager release]; locationManager = nil;
    [overlayGraphicView release]; overlayGraphicView = nil;
    [super dealloc];
}


- (void)viewDidLoad {
    [button addTarget:self action:@selector(go) forControlEvents:UIControlEventTouchUpInside];
    
    magCompassHeadingInDeg = 203.997986; // initial angle from origin to target for my two hardcoded points
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [super viewDidLoad];
}


- (void)viewDidUnload {
    [locationManager release];
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
    [self stopSensorUpdates];
    [super viewWillAppear:animated];
}





@end

