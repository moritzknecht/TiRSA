// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// open a single window
var win = Ti.UI.createWindow({
	backgroundColor: 'white'
});

win.open();

var rsa = require('ti.rsa');
var keyPair = rsa.generateKeyPair();
//Ti.API.info("keyPair: "+JSON.stringify(keyPair, undefined, 2));

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