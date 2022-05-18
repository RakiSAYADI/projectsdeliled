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
int stringCheckForEncryption(char *input);

esp_aes_context ctxEncode;
esp_aes_context ctxDecode;

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
    printf("Text to crypt : %s\n", plaintext);

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

    esp_aes_init(&ctxEncode);
    esp_aes_setkey(&ctxEncode, (unsigned char *)key, 256);
    esp_aes_crypt_cbc(&ctxEncode, ESP_AES_ENCRYPT, stringCheckForEncryption(plaintext), (unsigned char *)enc_iv, (uint8_t *)plaintext, (uint8_t *)encrypted);
    esp_aes_free(&ctxEncode);

    // Initialize the output hex String
    memset(encryptedHex, 0, sizeof(encryptedHex));

    // Converting ascii string to hex string
    string2hexString(encrypted, encryptedHex);

    printf("Text after crypt hex : %s\n", encryptedHex);
}

void decodeAESCBC()
{
    // Initialize the output String
    memset(encrypted, 0, sizeof(encrypted));

    printf("Text after crypt hex : %s\n", encryptedHex);

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

    esp_aes_init(&ctxDecode);
    esp_aes_setkey(&ctxDecode, (unsigned char *)key, 256);
    esp_aes_crypt_cbc(&ctxDecode, ESP_AES_DECRYPT, stringCheckForEncryption(encrypted), (unsigned char *)dec_iv, (uint8_t *)encrypted, (uint8_t *)plaintext);
    esp_aes_free(&ctxDecode);

    printf("Text after decrypt : %s\n", plaintext);
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
        i += 2;
    }
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

int stringCheckForEncryption(char *input)
{
    int lengthInput = strlen(input);
    if (lengthInput % 16)
    {
        while (lengthInput % 16)
            lengthInput++;

        return lengthInput;
    }
    else
        return lengthInput;
}