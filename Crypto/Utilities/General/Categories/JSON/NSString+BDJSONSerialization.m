//
//  Created by Patrick Hogan/Manuel Zamora 2012
//


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#import "NSString+BDJSONSerialization.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Utilities
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#import "BDJSONError.h"


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NSString (BDJSONSerialization)


////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Parsing
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableDictionary *)JSONObject:(BDError *)error
{
    NSError *JSONError = nil;
    NSMutableDictionary *JSONObject = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&JSONError];
    
    if (!JSONObject)
    {
        [error addErrorWithType:BDJSONErrorParse
                          errorClass:[BDJSONError class]];
    }
    else if (![JSONObject isKindOfClass:[NSDictionary class]])
    {
        [error addErrorWithType:BDJSONErrorIncorrectType
                          errorClass:[BDJSONError class]];
    }
    
    return JSONObject;
}


- (NSMutableArray *)JSONArray:(BDError *)error
{
    NSError *JSONError = nil;
    NSMutableArray *JSONArray = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&JSONError];
    
    if (!JSONArray)
    {
        [error addErrorWithType:BDJSONErrorParse
                          errorClass:[BDJSONError class]];
    }
    else if (![JSONArray isKindOfClass:[NSArray class]])
    {
        [error addErrorWithType:BDJSONErrorIncorrectType
                          errorClass:[BDJSONError class]];
    }
    
    return JSONArray;
}


@end