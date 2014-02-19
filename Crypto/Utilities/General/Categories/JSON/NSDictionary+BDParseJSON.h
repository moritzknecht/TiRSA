//
//  Created by Patrick Hogan/Manuel Zamora 2012
//


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface NSDictionary (BDParseJSON)

- (NSNumber *)booleanNumberValueForKeyPath:(NSString *)keyPath
                                     error:(BDError *)error;

- (NSString *)stringValueForKeyPath:(NSString *)keyPath
                              error:(BDError *)error;

- (NSDecimalNumber *)decimalNumberValueForKeyPath:(NSString *)keyPath
                                            error:(BDError *)error;

- (NSDecimalNumber *)safeDecimalNumberValueForKeyPath:(NSString *)keyPath
                                                error:(BDError *)error;

- (NSMutableArray *)arrayValueForKeyPath:(NSString *)keyPath
                                   error:(BDError *)error;

- (NSMutableDictionary *)dictionaryValueForKeyPath:(NSString *)keyPath
                                             error:(BDError *)error;

@end