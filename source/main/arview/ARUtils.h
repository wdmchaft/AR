
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#include <sys/types.h>
#include <sys/sysctl.h>

@interface ARUtils : NSObject

/** 
 * @return the great circle distance between two points.
 * See http://en.wikipedia.org/wiki/Haversine_formula
 * See http://www.movable-type.co.uk/scripts/latlong.html
 */
+(float) greatCircleFrom:(CLLocation*)first to:(CLLocation*)second;


+(float)angleFromCoordinate:(CLLocationCoordinate2D)first toCoordinate:(CLLocationCoordinate2D)second;


@end
