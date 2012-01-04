
#import <UIKit/UIKit.h>
#import "Geocoding.h"
#import "ARPickerController.h"

@interface ARViewController : UIViewController 

// address and button for geocoding
@property (nonatomic, retain) IBOutlet UITextField *addressTextField;
@property (nonatomic, retain) IBOutlet UIButton *searchButton;
@property (nonatomic, retain) IBOutlet UISwitch *accelModeSwitch;
@property (nonatomic, assign) BOOL accelMode;

- (IBAction) toggleAccelMode;


@property (nonatomic, retain) IBOutlet UISegmentedControl *filterModeControl;

/** Geocode of the address in the UITextView and launch the AR view. */
-(IBAction) search;


@end
