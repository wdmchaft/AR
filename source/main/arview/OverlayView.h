
#import <UIKit/UIKit.h>
#import "Hardware.h"


/**
 * View with the GUI that overlayed on the video feed.
 */
@interface OverlayView : UIView

@property (nonatomic, retain) UIImageView *guiTargetIcon;    // marker for the target (laughingman)
@property (nonatomic, retain) UILabel     *guiSensorsLabel;  // top bar with sensors
@property (nonatomic, retain) UILabel     *guiFpsLabel;      // fps label
@property (nonatomic, retain) UIButton    *infoButton;       // info button at bottom right

-(void) buildOverlay;

@end
