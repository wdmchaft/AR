
#import "OverlayView.h"


@implementation OverlayView

@synthesize guiFpsLabel, guiSensorsLabel, guiTargetIcon, infoButton;


/**
 * Sets self.guiTargetIcon, self.guiFpsLabel, self.guiSensorsLabel.
 */
-(void) buildOverlay {
    
    {
        // target image (the one tracking your destination)
        UIImage *overlayGraphic = [UIImage imageNamed:@"laughingman.png"];
        self.guiTargetIcon = [[UIImageView alloc] initWithImage:overlayGraphic];
        CGSize screenPoints = [Hardware pointSizeOfScreen];
        self.guiTargetIcon.frame = CGRectMake(screenPoints.width/2 - overlayGraphic.size.width/2, 
                                              screenPoints.height/2 - overlayGraphic.size.height/2, 
                                              overlayGraphic.size.width, 
                                              overlayGraphic.size.height);
        [self addSubview:self.guiTargetIcon];
        [self.guiTargetIcon release];
    }
    
    {
        // FPS label (the counter at top, right)
        NSString *twoDigits = @"00";
        UIFont *font = [UIFont fontWithName:@"standard 07_53" size:20];
        CGSize size = [twoDigits sizeWithFont:font];
        self.guiFpsLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake([Hardware pointSizeOfScreen].width-size.width, 40., size.width, size.height)];
        [self.guiFpsLabel setText:@"0"];
        [self.guiFpsLabel setBackgroundColor:[UIColor clearColor]];
        [self.guiFpsLabel setFont:font];
        [self.guiFpsLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:self.guiFpsLabel];
        [self.guiFpsLabel release];
    }
    
    {
        // sensors label (the bar at the top)
        CGSize screenPoints = [Hardware pointSizeOfScreen];
        self.guiSensorsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0., 0., screenPoints.width, 30.)];
        [self.guiSensorsLabel setText:@"waiting for updates"];
        [self.guiSensorsLabel setBackgroundColor:[UIColor purpleColor]];
        [self.guiSensorsLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [self.guiSensorsLabel setTextColor:[UIColor whiteColor]];
        self.guiSensorsLabel.numberOfLines = 0;
        [self addSubview:self.guiSensorsLabel];
        [self.guiSensorsLabel release];
    }
    
    {
        // info button (at bottom, right)
        self.infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [self.infoButton setFrame:CGRectMake(282, 421, 18, 19)];
    }
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        frame.origin.x = frame.origin.y = 0.0;
        [self buildOverlay];
    }
    return self;
}


- (void)dealloc {
    [guiTargetIcon   release],   guiTargetIcon=nil;
    [guiSensorsLabel release], guiSensorsLabel=nil;
    [guiFpsLabel     release],     guiFpsLabel=nil;
    [super dealloc];
}

@end
