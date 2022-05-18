#ifndef MAIN_AES_H_
#define MAIN_AES_H_

#define KEY_AES "12345678901234567890123456789012"
#define IV_AES "1234567890123456"

#define SIZEFACTOR 4
#define TEXTSIZE (16 * 16) * SIZEFACTOR

void setTextToEncrypt(const char *input);
void setTextToDecrypt(const char *input);

extern char plaintext[TEXTSIZE];
extern char encrypted[sizeof(plaintext) * 2];
extern char encryptedHex[sizeof(plaintext) * 4];

#endif /* MAIN_AES_H_ */