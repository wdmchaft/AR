
#import "XLowPassFilter.h"


@implementation XLowPassFilter

@synthesize x;


-(void)addNewValue:(double) newValue {
  
    //NSDate *startTime = [[NSDate date] autorelease]; 
    
    // no filter
    if (self.filterMode==kNoFilter){
        self.x = newValue;
        return;
    }
    
	double alpha = super.filterConstant;
    /*
	if (self.filterMode==kAdaptiveFilter) {
        const int const kMinStep = 0.02;
        const int const kNoiseAttenuation = 3.0;
        
        double change = fabs( self.x - newValue );
        double exaggeratedChange = change / kMinStep;
        
        // map to 0.0 ... 1.0, with values <1.0 becoming zero
		double d = Clamp( exaggeratedChange - 1.0, 
                         0.0,  // min
                         1.0); // max
        
        // lower "d" means less weight for new values
		alpha = (1.0 - d) * self.filterConstant / kNoiseAttenuation + d * super.filterConstant;
	}
     */
    
	self.x = newValue * alpha + self.x * (1.0 - alpha);
    
    //NSTimeInterval elapsedTime = [startTime timeIntervalSinceNow];  
    //trace([NSString stringWithFormat:@"addAcceleration: %@ - elapsed: %f", [NSDate date], -elapsedTime]);
}


@end
