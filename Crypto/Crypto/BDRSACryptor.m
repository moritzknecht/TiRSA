//
//  Created by Patrick Hogan on 10/12/12.
//


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#import "BDRSACryptor.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Utilities
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#import <Security/Security.h>

#import "NSData+Base64.h"
#import "NSString+Base64.h"

#import "BDCryptorError.h"
#import "BDRSACryptorKeyPair.h"


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constants
////////////////////////////////////////////////////////////////////////////////////////////////////////////
static unsigned char oidSequence [] = { 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00 };


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BDRSACryptor


////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Encryption/decryption methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
    
    [self setPublicKey:key
                   tag:[self publicKeyIdentifier]
                 error:error];
    
    SecKeyRef publicKey = [self keyRefWithTag:[self publicKeyIdentifier]
                                        error:error];
    
    if ([BDError error:error
     containsErrorType:BDCryptoErrorRSACopyKey
            errorClass:[BDCryptorError class]])
    {
        return nil;
    }
    
    uint8_t *nonce = (uint8_t *)[plainText UTF8String];
    size_t cipherBufferSize = SecKeyGetBlockSize(publicKey);
    uint8_t *cipherBuffer = malloc(cipherBufferSize);
    
//    BDDebugLog(@"Cipher buffer size: %lu", cipherBufferSize);
    
    if (cipherBufferSize < sizeof(nonce))
    {
        if (publicKey)
        {
            CFRelease(publicKey);
        }
        
        free(cipherBuffer);
        
        [error addErrorWithType:BDCryptoErrorRSATextLength
                     errorClass:[BDCryptorError class]];
        
        return nil;
    }
    
    OSStatus secStatus = SecKeyEncrypt(publicKey,
                                       kSecPaddingPKCS1,
                                       nonce,
                                       strlen((char *)nonce) + 1,
                                       &cipherBuffer[0],
                                       &cipherBufferSize);
    
    if (secStatus != noErr)
    {
        [error addErrorWithType:BDCryptoErrorEncrypt
                     errorClass:[BDCryptorError class]];
                
        return nil;
    }
    
    NSData *encryptedData = [NSData dataWithBytes:cipherBuffer
                                           length:cipherBufferSize];
    
//    BDDebugLog(@"Base 64 Encrypted String:\n%@", [encryptedData base64EncodedString]);
    
    if (publicKey)
    {
        CFRelease(publicKey);
    }
    free(cipherBuffer);
    
    NSString *result = [encryptedData base64EncodedString];
    
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
    
    [self setPrivateKey:key
                    tag:[self privateKeyIdentifier]
                  error:error];
    
    NSMutableDictionary *keyQueryDictionary = [self keyQueryDictionary:[self privateKeyIdentifier]];
    [keyQueryDictionary setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    SecKeyRef privateKey = [self keyRefWithTag:[self privateKeyIdentifier]
                                         error:error];
    
    if ([BDError error:error
     containsErrorType:BDCryptoErrorRSACopyKey
            errorClass:[BDCryptorError class]])
    {
        return nil;
    }
    
    size_t plainBufferSize = SecKeyGetBlockSize(privateKey);
    uint8_t *plainBuffer = malloc(plainBufferSize);
    
    NSData *incomingData = [cipherText base64DecodedData];
    uint8_t *cipherBuffer = (uint8_t*)[incomingData bytes];
    size_t cipherBufferSize = SecKeyGetBlockSize(privateKey);
    
    if (plainBufferSize < cipherBufferSize)
    {
        if (privateKey)
        {
            CFRelease(privateKey);
        }
        
        free(plainBuffer);
        
        [error addErrorWithType:BDCryptoErrorRSATextLength
                     errorClass:[BDCryptorError class]];
        
        return nil;
    }
    
    OSStatus secStatus = SecKeyDecrypt(privateKey,
                                       kSecPaddingPKCS1,
                                       cipherBuffer,
                                       cipherBufferSize,
                                       plainBuffer,
                                       &plainBufferSize);
    
    if (secStatus != noErr)
    {
        [error addErrorWithType:BDCryptoErrorDecrypt
                     errorClass:[BDCryptorError class]];
        
        return nil;
    }
    
    NSString *decryptedString = [[NSString alloc] initWithBytes:plainBuffer
                                                         length:plainBufferSize
                                                       encoding:NSUTF8StringEncoding];
    
    free(plainBuffer);
    
    if (privateKey)
    {
        CFRelease(privateKey);
    }
    
    return decryptedString;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Keychain generation and import/export methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BDRSACryptorKeyPair *)generateKeyPairWithKeyIdentifier:(NSString *)keyIdentifier
                                                   error:(BDError *)error
{
    NSString *publicKeyIdentifier = [self publicKeyIdentifierWithTag:keyIdentifier];
    NSString *privateKeyIdentifier = [self privateKeyIdentifierWithTag:keyIdentifier];
    
    [self removeKey:publicKeyIdentifier
              error:error];
    
    [self removeKey:privateKeyIdentifier
              error:error];
    
    NSMutableDictionary *publicKeyAttributes = [NSMutableDictionary dictionary];
    [publicKeyAttributes setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [publicKeyAttributes setObject:[publicKeyIdentifier dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrApplicationTag];
    
    NSMutableDictionary *privateKeyAttributes = [NSMutableDictionary dictionary];
    [privateKeyAttributes setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [privateKeyAttributes setObject:[privateKeyIdentifier dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrApplicationTag];
    
    NSMutableDictionary *keyPairAttributes = [NSMutableDictionary dictionary];
    [keyPairAttributes setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [keyPairAttributes setObject:[NSNumber numberWithInt:1024] forKey:(__bridge id)kSecAttrKeySizeInBits];
    [keyPairAttributes setObject:privateKeyAttributes forKey:(__bridge id)kSecPrivateKeyAttrs];
    [keyPairAttributes setObject:publicKeyAttributes forKey:(__bridge id)kSecPublicKeyAttrs];
    
    SecKeyRef publicKey = NULL;
    SecKeyRef privateKey = NULL;
    OSStatus err = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttributes, &publicKey, &privateKey);
    
    if (err != noErr)
    {
        [error addErrorWithType:BDCryptoErrorRSAGenerateKey
                     errorClass:[BDCryptorError class]];
        
        return nil;
    }
    
    if (publicKey)
    {
        CFRelease(publicKey);
    }
    
    if (privateKey)
    {
        CFRelease(privateKey);
    }
    
    BDRSACryptorKeyPair *result = [[BDRSACryptorKeyPair alloc] initWithPublicKey:[self X509FormattedPublicKey:publicKeyIdentifier
                                                                                                      error:error]
                                                                    privateKey:[self PEMFormattedPrivateKey:privateKeyIdentifier
                                                                                                      error:error]];
    
    if (!result.publicKey || !result.privateKey)
    {
        return nil;
    }
    
    return result;
}


- (NSString *)PEMFormattedPrivateKey:(NSString *)tag
                               error:(BDError *)error
{
    NSData *privateKeyData = [self keyDataWithTag:tag
                                            error:error];
    
    if ([BDError error:error
     containsErrorType:BDCryptoErrorRSACopyKey
            errorClass:[BDCryptorError class]])
    {
        return nil;
    }
    
//    BDDebugLog(@"Private Key Bits:\n%@", privateKeyData);
    
    NSMutableData * encodedKey = [[NSMutableData alloc] init];
    [encodedKey appendData:privateKeyData];
    NSString *result = [NSString stringWithFormat:@"%@\n%@\n%@",
                        [self PEMPrivateHeader],
                        [encodedKey base64EncodedStringWithWrapWidth:[self PEMWrapWidth]],
                        [self PEMPrivateFooter]];
    
//    BDDebugLog(@"PEM formatted key:\n%@", result);
    
    return result;
}


- (NSString *)X509FormattedPublicKey:(NSString *)tag
                               error:(BDError *)error
{
    NSData *publicKeyData = [self keyDataWithTag:tag
                                           error:error];
    
    if ([BDError error:error
     containsErrorType:BDCryptoErrorRSACopyKey
            errorClass:[BDCryptorError class]])
    {
        return nil;
    }
    
    unsigned char builder[15];
    int bitstringEncLength;
    if  ([publicKeyData length] + 1  < 128 )
    {
        bitstringEncLength = 1 ;
    }
    else
    {
        bitstringEncLength = (([publicKeyData length ] + 1)/256) + 2;
    }
    
    builder[0] = 0x30;
    
    size_t i = sizeof(oidSequence) + 2 + bitstringEncLength + [publicKeyData length];
    size_t j = [self encode:&builder[1]
                     length:i];
    
    NSMutableData *encodedKey = [[NSMutableData alloc] init];
    
    [encodedKey appendBytes:builder
                     length:j + 1];
    
    [encodedKey appendBytes:oidSequence
                     length:sizeof(oidSequence)];
    
    builder[0] = 0x03;
    j = [self encode:&builder[1]
              length:[publicKeyData length] + 1];
    
    builder[j+1] = 0x00;
    [encodedKey appendBytes:builder
                     length:j + 2];
    
    [encodedKey appendData:publicKeyData];
    
    NSString *returnString = [NSString stringWithFormat:@"%@\n%@\n%@",
                              [self X509PublicHeader],
                              [encodedKey base64EncodedStringWithWrapWidth:[self PEMWrapWidth]],
                              [self X509PublicFooter]];
    
//    BDDebugLog(@"PEM formatted key:\n%@", returnString);
    
    return returnString;
}


- (size_t)encode:(unsigned char *)buffer
          length:(size_t)length
{
    if (length < 128)
    {
        buffer[0] = length;
        return 1;
    }
    
    size_t i = (length / 256) + 1;
    buffer[0] = i + 0x80;
    for (size_t j = 0 ; j < i; ++j)
    {
        buffer[i - j] = length & 0xFF;
        length = length >> 8;
    }
    
    return i + 1;
}


- (void)setPrivateKey:(NSString *)key
                  tag:(NSString *)tag
                error:(BDError *)error
{
    [self removeKey:tag
              error:nil];
    
    NSString *strippedKey = nil;
    if ([self isPrivateKey:key])
    {
        strippedKey = [self strippedKey:key
                                 header:[self PEMPrivateHeader]
                                 footer:[self PEMPrivateFooter]];
    }
    
    if (!strippedKey)
    {
        [error addErrorWithType:BDCryptoErrorRSAKeyFormat
                     errorClass:[BDCryptorError class]];
        
        return;
    }
    
    NSData *strippedPrivateKeyData = [strippedKey base64DecodedData];
    
//    BDDebugLog(@"Stripped Private Key Base 64:\n%@",strippedKey);
    
    NSMutableDictionary *keyQueryDictionary = [self keyQueryDictionary:tag];
    [keyQueryDictionary setObject:strippedPrivateKeyData forKey:(__bridge id)kSecValueData];
    [keyQueryDictionary setObject:(__bridge id)kSecAttrKeyClassPrivate forKey:(__bridge id)kSecAttrKeyClass];
    [keyQueryDictionary setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];
    
    CFTypeRef persistKey = nil;
    OSStatus secStatus = SecItemAdd((__bridge CFDictionaryRef)keyQueryDictionary, &persistKey);
    
    if (persistKey != nil)
    {
        CFRelease(persistKey);
    }
    
    if ((secStatus != noErr) && (secStatus != errSecDuplicateItem))
    {
        [error addErrorWithType:BDCryptoErrorRSAAddKey
                     errorClass:[BDCryptorError class]];
        
        return;
    }
    
    return;
}


- (void)setPublicKey:(NSString *)key
                 tag:(NSString *)tag
               error:(BDError *)error
{
    [self removeKey:tag
              error:nil];
    
    NSData *strippedPublicKeyData = [self strippedPublicKey:key
                                                      error:error];
    
    if ([BDError errorContainsErrors:error])
    {
        return;
    }
    
//    BDDebugLog(@"Stripped Public Key Bytes:\n%@", [strippedPublicKeyData description]);
    
    CFTypeRef persistKey = nil;
    
    NSMutableDictionary *keyQueryDictionary = [self keyQueryDictionary:tag];
    [keyQueryDictionary setObject:strippedPublicKeyData forKey:(__bridge id)kSecValueData];
    [keyQueryDictionary setObject:(__bridge id)kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];
    [keyQueryDictionary setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];
    
    OSStatus secStatus = SecItemAdd((__bridge CFDictionaryRef)keyQueryDictionary, &persistKey);
    
    if (persistKey != nil)
    {
        CFRelease(persistKey);
    }
    
    if ((secStatus != noErr) && (secStatus != errSecDuplicateItem))
    {
        [error addErrorWithType:BDCryptoErrorRSAAddKey
                     errorClass:[BDCryptorError class]];
        
        return;
    }
    
    return;
}


- (NSData *)strippedPublicKey:(NSString *)key
                        error:(BDError *)error
{
    NSString *strippedKey = nil;
    if ([self isX509PublicKey:key])
    {
        strippedKey = [self strippedKey:key
                                 header:[self X509PublicHeader]
                                 footer:[self X509PublicFooter]];
    }
    else if ([self isPKCS1PublicKey:key])
    {
        strippedKey = [self strippedKey:key
                                 header:[self PKCS1PublicHeader]
                                 footer:[self PKCS1PublicFooter]];
    }
    
    if (!strippedKey)
    {
        [error addErrorWithType:BDCryptoErrorRSAKeyFormat
                     errorClass:[BDCryptorError class]];
        
        return nil;
    }
    
    NSData *strippedPublicKeyData = [strippedKey base64DecodedData];
    if ([self isX509PublicKey:key])
    {
        unsigned char * bytes = (unsigned char *)[strippedPublicKeyData bytes];
        size_t bytesLen = [strippedPublicKeyData length];
        
        size_t i = 0;
        if (bytes[i++] != 0x30)
        {
            [error addErrorWithType:BDCryptoErrorRSAKeyFormat
                         errorClass:[BDCryptorError class]];
            
            return nil;
        }
        
        if (bytes[i] > 0x80)
        {
            i += bytes[i] - 0x80 + 1;
        }
        else
        {
            i++;
        }
        
        if (i >= bytesLen)
        {
            [error addErrorWithType:BDCryptoErrorRSAKeyFormat
                         errorClass:[BDCryptorError class]];
            
            return nil;
        }
        if (bytes[i] != 0x30)
        {
            [error addErrorWithType:BDCryptoErrorRSAKeyFormat
                         errorClass:[BDCryptorError class]];
            
            
            return nil;
        }
        
        i += 15;
        
        if (i >= bytesLen - 2)
        {
            [error addErrorWithType:BDCryptoErrorRSAKeyFormat
                         errorClass:[BDCryptorError class]];
            
            
            return nil;
        }
        if (bytes[i++] != 0x03)
        {
            [error addErrorWithType:BDCryptoErrorRSAKeyFormat
                         errorClass:[BDCryptorError class]];
            
            return nil;
        }
        
        if (bytes[i] > 0x80)
        {
            i += bytes[i] - 0x80 + 1;
        }
        else
        {
            i++;
        }
        
        if (i >= bytesLen)
        {
            [error addErrorWithType:BDCryptoErrorRSAKeyFormat
                         errorClass:[BDCryptorError class]];
            
            return nil;
        }
        if (bytes[i++] != 0x00)
        {
            [error addErrorWithType:BDCryptoErrorRSAKeyFormat
                         errorClass:[BDCryptorError class]];
            
            return nil;
        }
        if (i >= bytesLen)
        {
            [error addErrorWithType:BDCryptoErrorRSAKeyFormat
                         errorClass:[BDCryptorError class]];
            
            return nil;
        }
        
        strippedPublicKeyData = [NSData dataWithBytes:&bytes[i]
                                               length:bytesLen - i];
    }
    
//    BDDebugLog(@"X.509 Formatted Public Key bytes:\n%@", [strippedPublicKeyData description]);
    
    if (!strippedPublicKeyData)
    {
        [error addErrorWithType:BDCryptoErrorRSAKeyFormat
                     errorClass:[BDCryptorError class]];
        
        return nil;
    }
    
    return strippedPublicKeyData;
}


- (NSString *)strippedKey:(NSString *)key
                   header:(NSString *)header
                   footer:(NSString *)footer
{
    NSString *result = [[key stringByReplacingOccurrencesOfString:header
                                                       withString:@""] stringByReplacingOccurrencesOfString:footer withString:@""];
    
    return [[result stringByReplacingOccurrencesOfString:@"\n"
                                              withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
}


- (BOOL)isPrivateKey:(NSString *)key
{
    if (([key rangeOfString:[self PEMPrivateHeader]].location != NSNotFound) && ([key rangeOfString:[self PEMPrivateFooter]].location != NSNotFound))
    {
        return YES;
    }
    
    return NO;
}


- (BOOL)isX509PublicKey:(NSString *)key
{
    if (([key rangeOfString:[self X509PublicHeader]].location != NSNotFound) && ([key rangeOfString:[self X509PublicFooter]].location != NSNotFound))
    {
        return YES;
    }
    
    return NO;
}


- (BOOL)isPKCS1PublicKey:(NSString *)key
{
    if (([key rangeOfString:[self PKCS1PublicHeader]].location != NSNotFound) && ([key rangeOfString:[self PKCS1PublicFooter]].location != NSNotFound))
    {
        return YES;
    }
    
    return NO;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Keychain convenience methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSData *)keyDataWithTag:(NSString *)tag
                     error:(BDError *)error
{
    NSMutableDictionary *queryKey = [self keyQueryDictionary:tag];
    [queryKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
    
    SecKeyRef key = NULL;
    OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef)queryKey, (CFTypeRef *)&key);
    
    if (err != noErr || !key)
    {
        [error addErrorWithType:BDCryptoErrorRSACopyKey
                     errorClass:[BDCryptorError class]];
        
        return nil;
    }
    
    return (__bridge NSData *)key;
}


- (SecKeyRef)keyRefWithTag:(NSString *)tag
                     error:(BDError *)error
{
    NSMutableDictionary *queryKey = [self keyQueryDictionary:tag];
    [queryKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    SecKeyRef key = NULL;
    OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef)queryKey, (CFTypeRef *)&key);
    
    if (err != noErr)
    {
        [error addErrorWithType:BDCryptoErrorRSACopyKey
                     errorClass:[BDCryptorError class]];
        
        
        return nil;
    }
    
    return key;
}


- (void)removeKey:(NSString *)tag
            error:(BDError *)error
{
    NSDictionary *queryKey = [self keyQueryDictionary:tag];
    OSStatus secStatus = SecItemDelete((__bridge CFDictionaryRef)queryKey);
    
    if ((secStatus != noErr) && (secStatus != errSecDuplicateItem))
    {
        [error addErrorWithType:BDCryptoErrorRSARemoveKey
                     errorClass:[BDCryptorError class]];
    }
}


- (NSMutableDictionary *)keyQueryDictionary:(NSString *)tag
{
    NSData *keyTag = [tag dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [result setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [result setObject:keyTag forKey:(__bridge id)kSecAttrApplicationTag];
    [result setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    
    return result;
}


- (NSUInteger)PEMWrapWidth
{
    return 64;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - RSA Key Anatomy
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)X509PublicHeader
{
    return @"-----BEGIN PUBLIC KEY-----";
}


- (NSString *)X509PublicFooter
{
    return @"-----END PUBLIC KEY-----";
}


- (NSString *)PKCS1PublicHeader
{
    return  @"-----BEGIN RSA PUBLIC KEY-----";
}


- (NSString *)PKCS1PublicFooter
{
    return @"-----END RSA PUBLIC KEY-----";
}


- (NSString *)PEMPrivateHeader
{
    return @"-----BEGIN RSA PRIVATE KEY-----";
}


- (NSString *)PEMPrivateFooter
{
    return @"-----END RSA PRIVATE KEY-----";
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Important tags
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)publicKeyIdentifier
{
    return [self publicKeyIdentifierWithTag:nil];
}


- (NSString *)privateKeyIdentifier
{
    return [self privateKeyIdentifierWithTag:nil];
}


- (NSString *)publicKeyIdentifierWithTag:(NSString *)additionalTag
{
    NSString *identifier = [NSString stringWithFormat:@"%@.publicKey", [[NSBundle mainBundle] bundleIdentifier]];
    
    if (additionalTag)
    {
        identifier = [identifier stringByAppendingFormat:@".%@", additionalTag];
    }
    
    return identifier;
}


- (NSString *)privateKeyIdentifierWithTag:(NSString *)additionalTag
{
    NSString *identifier = [NSString stringWithFormat:@"%@.privateKey", [[NSBundle mainBundle] bundleIdentifier]];
    
    if (additionalTag)
    {
        identifier = [identifier stringByAppendingFormat:@".%@", additionalTag];
    }
    
    return identifier;
}


@end