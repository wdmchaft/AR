
#import "ASIHTTPRequest.h"
#import "UIApplication+Extension.h"
#import "Reachability.h"

/** 
 * Methods to download a url as a page or data. 
 */
@interface HttpDownload : NSObject {
	NSDictionary *encodings;
    Reachability *reach;
}

@property (nonatomic,retain) Reachability *reachability;
@property (nonatomic, retain) NSDictionary *encodings;

/** 
 * Download a URL as a string.
 * If www.google.com is not reachable, this method sends a "hudWarningNoConnection" notification.
 *
 * @return URL as data
 */
- (NSData *) pageAsDataFromUrl:(NSString *)sUrl;

/** 
 * Download a URL as a string.
 * If www.google.com is not reachable, this method sends a "hudWarningNoConnection" notification.
 *
 * @return URL as string 
 */
- (NSString *) pageAsStringFromUrl:(NSString *) sUrl;

@end

