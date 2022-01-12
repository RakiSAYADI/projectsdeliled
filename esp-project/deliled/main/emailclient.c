/*
 * emailclient.c
 *
 *  Created on: Nov 19, 2019
 *      Author: raki
 */
#include <string.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_wifi.h"
#include "esp_event_loop.h"
#include "esp_log.h"
#include "esp_system.h"
#include "nvs_flash.h"

#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include "lwip/netdb.h"
#include "lwip/dns.h"

#include "mbedtls/platform.h"
#include "mbedtls/base64.h"
#include "mbedtls/net.h"
#include "mbedtls/debug.h"
#include "mbedtls/ssl.h"
#include "mbedtls/entropy.h"
#include "mbedtls/ctr_drbg.h"
#include "mbedtls/error.h"
#include "mbedtls/certs.h"

#include "webservice.h"
#include "sntp_client.h"
#include "emailclient.h"
#include "gatt_server.h"
#include "unitcfg.h"

/* Constants that aren't configurable in menuconfig */
#define SMTPS_SERVER "smtp.gmail.com"
#define SMTPS_PORT "465"
#define SMTPS_MAIL_FROM "delitech.alert@gmail.com"
#define SMTPS_USER "delitech.alert@gmail.com"
#define SMTPS_PWD "maestro_user"

const char *email_server_root_cert = "-----BEGIN CERTIFICATE-----\r\n"
		"MIID8DCCAtigAwIBAgIDAjqSMA0GCSqGSIb3DQEBCwUAMEIxCzAJBgNVBAYTAlVT\r\n"
		"MRYwFAYDVQQKEw1HZW9UcnVzdCBJbmMuMRswGQYDVQQDExJHZW9UcnVzdCBHbG9i\r\n"
		"YWwgQ0EwHhcNMTUwNDAxMDAwMDAwWhcNMTcxMjMxMjM1OTU5WjBJMQswCQYDVQQG\r\n"
		"EwJVUzETMBEGA1UEChMKR29vZ2xlIEluYzElMCMGA1UEAxMcR29vZ2xlIEludGVy\r\n"
		"bmV0IEF1dGhvcml0eSBHMjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB\r\n"
		"AJwqBHdc2FCROgajguDYUEi8iT/xGXAaiEZ+4I/F8YnOIe5a/mENtzJEiaB0C1NP\r\n"
		"VaTOgmKV7utZX8bhBYASxF6UP7xbSDj0U/ck5vuR6RXEz/RTDfRK/J9U3n2+oGtv\r\n"
		"h8DQUB8oMANA2ghzUWx//zo8pzcGjr1LEQTrfSTe5vn8MXH7lNVg8y5Kr0LSy+rE\r\n"
		"ahqyzFPdFUuLH8gZYR/Nnag+YyuENWllhMgZxUYi+FOVvuOAShDGKuy6lyARxzmZ\r\n"
		"EASg8GF6lSWMTlJ14rbtCMoU/M4iarNOz0YDl5cDfsCx3nuvRTPPuj5xt970JSXC\r\n"
		"DTWJnZ37DhF5iR43xa+OcmkCAwEAAaOB5zCB5DAfBgNVHSMEGDAWgBTAephojYn7\r\n"
		"qwVkDBF9qn1luMrMTjAdBgNVHQ4EFgQUSt0GFhu89mi1dvWBtrtiGrpagS8wDgYD\r\n"
		"VR0PAQH/BAQDAgEGMC4GCCsGAQUFBwEBBCIwIDAeBggrBgEFBQcwAYYSaHR0cDov\r\n"
		"L2cuc3ltY2QuY29tMBIGA1UdEwEB/wQIMAYBAf8CAQAwNQYDVR0fBC4wLDAqoCig\r\n"
		"JoYkaHR0cDovL2cuc3ltY2IuY29tL2NybHMvZ3RnbG9iYWwuY3JsMBcGA1UdIAQQ\r\n"
		"MA4wDAYKKwYBBAHWeQIFATANBgkqhkiG9w0BAQsFAAOCAQEACE4Ep4B/EBZDXgKt\r\n"
		"10KA9LCO0q6z6xF9kIQYfeeQFftJf6iZBZG7esnWPDcYCZq2x5IgBzUzCeQoY3IN\r\n"
		"tOAynIeYxBt2iWfBUFiwE6oTGhsypb7qEZVMSGNJ6ZldIDfM/ippURaVS6neSYLA\r\n"
		"EHD0LPPsvCQk0E6spdleHm2SwaesSDWB+eXknGVpzYekQVA/LlelkVESWA6MCaGs\r\n"
		"eqQSpSfzmhCXfVUDBvdmWF9fZOGrXW2lOUh1mEwpWjqN0yvKnFUEv/TmFNWArCbt\r\n"
		"F4mmk2xcpMy48GaOZON9muIAs0nH5Aqq3VuDx3CQRk6+0NtZlmwu9RY23nHMAcIS\r\n"
		"wSHGFg==\r\n"
		"-----END CERTIFICATE-----\r\n";

static const char *TAG = "Email_Client";

#ifdef MBEDTLS_DEBUG_C

#define MBEDTLS_DEBUG_LEVEL 4

/* mbedtls debug function that translates mbedTLS debug output
   to ESP_LOGx debug output.

   MBEDTLS_DEBUG_LEVEL 4 means all mbedTLS debug output gets sent here,
   and then filtered to the ESP logging mechanism.
*/
void mbedtls_debug(void *ctx, int level,
                     const char *file, int line,
                     const char *str)
{
    const char *MBTAG = "mbedtls";
    char *file_sep;

    /* Shorten 'file' from the whole file path to just the filename

       This is a bit wasteful because the macros are compiled in with
       the full _FILE_ path in each case.
    */
    file_sep = rindex(file, '/');
    if(file_sep)
        file = file_sep+1;

    switch(level) {
    case 1:
        ESP_LOGI(MBTAG, "%s:%d %s", file, line, str);
        break;
    case 2:
    	break;
    case 3:
        ESP_LOGD(MBTAG, "%s:%d %s", file, line, str);
        break;
    case 4:
        ESP_LOGV(MBTAG, "%s:%d %s", file, line, str);
        break;
    default:
        ESP_LOGE(MBTAG, "Unexpected log level %d: %s", level, str);
        break;
    }
    free(file_sep);
}

#endif

int do_handshake(mbedtls_ssl_context *ssl) {
	int ret;
	memset(buf_shake, 0, 1024);

	/*
	 * 4. Handshake
	 */
	ESP_LOGI(TAG, "  . Performing the SSL/TLS handshake...");

	while ((ret = mbedtls_ssl_handshake(ssl)) != 0) {
		if (ret != MBEDTLS_ERR_SSL_WANT_READ
				&& ret != MBEDTLS_ERR_SSL_WANT_WRITE) {
			ESP_LOGE(TAG,
					" failed\n  ! mbedtls_ssl_handshake returned %d: %s\n\n",
					ret, buf_shake);
			return (-1);
		}
	}

	ESP_LOGI(TAG, " ok\n    [ Ciphersuite is %s ]\n",
			mbedtls_ssl_get_ciphersuite(ssl));

	/*
	 * 5. Verify the server certificate
	 */
	ESP_LOGI(TAG, "  . Verifying peer X.509 certificate...");

	/* In real life, we probably want to bail out when ret != 0 */
	if ((flags_shake = mbedtls_ssl_get_verify_result(ssl)) != 0) {
		char vrfy_buf[512];

		ESP_LOGE(TAG, " failed\n");

		mbedtls_x509_crt_verify_info(vrfy_buf, sizeof(vrfy_buf), "  ! ",
				flags_shake);

		ESP_LOGE(TAG, "%s\n", vrfy_buf);
	} else {
		ESP_LOGI(TAG, " ok\n");
	}

	ESP_LOGI(TAG, "  . Peer certificate information    ...\n");
	mbedtls_x509_crt_info((char *) buf_shake, sizeof(buf_shake) - 1, "      ",
			mbedtls_ssl_get_peer_cert(ssl));
	ESP_LOGI(TAG, "%s\n", buf_shake);
	return (0);
}

int write_ssl_data(mbedtls_ssl_context *ssl, unsigned char *buf, size_t len) {
	int ret;

	ESP_LOGV(TAG, "mbedtls_ssl_write [%s]", buf);
	while (len && (ret = mbedtls_ssl_write(ssl, buf, len)) <= 0) {
		if (ret != MBEDTLS_ERR_SSL_WANT_READ
				&& ret != MBEDTLS_ERR_SSL_WANT_WRITE) {
			ESP_LOGE(TAG, " failed\n  ! mbedtls_ssl_write returned %d\n\n",
					ret);
			return -1;
		}
	}

	return (0);
}

unsigned char data[128];
char code[4];

int write_ssl_and_get_response(mbedtls_ssl_context *ssl, unsigned char *buf,
		size_t len) {
	int ret;
	size_t i, idx = 0;
	ESP_LOGI(TAG, "mbedtls_ssl_write [%s]", buf);
	while (len && (ret = mbedtls_ssl_write(ssl, buf, len)) <= 0) {
		if (ret != MBEDTLS_ERR_SSL_WANT_READ
				&& ret != MBEDTLS_ERR_SSL_WANT_WRITE) {
			ESP_LOGE(TAG, " failed\n  ! mbedtls_ssl_write returned %d\n\n",
					ret);
			return -1;
		}
	}

	do {
		len = sizeof(data) - 1;
		memset(data, 0, sizeof(data));
		ret = mbedtls_ssl_read(ssl, data, len);

		if (ret == MBEDTLS_ERR_SSL_WANT_READ
				|| ret == MBEDTLS_ERR_SSL_WANT_WRITE)
			continue;

		if (ret == MBEDTLS_ERR_SSL_PEER_CLOSE_NOTIFY)
			return -1;

		if (ret <= 0) {
			ESP_LOGE(TAG, "failed\n  ! mbedtls_ssl_read returned %d\n\n", ret);
			return -1;
		}

		ESP_LOGI(TAG, "mbedtls_ssl_read [%s]\n", data);
		len = ret;
		for (i = 0; i < len; i++) {
			if (data[i] != '\n') {
				if (idx < 4)
					code[idx++] = data[i];
				continue;
			}

			if (idx == 4 && code[0] >= '0' && code[0] <= '9'
					&& code[3] == ' ') {
				code[3] = '\0';
				return atoi(code);
			}

			idx = 0;
		}
	} while (1);
}

char dt[64];
struct tm timeinfo = { 0 };
time_t tm = 0;
uint8_t mac[6];
uint8_t rnd[6];

void Task_emailclient(void *pvParameters) {
	if (WifiConnectedFlag) {

		int ret, flags, len;

		ESP_LOGI(TAG, "Email task started");

		mbedtls_ssl_init(&ssl);
		mbedtls_x509_crt_init(&cacert);
		mbedtls_ctr_drbg_init(&ctr_drbg);

		ESP_LOGI(TAG, "Seeding the random number generator");

		mbedtls_ssl_config_init(&conf);

		mbedtls_entropy_init(&entropy);

		if ((ret = mbedtls_ctr_drbg_seed(&ctr_drbg, mbedtls_entropy_func,
				&entropy,
				NULL, 0)) != 0) {
			ESP_LOGE(TAG, "mbedtls_ctr_drbg_seed returned %d", ret);
			abort();
		}

		ESP_LOGI(TAG, "Loading the CA root certificate...");

		ret = mbedtls_x509_crt_parse(&cacert, (uint8_t*) email_server_root_cert,
				strlen(email_server_root_cert) + 1);

		if (ret < 0) {
			ESP_LOGE(TAG, "mbedtls_x509_crt_parse returned -0x%x\n\n", -ret);
			abort();
		}

		ESP_LOGI(TAG, "Setting hostname for TLS session...");

		/* Hostname set here should match CN in server certificate */
		if ((ret = mbedtls_ssl_set_hostname(&ssl, SMTPS_SERVER)) != 0) {
			ESP_LOGE(TAG, "mbedtls_ssl_set_hostname returned -0x%x", -ret);
			abort();
		}

		ESP_LOGI(TAG, "Setting up the SSL/TLS structure...");

		if ((ret = mbedtls_ssl_config_defaults(&conf, MBEDTLS_SSL_IS_CLIENT,
				MBEDTLS_SSL_TRANSPORT_STREAM, MBEDTLS_SSL_PRESET_DEFAULT))
				!= 0) {
			ESP_LOGE(TAG, "mbedtls_ssl_config_defaults returned %d", ret);
			goto exit;
		}

		/* MBEDTLS_SSL_VERIFY_OPTIONAL is bad for security, in this example it will print
		 a warning if CA verification fails but it will continue to connect.

		 You should consider using MBEDTLS_SSL_VERIFY_REQUIRED in your own code.
		 */
		mbedtls_ssl_conf_authmode(&conf, MBEDTLS_SSL_VERIFY_OPTIONAL);
		mbedtls_ssl_conf_ca_chain(&conf, &cacert, NULL);
		mbedtls_ssl_conf_rng(&conf, mbedtls_ctr_drbg_random, &ctr_drbg);
#ifdef MBEDTLS_DEBUG_C
		mbedtls_debug_set_threshold(MBEDTLS_DEBUG_LEVEL);
		mbedtls_ssl_conf_dbg(&conf, mbedtls_debug, NULL);
	#endif

		if ((ret = mbedtls_ssl_setup(&ssl, &conf)) != 0) {
			ESP_LOGE(TAG, "mbedtls_ssl_setup returned -0x%x\n\n", -ret);
			goto exit;
		}

		mbedtls_net_init(&server_fd);

		ESP_LOGI(TAG, "Connecting to %s:%s...", SMTPS_SERVER, SMTPS_PORT);

		if ((ret = mbedtls_net_connect(&server_fd, SMTPS_SERVER,
		SMTPS_PORT, MBEDTLS_NET_PROTO_TCP)) != 0) {
			ESP_LOGE(TAG, "mbedtls_net_connect returned -%x", -ret);
			goto exit;
		}

		ESP_LOGI(TAG, "Connected.");

		mbedtls_ssl_set_bio(&ssl, &server_fd, mbedtls_net_send,
				mbedtls_net_recv, NULL);

		ESP_LOGI(TAG, "Performing the SSL/TLS handshake...");

		while ((ret = mbedtls_ssl_handshake(&ssl)) != 0) {
			if (ret != MBEDTLS_ERR_SSL_WANT_READ
					&& ret != MBEDTLS_ERR_SSL_WANT_WRITE) {
				ESP_LOGE(TAG, "mbedtls_ssl_handshake returned -0x%x", -ret);
				goto exit;
			}
		}

		ESP_LOGI(TAG, "Verifying peer X.509 certificate...");

		if ((flags = mbedtls_ssl_get_verify_result(&ssl)) != 0) {
			//In real life, we probably want to close connection if ret != 0
			ESP_LOGW(TAG, "Failed to verify peer certificate!");
			bzero(buf, sizeof(buf));
			mbedtls_x509_crt_verify_info(buf, sizeof(buf), "  ! ", flags);
			ESP_LOGW(TAG, "verification info: %s", buf);
		} else {
			ESP_LOGI(TAG, "Certificate verified.");
		}

		if (do_handshake(&ssl) != 0)
			goto exit;

		ESP_LOGI(TAG, "  > Get header from server:");
		fflush( stdout);

		ret = write_ssl_and_get_response(&ssl, msgbuf, 0);
		if (ret < 200 || ret > 299) {
			ESP_LOGE(TAG, " failed\n  ! server responded with %d\n\n", ret);
			goto exit;
		}

		ESP_LOGI(TAG, " ok");

		//writing hello message and reading response (ESMTP reference)

		ESP_LOGI(TAG, "  > Write EHLO to server:");
		fflush( stdout);

		len = sprintf((char *) msgbuf, "EHLO ESP32\r\n");
		ret = write_ssl_and_get_response(&ssl, msgbuf, len);
		if (ret < 200 || ret > 299) {
			ESP_LOGE(TAG, " failed\n  ! server responded with %d\n\n", ret);
			goto exit;
		}

		ESP_LOGI(TAG, "  > Write AUTH LOGIN to server:");

		len = sprintf((char *) msgbuf, "AUTH LOGIN\r\n");
		ret = write_ssl_and_get_response(&ssl, msgbuf, len);
		if (ret < 200 || ret > 399) {
			ESP_LOGE(TAG, " failed\n  ! server responded with %d\n\n", ret);
			goto exit;
		}

		ESP_LOGI(TAG, " ok");

		//writing username and reading response

		ESP_LOGI(TAG, "  > Write username to server");
		ESP_LOGV(TAG, "%s", SMTPS_USER);

		ret = mbedtls_base64_encode(base, sizeof(base), &n,
				(const unsigned char *) SMTPS_USER, strlen( SMTPS_USER));

		if (ret != 0) {
			ESP_LOGE(TAG, " failed\n  ! mbedtls_base64_encode returned %d\n\n",
					ret);
			goto exit;
		}
		len = sprintf((char *) msgbuf, "%s\r\n", base);
		ESP_LOGI(TAG, "  > Write base64 username to server: %s", msgbuf);
		ret = write_ssl_and_get_response(&ssl, msgbuf, len);
		if (ret < 300 || ret > 399) {
			ESP_LOGE(TAG, " failed\n  ! server responded with %d\n\n", ret);
			goto exit;
		}

		ESP_LOGI(TAG, " ok");

		//writing password and reading response

		ESP_LOGI(TAG, "  > Write password to server");
		ESP_LOGV(TAG, "%s", SMTPS_PWD);

		ret = mbedtls_base64_encode(base, sizeof(base), &n,
				(const unsigned char *) SMTPS_PWD, strlen( SMTPS_PWD));

		if (ret != 0) {
			ESP_LOGE(TAG, " failed\n  ! mbedtls_base64_encode returned %d\n\n",
					ret);
			goto exit;
		}
		len = sprintf((char *) msgbuf, "%s\r\n", base);
		ESP_LOGI(TAG, "  > Write base64 password to server: %s", msgbuf);
		ret = write_ssl_and_get_response(&ssl, msgbuf, len);
		if (ret < 200 || ret > 399) {
			ESP_LOGE(TAG, " failed\n  ! server responded with %d\n\n", ret);
			goto exit;
		}

		ESP_LOGI(TAG, " ok");

		//writing MAIL FROM and reading response

		ESP_LOGI(TAG, "  > Write MAIL FROM to server:");

		len = sprintf((char *) msgbuf, "MAIL FROM:<%s>\r\n", SMTPS_MAIL_FROM);
		ret = write_ssl_and_get_response(&ssl, msgbuf, len);
		if (ret < 200 || ret > 299) {
			ESP_LOGE(TAG, " failed\n  ! server responded with %d\n\n", ret);
			goto exit;
		}

		ESP_LOGI(TAG, " ok");

		//writing RCPT TO and reading response

		ESP_LOGI(TAG, "  > Write RCPT TO to server:");

		len = sprintf((char *) msgbuf, "RCPT TO:<%s>\r\n", UnitCfg.Email);
		ret = write_ssl_and_get_response(&ssl, msgbuf, len);
		if (ret < 200 || ret > 299) {
			ESP_LOGE(TAG, " failed\n  ! server responded with %d\n\n", ret);
			goto exit;
		}

		ESP_LOGI(TAG, " ok");

		//writing DATA and reading response

		ESP_LOGI(TAG, "  > Write DATA to server:");

		len = sprintf((char *) msgbuf, "DATA\r\n");
		ret = write_ssl_and_get_response(&ssl, msgbuf, len);
		if (ret < 300 || ret > 399) {
			ESP_LOGE(TAG, " failed\n  ! server responded with %d\n\n", ret);
			goto exit;
		}

		ESP_LOGI(TAG, " ok");

		esp_efuse_mac_get_default(mac);
		esp_fill_random(&rnd, 6);

		time(&tm);
		localtime_r(&tm, &timeinfo);
		strftime(dt, sizeof(dt), "%c", &timeinfo);

		ESP_LOGI(TAG, "  > Write content to server:");

		if (TestorAlert) {
			len =
					sprintf((char *) msgbuf,
							"Date : %s +1100\r\n"
									"To: <%s> \r\n"
									"From: Delitech Email Service  <%s> \r\n"
									"Message-ID: <%08lX-%04X-%04X-%04X-%s@rfcpedant.example.org>\r\n"
									"Subject: Application Notif. Email test [%s] \r\n"
									"\r\n" // empty line to divide headers from body, see RFC5322
									"Bonjour,\r\n"
									"Cet email vous a été envoyé pour donner suite à votre demande sur l’application Lumi’Air. \r\n"
									"Si la qualité de votre air venait à se détériorer, vous recevrez un nouveau message. \r\n"
									"Merci d’utiliser l’application Lumi’Air. \r\n"
									"\r\n"
									"Ce message vous a été envoyé automatiquement, merci de ne pas y répondre. \r\n"
									"\r\n"
									"Cordialement, \r\n"
									"Votre boitier Lumi’Air de Maestro™. \r\n"
									"\r\n", dt, UnitCfg.Email, SMTPS_MAIL_FROM,
							tm, mac[5] * 256 + mac[4], mac[3] * 256 + mac[2],
							mac[1] * 256 + mac[0], rndstr, UnitCfg.UnitName);
		} else {
			len =
					sprintf((char *) msgbuf,
							"Date : %s +1100\r\n"
									"To: %s \r\n"
									"From: Delitech Email Service <%s> \r\n"
									"Message-ID: <%08lX-%04X-%04X-%04X-%s@rfcpedant.example.org>\r\n"
									"Subject: Alerte niveau de CO2 [%s] \r\n"
									"\r\n" // empty line to divide headers from body, see RFC5322
									"Votre boitier [%s] vous informe qu’un taux de CO2 élevé a été détecté. \r\n"
									"La valeur de CO2 relevée est la suivante : %d \r\n"
									"\r\n"
									"Il est préférable d’aérer les zones dont le niveau de CO2 est trop élevé. \r\n"
									"\r\n"
									"Ce message vous a été envoyé automatiquement, merci de ne pas y répondre.\r\n"
									"\r\n"
									"Cordialement, \r\n"
									"Votre boitier Lumi’Air de Maestro™. \r\n"
									"\r\n", dt, UnitCfg.Email, SMTPS_MAIL_FROM,
							tm, mac[5] * 256 + mac[4], mac[3] * 256 + mac[2],
							mac[1] * 256 + mac[0], rndstr, UnitCfg.UnitName,
							UnitCfg.UnitName, UnitData.aq_Co2Level);
		}

		if (detection_test) {
			len =
					sprintf((char *) msgbuf,
							"Date : %s +1100\r\n"
									"To: %s \r\n"
									"From: Delitech Email Service <%s> \r\n"
									"Message-ID: <%08lX-%04X-%04X-%04X-%s@rfcpedant.example.org>\r\n"
									"Subject: Alerte detection mouvement [%s] \r\n"
									"\r\n" // empty line to divide headers from body, see RFC5322
									"Votre boitier [%s] vous informe qu’un mouvement  a été détecté à (%s) \r\n"
									"\r\n"
									"Ce message vous a été envoyé automatiquement, merci de ne pas y répondre.\r\n"
									"\r\n"
									"Cordialement, \r\n"
									"Votre boitier Lumi’Air de Maestro™. \r\n"
									"\r\n", dt, UnitCfg.Email, SMTPS_MAIL_FROM,
							tm, mac[5] * 256 + mac[4], mac[3] * 256 + mac[2],
							mac[1] * 256 + mac[0], rndstr, UnitCfg.UnitName,
							UnitCfg.UnitName, dt);
		}

		ret = write_ssl_data(&ssl, msgbuf, len);

		len = sprintf((char *) msgbuf, "\r\n.\r\n");
		ret = write_ssl_and_get_response(&ssl, msgbuf, len);
		if (ret < 200 || ret > 299) {
			ESP_LOGE(TAG, " failed\n  ! server responded with %d\n\n", ret);
			goto exit;
		}
		ret = 0;
		ESP_LOGI(TAG, " ok");

		//writing QUIT and reading response

		ESP_LOGI(TAG, "  > Write QUIT to server:");

		len = sprintf((char *) msgbuf, "QUIT\r\n");
		ret = write_ssl_and_get_response(&ssl, msgbuf, len);
		if (ret < 300 || ret > 399) {
			ESP_LOGE(TAG, " failed\n  ! server responded with %d\n\n", ret);
			goto exit;
		}

		ESP_LOGI(TAG, " ok");

		mbedtls_ssl_close_notify(&ssl);
		exit: {
			mbedtls_ctr_drbg_free(&ctr_drbg);
			mbedtls_x509_crt_free(&cacert);
			mbedtls_ssl_config_free(&conf);
			mbedtls_entropy_free(&entropy);
			mbedtls_ssl_session_reset(&ssl);
			mbedtls_ssl_free(&ssl);
			mbedtls_net_free(&server_fd);
			if (ret != 0) {

				mbedtls_strerror(ret, buf, 100);
				ESP_LOGE(TAG, "Last error was: -0x%x - %s", -ret, buf);
			}
			vTaskDelay(1000 / portTICK_RATE_MS);
			ESP_LOGI(TAG, "Done EMAILING !");
			TestorAlert = false;
			if (!test_security) {
				vTaskDelay(300000 / portTICK_RATE_MS);
				test_security = true;
			}

			detection_test = false;
		};
	} else {
		ESP_LOGE(TAG, "No internet connection to send Emails");
	}
	vTaskDelete(NULL);
}

