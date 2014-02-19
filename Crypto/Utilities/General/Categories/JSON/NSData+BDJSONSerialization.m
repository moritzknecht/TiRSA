//
//  Created by Patrick Hogan/Manuel Zamora 2012
//


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#import "NSData+BDJSONSerialization.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Utilities
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#import "BDJSONError.h"


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NSData (BDJSONSerialization)


////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Parsing
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableDictionary *)JSONObject:(BDError *)error
{
    NSError *unhandledError = nil;
    NSMutableDictionary *JSONObject = [NSJSONSerialization JSONObjectWithData:self
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&unhandledError];
    
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
    NSError *unhandledError = nil;
    NSMutableArray *JSONArray = [NSJSONSerialization JSONObjectWithData:self
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&unhandledError];
    
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
