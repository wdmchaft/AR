
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ARUtils.h"
#import "Hardware.h"


@interface OldARViewController : UIViewController <UIAccelerometerDelegate, CLLocationManagerDelegate> {

    // 'go' button that launches the pickerView
    UIButton *_button;
    
    // camera picker 
    UIImagePickerController *_picker;
    
    // location manager to listen for updates
    CLLocationManager *_locationManager;
    
    // graphic and label
    UIImageView *_overlayGraphicView;
    
    // stores the current gps position
    CLLocation *currentLocation;
    
    UILabel *_sensorsLabel;
    
    CLLocationDirection magCompassHeadingInDeg;
    double zAxisAngle;
    double xAxisAngle;
}

@property (nonatomic, retain) UILabel *_sensorsLabel;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) UIImageView *_overlayGraphicView;
@property (nonatomic, retain) IBOutlet UIButton *_button;
@property (nonatomic, retain) UIImagePickerController *_picker;
@property (nonatomic, retain) CLLocationManager *_locationManager;


-(void) go;

-(UIView*) overlayView;

// simulate heading in my old iPhone 3G
-(void) decreaseHeading;
-(void) increaseHeading;

// toggle GPS, heading, and accelerometer updates
-(void) startSensorUpdates;
-(void) stopSensorUpdates;

-(void) updateUI;

@end
