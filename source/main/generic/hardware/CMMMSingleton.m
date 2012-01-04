
#import "CMMMSingleton.h"

@implementation CMMMSingleton

+(CMMMSingleton *)singleton {
    static dispatch_once_t pred;
    static CMMMSingleton *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[CMMMSingleton alloc] init];
    });
    return shared;
}


- (void)release {
    warn(@"Ignoring your release request because I'm a singleton.");
} 

@end
