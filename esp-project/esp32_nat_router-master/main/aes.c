#include "esp_log.h"
#include "mbedtls/aes.h"
#include "esp_system.h"
#include <stdio.h>
#include <string.h>

#include "aes.h"

const char *AES_TAG = "AES";

void encodeAESCBC();
void decodeAESCBC();
int hex_to_int(char c);
int hex_to_ascii(char c, char d);
char *removeWhiteSpaces(char *str);
void string2hexString(char *input, char *output);
void hexstring2String(char *input, char *output);
void stringCheckForEncryption(char *input);

mbedtls_aes_context ctxEncode;
mbedtls_aes_context ctxDecode;

char plaintext[TEXTSIZE];
char encrypted[sizeof(plaintext) * 2];
char encryptedHex[sizeof(plaintext) * 4];

void setTextToEncrypt(const char *input)
{
    memset(plaintext, 0, sizeof(plaintext));
    sprintf(plaintext, input);
    encodeAESCBC();
}

void setTextToDecrypt(const char *input)
{
    memset(encryptedHex, 0, sizeof(encryptedHex));
    sprintf(encryptedHex, input);
    decodeAESCBC();
}

void encodeAESCBC()
{
    // printf("Text to crypt : %s\n", plaintext);

    char enc_iv[17] = IV_AES;
    char key[33] = KEY_AES;

    memset(key, 0, sizeof(key));
    memset(enc_iv, 0, sizeof(enc_iv));
    uint8_t mac[6];
    esp_efuse_mac_get_default(mac);
    sprintf(enc_iv, "DL%02X%02X%02X%02X%02X%02XFR", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);

    uint8_t macWIFI[6];
    esp_read_mac(macWIFI, ESP_MAC_ETH);
    sprintf(key, "DELI%02X%02X%02X%02X%02X%02XLE%02X%02X%02X%02X%02X%02XFR",
            mac[0], mac[1], mac[2], mac[3], mac[4], mac[5], macWIFI[0], macWIFI[1], macWIFI[2], macWIFI[3], macWIFI[4], macWIFI[5]);

    // Initialize the output String
    memset(encrypted, 0, sizeof(encrypted));

    // Initialize the output hex String
    memset(encryptedHex, 0, sizeof(encryptedHex));

    stringCheckForEncryption(plaintext);

    string2hexString(plaintext, encryptedHex);

    mbedtls_aes_init(&ctxEncode);
    mbedtls_aes_setkey_enc(&ctxEncode, (unsigned char *)key, 256);
    int result = mbedtls_aes_crypt_cbc(&ctxEncode,
                                       MBEDTLS_AES_DECRYPT,
                                       strlen(encryptedHex),
                                       (unsigned char *)enc_iv,
                                       (uint8_t *)encryptedHex,
                                       (uint8_t *)encrypted);
    mbedtls_aes_free(&ctxEncode);

    // Converting ascii string to hex string
    string2hexString(encrypted, encryptedHex);

    // printf("Text after crypt result %d text %s\n", result, encryptedHex);
}

void decodeAESCBC()
{
    // Initialize the output String
    memset(encrypted, 0, sizeof(encrypted));

    // printf("Text after crypt hex : %s\n", encryptedHex);

    char dec_iv[17] = IV_AES;
    char key[33] = KEY_AES;

    memset(key, 0, sizeof(key));
    memset(dec_iv, 0, sizeof(dec_iv));
    uint8_t mac[6];
    esp_efuse_mac_get_default(mac);
    sprintf(dec_iv, "DL%02X%02X%02X%02X%02X%02XFR", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);

    uint8_t macWIFI[6];
    esp_read_mac(macWIFI, ESP_MAC_ETH);
    sprintf(key, "DELI%02X%02X%02X%02X%02X%02XLE%02X%02X%02X%02X%02X%02XFR",
            mac[0], mac[1], mac[2], mac[3], mac[4], mac[5], macWIFI[0], macWIFI[1], macWIFI[2], macWIFI[3], macWIFI[4], macWIFI[5]);

    // Converting hex string to ascii string
    hexstring2String(encryptedHex, encrypted);

    // Initialize the output String
    memset(plaintext, 0, sizeof(plaintext));

    mbedtls_aes_init(&ctxDecode);
    mbedtls_aes_setkey_dec(&ctxDecode, (unsigned char *)key, 256);
    int result = mbedtls_aes_crypt_cbc(&ctxDecode,
                                       MBEDTLS_AES_DECRYPT,
                                       strlen(encrypted),
                                       (unsigned char *)dec_iv,
                                       (uint8_t *)encrypted,
                                       (uint8_t *)plaintext);
    mbedtls_aes_free(&ctxDecode);

    // printf("Text after decrypt result %d : %s\n", result, plaintext);
}

int hex_to_int(char c)
{
    int first = c / 16 - 3;
    int second = c % 16;
    int result = first * 10 + second;
    if (result > 9)
        result--;
    return result;
}

int hex_to_ascii(char c, char d)
{
    int high = hex_to_int(c) * 16;
    int low = hex_to_int(d);
    return high + low;
}

void string2hexString(char *input, char *output)
{
    int i = 0;
    for (int loop = 0; loop < strlen(input); loop++)
    {
        sprintf((char *)(output + i), "%02X", input[loop]);
        // printf("%c %02X\n", input[loop], input[loop]);
        i += 2;
    }
    // printf("END conversion \ninput : %s size %d \noutput : %s \n", input, strlen(input), output);
}

void hexstring2String(char *input, char *output)
{
    int i = 0, j = 0;
    char buf = 0;
    for (i = 0; i < strlen(input); i++)
    {
        if (i % 2 != 0)
        {
            sprintf((char *)(output + j), "%c", hex_to_ascii(buf, input[i]));
            j++;
        }
        else
        {
            buf = input[i];
        }
    }
}

void stringCheckForEncryption(char *input)
{
    int lengthInput = strlen(input);
    if (lengthInput % 16)
    {
        while (lengthInput % 16)
        {
            strcat(input, "0");
            lengthInput = strlen(input);
        }
    }
}