//
//  Created by Patrick Hogan on 10/12/12.
//


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#import "BDSHA512Cryptor.h"


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Utilities
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#import "BDCryptorError.h"


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BDSHA512Cryptor


- (NSString *)SHA512Hash:(NSString *)inputString
                   error:(BDError *)error
{
    if (!inputString)
    {
        [error addErrorWithType:BDCryptoErrorEncrypt
                     errorClass:[BDCryptorError class]];
        
        return nil;
    }
    
    const char *fullCString = [inputString cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSData *keyData = [NSData dataWithBytes:fullCString
                                     length:strlen(fullCString)];
    
    uint8_t digest[CC_SHA512_DIGEST_LENGTH] = { 0 };
    CC_SHA512(keyData.bytes, keyData.length, digest);
    
    NSData *outString = [NSData dataWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];
    
    NSString *result = [[[[outString description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                         stringByReplacingOccurrencesOfString: @">" withString: @""]
                        stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    return result;
}


@end
