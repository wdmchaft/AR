
#import "Device.h"

@implementation Device

@synthesize fieldOfView, screenSizeInPoints, diagonalFromCenter;
@synthesize horizontalPointsPerDegree, horizontalDegreesPerPoint, verticalPointsPerDegree, verticalDegreesPerPoint;
@synthesize visibleAngularDistanceInDeg;


-(id)init {
    self = [super init];
    if (self!=nil){
        self.fieldOfView = [Hardware fieldOfView];
        self.screenSizeInPoints = [Hardware pointSizeOfScreen];
        self.diagonalFromCenter = [Hardware diagonalFromCenter];
        self.horizontalPointsPerDegree = screenSizeInPoints.width / fieldOfView.horizontal;
        self.horizontalDegreesPerPoint = fieldOfView.horizontal / screenSizeInPoints.width;
        self.verticalPointsPerDegree = screenSizeInPoints.height / fieldOfView.vertical;
        self.verticalDegreesPerPoint = fieldOfView.vertical / screenSizeInPoints.height;
        self.visibleAngularDistanceInDeg = fabs(fieldOfView.horizontal/2);
    }
    return self;
}


-(void) dealloc {
    [super dealloc];
}


@end
