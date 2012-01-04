
#import "Geocoding.h"


@implementation Geocoding

@synthesize lastPetition;


+(Geocoding *)singleton {
    static dispatch_once_t pred;
    static Geocoding *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[Geocoding alloc] init];
        shared.lastPetition = [NSDate date];
    });
    return shared;
}


-(CLLocation*) geocodeAddress:(NSString*) address {
	
    debug(@"Geocoding address: %@", address);
    
	// don't make requests faster than 0.5 seconds
	// Google may block/ban your requests if you abuse the service
    double pause = 0.5;
    NSDate *now = [NSDate date];
	NSTimeInterval elapsed = [now timeIntervalSinceDate:self.lastPetition];
	self.lastPetition = now;
	if (elapsed>0.0 && elapsed<pause){
		debug(@"    Elapsed < pause = %f < %f, sleeping for %f seconds", elapsed, pause, pause-elapsed);
		[NSThread sleepForTimeInterval:pause-elapsed];
	}
	
	// url encode
	NSString *encodedAddress = (NSString *) CFURLCreateStringByAddingPercentEscapes(
								NULL, (CFStringRef) address,
								NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]",
								kCFStringEncodingUTF8 );
	
	NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", encodedAddress];
	//debug(@"    url is %@", url);
	[encodedAddress release];
    
    // try twice to geocode the address
	NSDictionary *dic;
	for (int i=0; i<2; i++) { // two tries
	
		HttpDownload *http = [HttpDownload new];
		NSString *page = [http pageAsStringFromUrl:url];
        [http release];
		dic = [JsonParser parseJson:page];
		NSString *status = (NSString*)[dic objectForKey:@"status"];
		BOOL success = [status isEqualToString:@"OK"];
		if (success) break;
		
		// Query failed
		// See http://code.google.com/apis/maps/documentation/geocoding/#StatusCodes
		if ([status isEqualToString:@"OVER_QUERY_LIMIT"]){
			debug(@"try #%d", i);
			[NSThread sleepForTimeInterval:1];
		} else if ([status isEqualToString:@"ZERO_RESULTS"]){
			warn(@"    Address unknown: %@", address);
			break;
		} else {
			// REQUEST_DENIED: no sensor parameter. Shouldn't happen.
			// INVALID_REQUEST: no address parameter or empty address. Doesn't matter.
		}

	}
	
	// if we fail after two tries, just leave
    NSString *status = (NSString*)[dic objectForKey:@"status"];
	BOOL success = [status isEqualToString:@"OK"];
	if (!success) return nil;
	
	// extract the data
    {
        int results = [[dic objectForKey:@"results"] count];
        if (results>1){
            warn(@"    There are %d possible results for this adress.", results);
        }
    }
    
	NSDictionary *locationDic = [[[[dic objectForKey:@"results"] objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"];
	NSNumber *latitude = [locationDic objectForKey:@"lat"];
	NSNumber *longitude = [locationDic objectForKey:@"lng"]; 	
	debug(@"    Google returned coordinate = { %f, %f }", [latitude floatValue], [longitude floatValue]);
	
	// return as location
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
	
    return [location autorelease];
}


@end


/* GEOCODING WITH GOOGLE ///////////////////////////////////////////////////////////////////////////
	
	Address: Calle de Carranza 2, Madrid, Madrid, España
	 
	URL: http://maps.googleapis.com/maps/api/geocode/json?address=
         Calle%20de%20Carranza%202%%2C%20Madrid%2C%20Espa%C3%B1a&sensor=true
	
	JSON returned should be:
	{
		status: "OK";
	    results: [
	        {
	            types: [ ... ];
    	        formatted_address: "Betanzos, Spain",
	            address_components: [ ... ],
	            geometry: {
	                location: {
	                    lat: 43.2810597,
	                    lng: -8.2113155
    	            },
	                location_type: "APPROXIMATE",
	                viewport: { ... },
	                bounds: { ... }
    	        },
	    	    partial_match: true
			}
        ] 
	}
	 
*/

