//
//  Created by Patrick Hogan on 10/12/12.
//


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#import "BDAESCBC256Cryptor.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Utilities
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#import "NSData+Base64.h"
#import "NSString+Base64.h"

#import "BDCryptorError.h"


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BDAESCBC256Cryptor


- (NSString *)encrypt:(NSString *)plainText
                  key:(NSString *)key
                error:(BDError *)error
{
    if (!plainText)
    {
        [error addErrorWithType:BDCryptoErrorEncrypt
                     errorClass:[BDCryptorError class]];
        
        return nil;
    }
    
    if (plainText.length > [self maximumBlockSize])
    {
        [error addErrorWithType:BDCryptoErrorAESPlainTextSize
                     errorClass:[BDCryptorError class]];
        
        return nil;
    }
    
    NSString *result = [[self performOperation:kCCEncrypt
                                          data:[plainText dataUsingEncoding:NSUTF8StringEncoding]
                                           key:key
                                         error:error] base64EncodedString];
    
    return result;
}


- (NSString *)decrypt:(NSString *)cipherText
                  key:(NSString *)key
                error:(BDError *)error
{
    if (!cipherText)
    {
        [error addErrorWithType:BDCryptoErrorDecrypt
                     errorClass:[BDCryptorError class]];
        
        return nil;
    }
    
    NSString *result = [[NSString alloc] initWithData:[self performOperation:kCCDecrypt
                                                                        data:[cipherText base64DecodedData]
                                                                         key:key
                                                                       error:error]
                                             encoding:NSUTF8StringEncoding];
    
    return result;
}


- (NSData *)performOperation:(CCOperation)operation
                        data:(NSData *)inputData
                         key:(NSString *)key
                       error:(BDError *)error
{
    NSData *keyData = [[self paddedKey:key] dataUsingEncoding:NSUTF8StringEncoding];
    
    CCCryptorRef cryptor = NULL;
    CCCryptorStatus status = kCCSuccess;
    
    uint8_t iv[kCCBlockSizeAES128];
    memset((void *)iv, 0x0, (size_t) sizeof(iv));
    
    status = CCCryptorCreate(operation,
                             kCCAlgorithmAES128,
                             kCCOptionPKCS7Padding,
                             [keyData bytes],
                             kCCKeySizeAES256,
                             iv,
                             &cryptor);
    
    if (status != kCCSuccess)
    {
        [error addErrorWithType:BDCryptoErrorAESCreation
                     errorClass:[BDCryptorError class]];
        
        return nil;
    }
    
    size_t bufsize = CCCryptorGetOutputLength(cryptor, (size_t)[inputData length], YES);
    
    void *buf = malloc(bufsize * sizeof(uint8_t));
    memset(buf, 0x0, bufsize);
    
    size_t bufused = 0;
    size_t bytesTotal = 0;
    
    status = CCCryptorUpdate(cryptor,
                             [inputData bytes],
                             (size_t)[inputData length],
                             buf,
                             bufsize,
                             &bufused);
    
    if (status != kCCSuccess)
    {
        free(buf);
        CCCryptorRelease(cryptor);
        [error addErrorWithType:BDCryptoErrorAESUpdate
                     errorClass:[BDCryptorError class]];
        
        return nil;
    }
    
    bytesTotal += bufused;
    
    status = CCCryptorFinal(cryptor, buf + bufused, bufsize - bufused, &bufused);
    
    if (status != kCCSuccess)
    {
        free(buf);
        CCCryptorRelease(cryptor);
        
        [error addErrorWithType:BDCryptoErrorAESFinal
                     errorClass:[BDCryptorError class]];
        
        return nil;
    }
    
    bytesTotal += bufused;
    
    CCCryptorRelease(cryptor);
    
    return [NSData dataWithBytesNoCopy:buf
                                length:bytesTotal];
}


- (NSString *)paddedKey:(NSString *)key
{
    NSString *result = key;
    while (result.length < [self keySize])
    {
        result = [result stringByAppendingString:@" "];
    }
    
    result = [result substringWithRange:NSMakeRange(0, [self keySize])];
    
    return result;
}


- (NSInteger)keySize
{
    return 32;
}


@end
