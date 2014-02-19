# TiRSA

TiRSA is a simple titanium module to create RSA keypairs and en- and decrypt text. 
It simply wraps this Project https://github.com/kuapay/iOS-Certificate--Key--and-Trust-Sample-Project

# Usuage

## Adding the module 

Add 
```
<module platform="iphone" version="1.0">ti.rsa</module>
```
to the modules tag in tiapp.xml in your Project Folder

##Example Code

```
var rsa = require('ti.rsa');

var keyPair = rsa.generateKeyPair();

var cipherText = rsa.encrypt({
	plainText: "Hello World",
	publicKey: keyPair.publicKey
});
Ti.API.info("cipherText: " + cipherText);

var plainText = rsa.decrypt({
	cipherText: cipherText,
	privateKey: keyPair.privateKey
});

Ti.API.info("plainText: " + plainText);
```