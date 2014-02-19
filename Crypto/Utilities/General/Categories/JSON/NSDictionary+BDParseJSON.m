//
//  Created by Patrick Hogan/Manuel Zamora 2012
//

////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#import "NSDictionary+BDParseJSON.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Utilities
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#import "BDJSONError.h"
#import "NSString+BDJSONSerialization.h"
#import "NSDictionary+BDJSONSerialization.h"
#import "NSArray+BDJSONSerialization.h"


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NSDictionary (BDParseJSON)


////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Parsing
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSNumber *)booleanNumberValueForKeyPath:(NSString *)keyPath
                                     error:(BDError *)error
{
    id boolValue = [self valueForKeyPath:keyPath];
    
    if ([boolValue isKindOfClass:[NSNumber class]])
    {
        return @([boolValue boolValue]);
    }
    
    if ([boolValue isKindOfClass:[NSString class]])
    {
        if ([boolValue isEqualToString:@"true"])
        {
            return @YES;
        }
        else if ([boolValue isEqualToString:@"false"])
        {
            return @NO;
        }
    }
    
    [self populateError:error
                keyPath:keyPath];
    
    return nil;
}


- (NSString *)stringValueForKeyPath:(NSString *)keyPath
                              error:(BDError *)error
{
    NSString *string = [self valueForKeyPath:keyPath
                                expectedType:[NSString class]];
    
    if (string)
    {
        return string;
    }
    
    [self populateError:error
                keyPath:keyPath];
    
    return nil;
}


- (NSDecimalNumber *)safeDecimalNumberValueForKeyPath:(NSString *)keyPath
                                                error:(BDError *)error
{
    NSDecimalNumber *decimalNumber = [self decimalNumberValueForKeyPath:keyPath
                                                                  error:error];
    
    if (decimalNumber)
    {
        return decimalNumber;
    }
    
    return [NSDecimalNumber zero];
}


- (NSDecimalNumber *)decimalNumberValueForKeyPath:(NSString *)keyPath
                                            error:(BDError *)error
{
    NSDecimalNumber *decimalNumber = [self valueForKeyPath:keyPath
                                             expectedTypes:@[ [NSString class], [NSNumber class] ]];
    
    NSString *stringValue = [decimalNumber isKindOfClass:[NSString class]] ? (NSString *)decimalNumber : decimalNumber.stringValue;
    if (!decimalNumber || !stringValue)
    {
        [self populateError:error
                    keyPath:keyPath];
        
        return nil;
    }
    
    decimalNumber = [NSDecimalNumber decimalNumberWithString:stringValue];
    if ([decimalNumber isEqual:[NSDecimalNumber notANumber]])
    {
        [self populateError:error
                    keyPath:keyPath];
        
        return nil;
    }
    
    return decimalNumber;
}


- (NSMutableArray *)arrayValueForKeyPath:(NSString *)keyPath
                                   error:(BDError *)error
{
    NSMutableArray *array  = [self valueForKeyPath:keyPath
                                      expectedType:[NSArray class]];
    
    if (array)
    {
        if (![array isKindOfClass:[NSMutableArray class]])
        {
            return [array mutableCopy];
        }
        
        return array;
    }
    
    [self populateError:error
                keyPath:keyPath];
    
    return nil;
}


- (NSMutableDictionary *)dictionaryValueForKeyPath:(NSString *)keyPath
                                             error:(BDError *)error
{
    NSMutableDictionary *dictionary = [self valueForKeyPath:keyPath
                                               expectedType:[NSDictionary class]];
    
    if (dictionary)
    {
        if (![dictionary isKindOfClass:[NSMutableDictionary class]])
        {
            return [dictionary mutableCopy];
        }
        
        return dictionary;
    }
    
    [self populateError:error
                keyPath:keyPath];
    
    return nil;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Convenience
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)valueForKeyPath:(NSString *)keyPath
         expectedType:(Class)expectedType
{
    id value = [self valueForKeyPath:keyPath];
    
    if (value && (value != (id)[NSNull null]))
    {
        if ([value isKindOfClass:expectedType])
        {
            return value;
        }
        
        return [self castValue:value
                  expectedType:expectedType];
    }
    
    return nil;
}


- (id)castValue:(id)value
   expectedType:(Class)expectedType
{
    if ([value isKindOfClass:[NSString class]])
    {
        if ([expectedType isSubclassOfClass:[NSDictionary class]])
        {
            return [(NSString *)value JSONObject:nil];
        }
        else if ([expectedType isSubclassOfClass:[NSArray class]])
        {
            return [(NSString *)value JSONArray:nil];
        }
    }
    else if ([value isKindOfClass:[NSDictionary class]])
    {
        if ([expectedType isSubclassOfClass:[NSString class]])
        {
            return [(NSDictionary *)value stringValue:nil];
        }
    }
    else if ([value isKindOfClass:[NSArray class]])
    {
        if ([expectedType isSubclassOfClass:[NSString class]])
        {
            return [(NSArray *)value stringValue:nil];
        }
    }
    
    return nil;
}


- (id)valueForKeyPath:(NSString *)keyPath
        expectedTypes:(NSArray *)expectedTypes
{
    for (Class expectedType in expectedTypes)
    {
        id value = [self valueForKeyPath:keyPath
                            expectedType:expectedType];
        
        if (value)
        {
            return value;
        }
    }
    
    return nil;
}


- (id)normalizedValueForKeyPath:(NSString *)keyPath
                   expectedType:(Class)expectedType
                          error:(BDError *)error
{
    if ([expectedType isSubclassOfClass:[NSString class]])
    {
        return [self stringValueForKeyPath:keyPath
                                     error:error];
    }
    else if ([expectedType isSubclassOfClass:[NSDecimalNumber class]])
    {
        return [self decimalNumberValueForKeyPath:keyPath
                                            error:error];
    }
    else if ([expectedType isSubclassOfClass:[NSNumber class]])
    {
        // Warning BD: 
        return [self booleanNumberValueForKeyPath:keyPath
                                            error:error];
    }
    else if ([expectedType isSubclassOfClass:[NSDictionary class]])
    {
        return [self dictionaryValueForKeyPath:keyPath
                                         error:error];
    }
    else if ([expectedType isSubclassOfClass:[NSArray class]])
    {
        return [self arrayValueForKeyPath:keyPath
                                    error:error];
    }
    
    return nil;
}



- (BOOL)populateError:(BDError *)error
              keyPath:(NSString *)keyPath
{
    BDDebugLog(@"Unexpected type error: %@ not expected type.", keyPath);
    
    [error addErrorWithType:BDJSONErrorIncorrectType
                      errorClass:[BDJSONError class]];
    
    return YES;
}


@end
