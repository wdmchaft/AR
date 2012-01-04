
#import "XYZLowPassFilter.h"


@implementation XYZLowPassFilter

@synthesize x, y, z;


double Norm(double xx, double yy, double zz) {
	return sqrt(xx * xx + yy * yy + zz * zz);
}


-(void)addAcceleration:(CMAcceleration)accel {
    
    // no filter
    if (self.filterMode==kNoFilter){
        self.x = accel.x;
        self.y = accel.y;
        self.z = accel.z;
        return;
    }
    
	double alpha = super.filterConstant;
    
	if (self.filterMode==kAdaptiveFilter) {
        const int const kAccelerometerMinStep = 0.02;
        const int const kAccelerometerNoiseAttenuation = 3.0;
        
        double change = fabs( Norm(x, y, z) - Norm(accel.x, accel.y, accel.z) );
        double exaggeratedChange = change / kAccelerometerMinStep;
        
        // map to 0.0 ... 1.0, with values <1.0 becoming zero
		double d = Clamp( exaggeratedChange - 1.0, 
                         0.0,  // min
                         1.0); // max
        
        // lower "d" means less weight for new values
		alpha = (1.0 - d) * self.filterConstant / kAccelerometerNoiseAttenuation + d * self.filterConstant;
	}
    
	self.x = accel.x * alpha + self.x * (1.0 - alpha);
	self.y = accel.y * alpha + self.y * (1.0 - alpha);
	self.z = accel.z * alpha + self.z * (1.0 - alpha);
}


@end
