
#import "LowPassFilter.h"
#import <CoreMotion/CoreMotion.h>


// Taken from AccelerometerGraph from Apple
@interface XYZLowPassFilter : LowPassFilter

// acceleration x,y,z
@property (nonatomic, assign) double x, y, z;

-(void)addAcceleration:(CMAcceleration)accel;

@end


@interface XYZLowPassFilter (private)

double Norm(double x, double y, double z);

@end