#ifndef MAIN_AES_H_
#define MAIN_AES_H_

void encodeAESCBC();
void decodeAESCBC();

extern char plaintext[1024];
extern char encrypted[1024];
extern char encryptedHex[1024];

#endif /* MAIN_AES_H_ */