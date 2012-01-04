
#import <CoreLocation/CoreLocation.h>
#import "HttpDownload.h"
#import "ASIHTTPRequest.h"
#import "JsonParser.h"


// See http://code.google.com/apis/maps/documentation/geocoding/
@interface Geocoding : NSObject 

@property (nonatomic, retain) NSDate *lastPetition;

/** Return a location for the address using the Google API. */
-(CLLocation*) geocodeAddress:(NSString*) address;

+(Geocoding *)singleton;

@end
