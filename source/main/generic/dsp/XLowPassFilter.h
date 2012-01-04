
#import "LowPassFilter.h"
#import <CoreLocation/CoreLocation.h>

// Taken from AccelerometerGraph from Apple
@interface XLowPassFilter : LowPassFilter

// acceleration x,y,z
@property (nonatomic, assign) double x;

-(void)addNewValue:(double) newValue;

@end
