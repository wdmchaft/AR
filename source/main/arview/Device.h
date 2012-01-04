
#import "Hardware.h"

/** Properties of this device. */
@interface Device : NSObject

@property (nonatomic, assign) float horizontalPointsPerDegree;   // h points per degree
@property (nonatomic, assign) float horizontalDegreesPerPoint;   // h degrees per point
@property (nonatomic, assign) float verticalPointsPerDegree;     // v points per degree
@property (nonatomic, assign) float verticalDegreesPerPoint;     // v degrees per point
@property (nonatomic, assign) float diagonalFromCenter;
@property (nonatomic, assign) float visibleAngularDistanceInDeg; // visible angular distanc
@property (nonatomic, assign) CGSize screenSizeInPoints;         // size of screen in pointse
@property (nonatomic, assign) FieldOfView fieldOfView;           // camera field of view


@end
