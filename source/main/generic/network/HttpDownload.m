
#import "HttpDownload.h"

@implementation HttpDownload

@synthesize encodings, reachability;

-(id) init {
    self = [super init];
    if (self != nil){        
        self.reachability = [[Reachability reachabilityWithHostName: @"www.google.com"] retain];
		self.encodings = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"NSASCIIStringEncoding", @"1",
                          @"NSNEXTSTEPStringEncoding", @"2",
                          @"NSJapaneseEUCStringEncoding", @"3",
                          @"NSUTF8StringEncoding", @"4",
                          @"NSISOLatin1StringEncoding", @"5",
                          @"NSSymbolStringEncoding", @"6",
                          @"NSNonLossyASCIIStringEncoding", @"7",
                          @"NSShiftJISStringEncoding", @"8",
                          @"NSISOLatin2StringEncoding", @"9",
                          @"NSUnicodeStringEncoding", @"10",
                          @"NSWindowsCP1251StringEncoding", @"11",
                          @"NSWindowsCP1252StringEncoding", @"12",
                          @"NSWindowsCP1253StringEncoding", @"13",
                          @"NSWindowsCP1254StringEncoding", @"14",
                          @"NSWindowsCP1250StringEncoding", @"15",
                          @"NSISO2022JPStringEncoding", @"21",
                          @"NSMacOSRomanStringEncoding", @"30",
                          @"NSUTF16StringEncoding", @"10",
                          @"NSUTF16BigEndianStringEncoding", @"0x90000100",
                          @"NSUTF16LittleEndianStringEncoding", @"0x94000100",
                          @"NSUTF32StringEncoding", @"0x8c000100",
                          @"NSUTF32BigEndianStringEncoding", @"0x98000100",
                          @"NSUTF32LittleEndianStringEncoding", @"0x9c000100",
                          nil];   
    }
    return self;
}


- (NSString *) pageAsStringFromUrl:(NSString *)sUrl {
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    BOOL isReachable = status!=NotReachable;
    if (!isReachable) {
        debug(@"not reachable");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hudWarningNoConnection" object:nil];
        return nil;
    }
    //NSURL *url = [NSURL URLWithString:[sUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:sUrl];
    //trace(@"Downloading: %@", url);
    
	[[UIApplication sharedApplication] showNetworkActivityIndicator];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request startSynchronous];
	[[UIApplication sharedApplication] hideNetworkActivityIndicator];
	
	NSError *error = [request error];
	if (error) { warn(@"%@", [error localizedDescription] ); }
	NSString *result = [request responseString];
	debug(@"    Download: %d chars with encoding %@", 
		  [result length], 
		  [self.encodings objectForKey:[NSString stringWithFormat:@"%d",[request responseEncoding]]]
          );
    
	return result;
}


- (NSData *) pageAsDataFromUrl:(NSString *)sUrl {
    NetworkStatus status = [reachability currentReachabilityStatus];
    BOOL isReachable = status!=NotReachable;
    if (!isReachable) {
        debug(@"not reachable");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hudWarningNoConnection" object:nil];
        return nil;
    }
    //NSURL *url = [NSURL URLWithString:[sUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:sUrl];
    //trace(@"Downloading: %@", url);
    
	[[UIApplication sharedApplication] showNetworkActivityIndicator];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request startSynchronous];
	[[UIApplication sharedApplication] hideNetworkActivityIndicator];
	
	NSError *error = [request error];
	if (error) { warn(@"%@", [error localizedDescription] ); }
	NSString *result = [request responseString];
	debug(@"    Download: %d chars with encoding %@", 
		  [result length], 
		  [self.encodings objectForKey:[NSString stringWithFormat:@"%d",[request responseEncoding]]]);
	
	NSData *data = [result dataUsingEncoding:[request responseEncoding]];
	return data;
}


-(void) dealloc {    
    [self.reachability release];
    [self.encodings release];
    [super dealloc];
}


@end



