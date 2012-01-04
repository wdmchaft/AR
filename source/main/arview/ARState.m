
#import "ARState.h"

@implementation ARState

@synthesize locationTarget, locationCurrent, heading;
@synthesize headingToTargetInDeg, zAxisAngle, xAxisAngle;
@synthesize headingPlusGyrosInDeg;


-(void)setHeading:(CLHeading*)newHeading {
    // set new value
    [heading autorelease];
    heading = [newHeading retain];
}


-(void)setLocationCurrent:(CLLocation *)newLocationCurrent {
    [locationCurrent autorelease];
    locationCurrent = [newLocationCurrent retain];
    // update angle to target
    headingToTargetInDeg = [self headingFromCoordinate:locationCurrent.coordinate
                                          toCoordinate:locationTarget.coordinate];
}


-(id) init {
    self = [super init];
    if (self!=nil){
        self.locationTarget=nil;
        self.locationCurrent=nil;
        self.heading=nil;
    }
    return self;
}


- (void)dealloc {
    [self.heading release], heading=nil;
    [self.locationCurrent release], locationCurrent=nil;
    [self.locationTarget release],  locationTarget=nil;
    [super dealloc];
}

@end


@implementation ARState (private) 

- (float) headingFromCoordinate:(CLLocationCoordinate2D)fromLoc 
                   toCoordinate:(CLLocationCoordinate2D)toLoc {
    float fLat = DEGREES_TO_RADIANS(fromLoc.latitude);
    float fLng = DEGREES_TO_RADIANS(fromLoc.longitude);
    float tLat = DEGREES_TO_RADIANS(toLoc.latitude);
    float tLng = DEGREES_TO_RADIANS(toLoc.longitude);
    float angle = atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng));
    angle = RADIANS_TO_DEGREES(angle);
    return angle;
}


- (float) cartesianHeadingFromCoordinate:(CLLocationCoordinate2D)fromLoc 
                            toCoordinate:(CLLocationCoordinate2D)toLoc {
    float dx = toLoc.longitude - fromLoc.longitude;
    float dy = toLoc.latitude - fromLoc.latitude;
    float angle = RADIANS_TO_DEGREES(-atan2(dy,dx)) + 90; // add 90 to set N as 0
    return angle;
}
@end