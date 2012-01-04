
#import <CoreLocation/CoreLocation.h>
#import "Macros.h"

@interface ARState : NSObject

@property (nonatomic, retain) CLLocation *locationCurrent;  // current location
@property (nonatomic, retain) CLLocation *locationTarget;   // target location
@property (nonatomic, retain) CLHeading *heading;           // target location

// Heading periodically updated with the yaw from the gyroscope.
// This will be reset to a value form the compass
@property (nonatomic, assign) CLLocationDirection headingPlusGyrosInDeg; 

@property (nonatomic, assign) CLLocationDirection headingToTargetInDeg;
@property (nonatomic, assign) double zAxisAngle;  // z angle from the accelerometer
@property (nonatomic, assign) double xAxisAngle;  // x angle from the accelerometer

@end


@interface ARState (private) 

/** 
 * Returns the angle in degrees between two points using the haversine formula. 
 * Reference is: N=0,E=90,S=180.
 */
- (float) headingFromCoordinate:(CLLocationCoordinate2D)fromLoc 
                   toCoordinate:(CLLocationCoordinate2D)toLoc;
/** 
 * Returns the angle in degrees between two points as if the two positions were on cartesians coordinates. 
 * Reference is: N=0,E=90,S=180.
 */
- (float) cartesianHeadingFromCoordinate:(CLLocationCoordinate2D)fromLoc 
                            toCoordinate:(CLLocationCoordinate2D)toLoc;
@end