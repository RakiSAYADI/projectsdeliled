#ifndef MAIN_AES_H_
#define MAIN_AES_H_

#define KEY_AES "12345678901234567890123456789012"
#define IV_AES  "1234567890123456"

void setTextToEncrypt(const char *input);
void setTextToDecrypt(const char *input);
void encodeAESCBC();
void decodeAESCBC();

extern char plaintext[1024];
extern char encrypted[2048];
extern char encryptedHex[4096];

#endif /* MAIN_AES_H_ */