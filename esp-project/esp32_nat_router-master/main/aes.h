#ifndef MAIN_AES_H_
#define MAIN_AES_H_

void setTextToEncrypt(char *input);
void setTextToDecrypt(char *input);
void encodeAESCBC();
void decodeAESCBC();

extern char plaintext[1024];
extern char encrypted[2048];
extern char encryptedHex[4096];

#endif /* MAIN_AES_H_ */