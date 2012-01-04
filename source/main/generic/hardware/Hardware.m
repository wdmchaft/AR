
#import "Hardware.h"

@implementation Hardware


+(BOOL) isAvailableAccelerometer {
    return [[[CMMotionManager alloc] init] isAccelerometerAvailable];
}


+(BOOL) isAvailableAR {
    BOOL camera = [Hardware isAvailableCamera];
    BOOL gyroscope = [Hardware isAvailableGyro];
    BOOL heading = [Hardware isAvailableHeading];
    BOOL location = [Hardware isEnabledLocationServices];
    BOOL arEnabled = camera && gyroscope && heading && location;
    
    trace(@"AR %@available:", arEnabled ? @"" : @"not ");
    trace(@"  [%@] camera", camera?@"x":@" ");
    trace(@"  [%@] gyroscope", gyroscope?@"x":@" ");
    trace(@"  [%@] heading", heading?@"x":@" ");
    trace(@"  [%@] location", location?@"x":@" ");
    
    return arEnabled;
}


+(BOOL) isAvailableCamera {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count]>0;
}


+(BOOL) isAvailableGyro {
    return [[CMMMSingleton singleton] isGyroAvailable];   
}


+(BOOL) isAvailableHeading {
    return [CLLocationManager headingAvailable];
}


+(BOOL) isEnabledLocationServices {
    return [CLLocationManager locationServicesEnabled];
}


+(BOOL) isRetinaDisplay {
    BOOL isRetina = NO;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        CGFloat scale = [[UIScreen mainScreen] scale];
        if (scale > 1.0) {
            isRetina = YES;
        }
    }
    return isRetina;
}


+(CGSize) pixelSizeOfScreen {
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGSize size = [mainScreen applicationFrame].size;
    if ([mainScreen respondsToSelector:@selector(scale)]) {
        CGFloat scale = [mainScreen scale];
        size = CGSizeMake(size.width * scale, size.height * scale);
    }
    return size;
}


+(CGSize) pointSizeOfScreen {
    return [[UIScreen mainScreen] applicationFrame].size;
}


+(double) diagonalFromCenter {
    CGSize size = [Hardware pointSizeOfScreen];
    return sqrt( pow((size.width/2),2) + pow((size.height/2),2));
}


/**
 * Returns the field of view of the current device.
 * If there is no camera, the result is 0,0.
 *
 * "Field of view" is the angular extent of the observable space. Humans have 160-200 wide and 135 high, 
 * while most cameras have a much narrow angle. If you want a photo of the same area that your naked eyes 
 * can see, you need to use a "full frame fisheye lens" and then remap the photo to rectilinear perspective.
 * Here is an example: http://en.wikipedia.org/wiki/File:Panotools5618.jpg
 */
+(FieldOfView) fieldOfView {
    
    FieldOfView fieldOfView = {0.,0.};
    if (![Hardware isAvailableCamera]) {
        return fieldOfView;   
    }
    
    if ([self isIPad]){
        // roughly 34.1º, 44.5º http://hunter.pairsite.com/blogs/20110317/
        // Front Camera - VGA (640 x 480 pixels or .69MP)
        // Back Camera - 720p (960 x 720 pixels or 1.3MP)
        // Sigh, no focal length or sensor size information anywhere.
        fieldOfView.horizontal = 34.1;
        fieldOfView.vertical = 44.5;
        
    } else if ([self isIPhone]){
        if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
            /* IPHONE 4
             * Focal length: 3.85mm. Sensor: 3.39mm * 4.52mm. 
             * Horizontal: 3.39/2 = 1.695mm, atan(1.695/3.85) = 23.75º center to top, which is or 47.5º top to bottom.
             * Vertical: 4.52/2 = 2.26mm, atan(2.26/3.85) = 30.41mm center to side, which is 60.8º left to right.
             * Therefore the field vision is 47.5º, 60.8º. */
            fieldOfView.horizontal = 47.5;
            fieldOfView.vertical = 60.8;
            
        } else {
            // iPhone 3
            fieldOfView.horizontal = 37.5;
            fieldOfView.vertical = 53;
        }
    }
    
    return fieldOfView;
}


/*
+(CGSize)screenSizePortrait {
    CGSize size = { 0, 0 };
    NSString *machine = [Hardware getSysInfoByName:"hw.machine"];
    if ([self isIPod]){
        // iPod
        size = CGSizeMake(320.0, 460.0);
    } else if ([self isIpad]){
        if ([Hardware isRetinaDisplay]) {
            // iPhone 4/5
            size = CGSizeMake(640.0, 960.0);
        } else {
            // iPhone 1/2/3
            size = CGSizeMake(320.0, 480.0);
        }
    } else if ([self isIpad]){
        // iPad 1/2
        size = CGSizeMake(768.0, 1024.0);
    }
    
    return size;
}
*/

@end


@implementation Hardware (private)

+ (NSString *) getSysInfoByName:(char *)typeSpecifier {
	size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    char *answer = malloc(size);
	sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
	NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
	free(answer);
	return results;
}

+ (BOOL) isIPod {
    return [[Hardware getSysInfoByName:"hw.machine"] hasPrefix:@"iPod"];
}
+ (BOOL) isIPad {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}
+ (BOOL) isIPhone {
    return [[Hardware getSysInfoByName:"hw.machine"] hasPrefix:@"iPhone"];
}

// Return the exact model.
// http://stackoverflow.com/questions/448162/determine-device-iphone-ipod-touch-with-iphone-sdk
- (NSString *) marketingName {
    NSString *platform = [Hardware getSysInfoByName:"hw.machine"];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    return platform;
}



@end


/*
 DEVICE MODELS AND CAPABILITIES
 
        iPhone 1G:  A-GPS,  accelerometer,  camera,     --        --     
        iPhone 3G:  A-GPS,  accelerometer,  camera,     --        --     
 iPhone Simulator:  A-GPS,  accelerometer,    --        --        --     
       iPhone 3GS:  A-GPS,  accelerometer,  camera,  compass,     --      
         iPhone 4:  A-GPS,  accelerometer,  camera,  compass,  gyroscope  
             iPad:  A-GPS,  accelerometer,    --     compass,     --     
           iPad 2:  A-GPS,  accelerometer,  camera,  compass,  gyroscope  
    iPod Touch 1G:   --     accelerometer,    --        --        --     
    iPod Touch 2G:   --     accelerometer,    --        --        --     
    iPod Touch 3G:   --     accelerometer,    --        --        --     
    iPod Touch 4G:   --     accelerometer,  camera,     --     gyroscope
*/

