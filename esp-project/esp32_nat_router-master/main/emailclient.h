/*
 * emailclient.h
 *
 *  Created on: Nov 19, 2019
 *      Author: raki
 */

#ifndef MAIN_EMAILCLIENT_H_
#define MAIN_EMAILCLIENT_H_

#include "mbedtls/platform.h"
#include "mbedtls/base64.h"
#include "mbedtls/net.h"
#include "mbedtls/debug.h"
#include "mbedtls/ssl.h"
#include "mbedtls/entropy.h"
#include "mbedtls/ctr_drbg.h"
#include "mbedtls/error.h"
#include "mbedtls/certs.h"

unsigned char buf_shake[1024];
uint32_t flags_shake;

char rndstr[13];
char buf[512];
unsigned char msgbuf[1024 *2];
unsigned char base[1024];
size_t n;

mbedtls_entropy_context entropy;
mbedtls_ctr_drbg_context ctr_drbg;
mbedtls_ssl_context ssl;
mbedtls_x509_crt cacert;
mbedtls_ssl_config conf;
mbedtls_net_context server_fd;

void emailClient();

extern bool sendEmailClient;

#endif /* MAIN_EMAILCLIENT_H_ */
