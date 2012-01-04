
typedef enum {
    kNoFilter=0, kFilter=1, kAdaptiveFilter=2
} LowPassFilterMode;


// Taken from AccelerometerGraph from Apple
@interface LowPassFilter : NSObject

// acceleration x,y,z
@property (nonatomic, assign) double filterConstant;
@property (nonatomic, assign) LowPassFilterMode filterMode;

-(id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq;

double Clamp(double v, double min, double max);

@end