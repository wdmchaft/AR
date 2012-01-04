
#import "LowPassFilter.h"


@implementation LowPassFilter

@synthesize filterConstant;
@synthesize filterMode;


-(id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq {
	self = [super init];
	if(self != nil) {
		double dt = 1.0 / rate;
		double RC = 1.0 / freq;
		self.filterConstant = dt / (dt + RC);
        debug(@"%@ %f", [self class], self.filterConstant);
	}
	return self;
}


double Clamp(double v, double min, double max) {
	if(v > max) return max;
	else if(v < min) return min;
	else return v;
}


@end
