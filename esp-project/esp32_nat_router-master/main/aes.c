#include "esp_log.h"
#include "mbedtls/aes.h"
#include "esp_system.h"
#include <stdio.h>
#include <string.h>

#include "aes.h"

const char *AES_TAG = "AES";

int hex_to_int(char c);
int hex_to_ascii(char c, char d);
void string2hexString(char *input, char *output);
void hexstring2String(char *input, char *output);
int stringCheckForEncryption(char *input);
char *removeWhiteSpaces(char *str);

const char key[32] = "12345678901234567890123456789012";

esp_aes_context ctxEncode;
esp_aes_context ctxDecode;

char plaintext[1024];
char encrypted[2048];
char encryptedHex[4096];

void setTextToEncrypt(char *input)
{
    memset(plaintext, 0, sizeof(plaintext));
    sprintf(plaintext, input);
}

void setTextToDecrypt(char *input)
{
    memset(encryptedHex, 0, sizeof(encryptedHex));
    sprintf(encryptedHex, input);
}

void encodeAESCBC()
{
    printf("Text to crypt : %s\n", plaintext);

    char enc_iv[16] = "1234567890123456";

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

    // Verify output
    /*for (int i = 0; i < 128; i++)
    {
        printf("%02x[%c]%c", encrypted[i], (encrypted[i] > 31) ? encrypted[i] : ' ', ((i & 0xf) != 0xf) ? ' ' : '\n');
    }
    printf("\n");*/
}

void decodeAESCBC()
{
    // Initialize the output String
    memset(encrypted, 0, sizeof(encrypted));

    printf("Text after crypt hex : %s\n", encryptedHex);

    char dec_iv[16] = "1234567890123456";

    // Converting hex string to ascii string
    hexstring2String(encryptedHex, encrypted);

    // Initialize the output String
    memset(plaintext, 0, sizeof(plaintext));

    esp_aes_init(&ctxDecode);
    esp_aes_setkey(&ctxDecode, (unsigned char *)key, 256);
    esp_aes_crypt_cbc(&ctxDecode, ESP_AES_DECRYPT, strlen(encrypted), (unsigned char *)dec_iv, (uint8_t *)encrypted, (uint8_t *)plaintext);
    esp_aes_free(&ctxDecode);

    removeWhiteSpaces(plaintext);

    printf("Text after crypt : %s\n", plaintext);
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

char *removeWhiteSpaces(char *str)
{
    int i = 0, j = 0;
    while (str[i])
    {
        if (str[i] != ' ')
            str[j++] = str[i];
        i++;
    }
    str[j] = '\0';
    return str;
}