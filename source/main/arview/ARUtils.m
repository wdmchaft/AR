
#import "ARUtils.h"


@implementation ARUtils


+(float)angleFromCoordinate:(CLLocationCoordinate2D)first 
               toCoordinate:(CLLocationCoordinate2D)second {
    
	float deltaLongitude = second.longitude - first.longitude;
	float deltaLatitude = second.latitude - first.latitude;
	float angle = (M_PI * .5f) - atan(deltaLatitude / deltaLongitude);
    
	if (deltaLongitude > 0)      return angle;
	else if (deltaLongitude < 0) return angle + M_PI;
	else if (deltaLatitude < 0)  return M_PI;
    
	return 0.0f;
}


+(float) greatCircleFrom:(CLLocation*)first 
                      to:(CLLocation*)second {
    
    int radius = 6371; // 6371km is the radius of the earth
    float dLat = second.coordinate.latitude-first.coordinate.latitude;
    float dLon = second.coordinate.longitude-first.coordinate.longitude;
    float a = pow(sin(dLat/2),2) + cos(first.coordinate.latitude)*cos(second.coordinate.latitude) * pow(sin(dLon/2),2);
    float c = 2 * atan2(sqrt(a),sqrt(1-a));
    float d = radius * c;
    
    return d;
}

@end


