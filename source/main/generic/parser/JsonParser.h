
#import <Foundation/Foundation.h>
#import "JSONKit.h"


/**
 * Method to parse a JSON string to a NSDictionary using JSONKit. 
 */
@interface JsonParser : NSObject {
}

/** @return NSDictionary containing the given JSON string. */
+(NSDictionary*) parseJson:(NSString*)jsonString;

@end
