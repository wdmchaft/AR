
#import "JsonParser.h"

@implementation JsonParser


+(NSDictionary*) parseJson:(NSString*) jsonString {
	
	NSDictionary *rootDict = nil;
	NSError *error = nil;
	@try {
		JKParseOptionFlags options = JKParseOptionComments | JKParseOptionUnicodeNewlines;
		rootDict = [jsonString objectFromJSONStringWithParseOptions:options error:&error];
		if (error) {
			warn(@"%@",[error localizedDescription]);
		}
		debug(@"    JSONKit: %d characters resulted in %d root node", [jsonString length], [rootDict count]);
		
	} @catch (NSException * e) {
		// If data is 0 bytes, here we get: "NSInvalidArgumentException The string argument is NULL"
		warn(@"%@ %@", [e name], [e reason]);
		
		// abort
		rootDict = nil;
	}
	return rootDict;
}


@end
