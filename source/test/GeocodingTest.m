
#import <UIKit/UIKit.h>
#import <GHUnitIOS/GHUnit.h>
#import <CoreLocation/CoreLocation.h>
#import "Geocoding.h"


@interface GeocodingTest : GHTestCase 
@end


@implementation GeocodingTest


- (void) testAddress {
    Geocoding *geocoding = [Geocoding singleton];
    
	NSString *address = @"Calle de Carranza 2, Madrid, España";
	CLLocation *location = [geocoding geocodeAddress:address];
	GHAssertTrue(location!=nil, nil);
    
    address = @"Third rock from the sun";
    location = [geocoding geocodeAddress:address];
    GHAssertTrue(location==nil, nil);
    
}

 
@end
