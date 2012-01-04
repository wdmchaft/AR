
#import "Logger.h"

@implementation Logger

@synthesize logThreshold, async;


+(Logger *)singleton {
    static dispatch_once_t pred;
    static Logger *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[Logger alloc] init];
        shared.logThreshold = kTrace;
        shared.async = TRUE;
    });
    return shared;
}


-(void) debugWithLevel:(LoggerLevel)level 
                  line:(int)line 
              funcName:(const char *)funcName 
               message:(NSString *)msg, ... {
    
    const char* const levelName[6] = { "TRACE", "DEBUG", " INFO", " WARN", "ERROR", "SILENT" };
    
    va_list ap;         // define variable ap of type va
    va_start (ap, msg); // initializes ap
	msg = [[[NSString alloc] initWithFormat:[NSString stringWithFormat:@"%@",msg] arguments:ap] autorelease];
    va_end (ap);        // invalidates ap

    // if there is no trailing \n add one
    if (![msg hasSuffix:@"\n"]) {  
		msg = [msg stringByAppendingString:@"\n"];
    }
    
    if (level>=logThreshold){
        // output to console without calling ASL
        const char *name = levelName[level];
        if (self.async){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (![msg hasPrefix:@"\n"]) {  
                        // if starting with /n then print bare
                        fprintf(stdout,"%s %50s:%3d - %s", name, funcName, line, [msg UTF8String]);
                    } else {
                        fprintf(stdout,"%s", [[msg substringFromIndex:1] UTF8String]);
                    }
                });
            });
        } else {
            if (![msg hasPrefix:@"\n"]) {  
                fprintf(stdout,"%s %50s:%3d - %s", name, funcName, line, [msg UTF8String]);
            } else {
                fprintf(stdout,"%s", [[msg substringFromIndex:1] UTF8String]);
            }
        }
    }
}


@end


