//
//  Created by Patrick Hogan on 10/12/12.
//


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macros
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define BDCryptoErrorEncrypt @"BDCryptoErrorEncrypt"
#define BDCryptoErrorDecrypt @"BDCryptoErrorDecrypt"
#define BDCryptoErrorAESCreation @"BDCryptoErrorAESCreation"
#define BDCryptoErrorAESUpdate @"BDCryptoErrorAESUpdate"
#define BDCryptoErrorAESFinal @"BDCryptoErrorAESFinal"
#define BDCryptoErrorAESPlainTextSize @"BDCryptoErrorAESPlainTextSize"
#define BDCryptoErrorRSACopyKey @"BDCryptoErrorRSACopyKey"
#define BDCryptoErrorRSATextLength @"BDCryptoErrorRSATextLength"
#define BDCryptoErrorRSAKeyFormat @"BDCryptoErrorRSAKeyFormat"
#define BDCryptoErrorRSAAddKey @"BDCryptoErrorRSAAddKey"
#define BDCryptoErrorRSARemoveKey @"BDCryptoErrorRSARemoveKey"
#define BDCryptoErrorRSAGenerateKey @"BDCryptoErrorRSAGenerateKey"
#define BDCryptoErrorSHAHash @"BDCryptoErrorSHAHash"


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Interface
////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface BDCryptorError : BDError

@end
