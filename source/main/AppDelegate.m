
#import "AppDelegate.h"
#import "ARViewController.h"
#import "Hardware.h"


@implementation AppDelegate

@synthesize window=_window;
@synthesize viewController=_viewController;


/** Warn when connectivity is lost. */
-(void) hudWarningNoConnection {
    ATMHud *myHud = [[[ATMHud alloc] initWithDelegate:self] autorelease];
    [myHud setCaption:@"no Internet :("];
    [self.window addSubview:myHud.view];
    [myHud show];
    [myHud hideAfter:2.0];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    // notification center for missing connectivity
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(hudWarningNoConnection) 
                                                 name:@"hudWarningNoConnection" 
                                               object:nil];
    
    // configure logger
    {
        BOOL async = TRUE;
        [[Logger singleton] setAsync:async];
        [[Logger singleton] setLogThreshold:kTrace];
        trace(@"Logger set to async:%@", async?@"TRUE":@"FALSE");
    }
    
    return YES;
}


- (void)dealloc {
    [_window release];
    [_viewController release];
    [super dealloc];
}


@end
