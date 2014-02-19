/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiRsaModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation TiRsaModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"1071b831-0061-4d74-91ed-6003c7793730";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"ti.rsa";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added 
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs

-(id)example:(id)args
{
	// example method
	return @"hello world";
}

-(id)exampleProp
{
	// example property getter
	return @"hello world";
}

-(void)setExampleProp:(id)value
{
	// example property setter
}

-(id)generateKeyPair:(id)args
{
    BDError *error = [[BDError alloc] init];
    BDRSACryptor *RSACryptor = [[BDRSACryptor alloc] init];
    
    BDRSACryptorKeyPair *RSAKeyPair = [RSACryptor generateKeyPairWithKeyIdentifier:@"key_pair_tag"
                                                                             error:error];
    
    NSDictionary *dict = @{@"privateKey":RSAKeyPair.privateKey, @"publicKey":RSAKeyPair.publicKey};
    return dict;
}


- (id)encrypt:(id)args {
    
    ENSURE_SINGLE_ARG(args,NSDictionary);
    NSDictionary *dict = (NSDictionary*) args;
    
    
    BDError *error = [[BDError alloc] init];
    BDRSACryptor *RSACryptor = [[BDRSACryptor alloc] init];
    BDRSACryptorKeyPair *RSAKeyPair = [[BDRSACryptorKeyPair alloc] initWithPublicKey:dict[@"publicKey"]
                                                                          privateKey:dict[@"privateKey"]];
    
    NSString *cipherText =
    [RSACryptor encrypt:dict[@"plainText"]
                    key:RSAKeyPair.publicKey
                  error:error];
    return cipherText;
    
}

- (id)decrypt:(id)args {
    
    ENSURE_SINGLE_ARG(args,NSDictionary);
    NSDictionary *dict = (NSDictionary*) args;
    
    
    BDError *error = [[BDError alloc] init];
    BDRSACryptor *RSACryptor = [[BDRSACryptor alloc] init];
    BDRSACryptorKeyPair *RSAKeyPair = [[BDRSACryptorKeyPair alloc] initWithPublicKey:dict[@"publicKey"]
                                                                          privateKey:dict[@"privateKey"]];
    
    NSString *plainText =
    [RSACryptor decrypt:dict[@"cipherText"]
                    key:RSAKeyPair.privateKey
                  error:error];
    return plainText;
}



/*

- (void)encryptionCycleWithRSACryptor:(BDRSACryptor *)RSACryptor
                              keyPair:(BDRSACryptorKeyPair *)RSAKeyPair
                                error:(BDError *)error
{
    NSString *cipherText =
    [RSACryptor encrypt:@"Plain Text"
                    key:RSAKeyPair.publicKey
                  error:error];
    
    BDDebugLog(@"Cipher Text:\n%@", cipherText);
    
    NSString *recoveredText =
    [RSACryptor decrypt:cipherText
                    key:RSAKeyPair.privateKey
                  error:error];
    
    BDDebugLog(@"Recovered Text:\n%@", recoveredText);
}
*/




@end
