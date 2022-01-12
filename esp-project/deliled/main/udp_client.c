/* BSD Socket API Example

 This example code is in the Public Domain (or CC0 licensed, at your option.)

 Unless required by applicable law or agreed to in writing, this
 software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 CONDITIONS OF ANY KIND, either express or implied.
 */
#include <string.h>
#include <sys/param.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "tcpip_adapter.h"
#include "cJSON.h"

#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include <lwip/netdb.h>

#include "sys/errno.h"

#include "mbedtls/aes.h"
#include "mbedtls/md5.h"

#include "sdkconfig.h"
#include "unitcfg.h"
#include "webservice.h"

static const char *TAG = "UDP_CLIENT";
const char *payload = "$discover baillindustrie\r\n";
const char *GET = "GET infos?flags=1 HTTP/1.1\r\n";
char* REQUET;

char rx_buffer[1024];
unsigned char key[16];
char addr_str[128];
int addr_family;
int ip_protocol;
int sock;

mbedtls_aes_context enc_ctx;
mbedtls_aes_context dec_ctx;

void hex_print(const void* pv, size_t len) {
	const unsigned char * p = (const unsigned char*) pv;
	if (NULL == pv)
		printf("NULL");
	else {
		size_t i = 0;
		for (; i < len; ++i)
			printf("%02X", *p++);
	}
	printf("\n");
}

int hex_to_int(char c) {
	int first = c / 16 - 3;
	int second = c % 16;
	int result = first * 10 + second;
	if (result > 9)
		result--;
	return result;
}

int hex_to_ascii(char c, char d) {
	int high = hex_to_int(c) * 16;
	int low = hex_to_int(d);
	return high + low;
}

unsigned char buf[16];
int i, j;
int count = 0;
int times;
unsigned char buf_out[17];
uint32_t buffer_size = 0;
char our_text[sizeof((rx_buffer)) * 2];
char buffer;
int length;

void aes_crypt() {
	//cryptage

	mbedtls_aes_init(&enc_ctx);

	ESP_LOGI(TAG, "[APP] Free memory: %d bytes", esp_get_free_heap_size());

	sprintf(rx_buffer,
			"{ \"connected\":1, \"rq_type\":1, \"tick\":232352, \"flags\":12, \"th1\":{ \"sp_ht1\":%1.0f } }",
			UnitData.Temp * 10);

	//sprintf(rx_buffer,"{\"connected\":1,\"mac\":\"D88039D99AA4\",\"dt\":{\"date\":20190429,\"time\":10503400},\"mbus\":1,\"uc\":{\"mode\":2,\"cool_mode\":1},\"ui\":{\"on\":1,\"mode\":4,\"sp\":225,\"rt\":230,\"fan\":2,\"error\":0,\"dev_id\":7936,\"dev_ver\":1},\"th1\":{\"on\":1,\"temp\":254,\"sp\":225,\"dn\":1,\"zone\":1,\"motor\":4,\"vbat\":28}}00");

	mbedtls_aes_setkey_enc(&enc_ctx, key, 128);

	memset(buf_out, 0, 17);

	ESP_LOGI(TAG, "avant encryption: %s", rx_buffer);

	if (strlen((char*) (rx_buffer)) % 16 == 0) {
		times = (int) (strlen((char*) (rx_buffer)) / 16);
	} else {
		times = (int) (strlen((char*) (rx_buffer)) / 16) + 1;
	}

	j = 0;

	memset(buf, 0, 16);

	memset(our_text, 0, sizeof(our_text));

	unsigned char * p;

	size_t is = 0;

	for (i = 0; i < sizeof(rx_buffer); i++) {
		if (times == count) {
			break;
		}
		if (j == 16 && (!(strlen((char*) buf) == 0))) {
			mbedtls_aes_crypt_ecb(&enc_ctx, MBEDTLS_AES_ENCRYPT, buf, buf_out);
			p = (unsigned char*) buf_out;
			for (is = 0; is < sizeof(buf_out) - 1; ++is) {
				sprintf(our_text + buffer_size + (is * 2), "%02X", *p);
				p++;
			}
			buffer_size += 32;
			memset(buf, 0, 16);
			memset(buf_out, 0, 17);
			count++;
			j = 0;
		}
		buf[j] = rx_buffer[i];
		j++;
	}

	mbedtls_aes_free(&enc_ctx);

	ESP_LOGI(TAG, "le message apres encryption:%s", (char* )our_text);
}

void aes_dec() {
	//decryptage

	mbedtls_aes_init(&dec_ctx);

	mbedtls_aes_setkey_dec(&dec_ctx, key, 128);

	memset(rx_buffer, 0, sizeof(rx_buffer));

	if (strlen((char*) (our_text)) % 32 == 0) {
		times = (int) (strlen(our_text) / 32);
	} else {
		times = (int) (strlen(our_text) / 32) + 1;
	}

	memset(buf_out, 0, 17);

	memset(buf, 0, 16);

	count = 0;
	j = 0;
	i = 0;

	buffer = 0;

	buffer_size = 0;

	length = strlen(our_text);

	char our_text_ascii[strlen((char*) (our_text)) + 1];

	for (i = 0; i < length; i++) {
		if (i % 2 != 0) {
			sprintf(our_text_ascii + j, "%c",
					hex_to_ascii(buffer, our_text[i]));
			j++;
		} else {
			buffer = our_text[i];
		}
	}

	j = 0;

	for (i = 0; i < sizeof(our_text_ascii); i++) {
		if (times == count) {
			break;
		}
		if (j == 16 && (!(strlen((char*) buf) == 0))) {
			mbedtls_aes_crypt_ecb(&dec_ctx, MBEDTLS_AES_DECRYPT, buf, buf_out);
			memcpy(rx_buffer + buffer_size, buf_out, strlen((char*) buf_out));
			buffer_size += strlen((char*) buf_out);
			memset(buf, 0, 16);
			memset(buf_out, 0, 17);
			count++;
			j = 0;
		}
		buf[j] = (unsigned char) our_text_ascii[i];
		j++;
	}

	j = 0;
	count = 0;
	j = 0;
	i = 0;

	buffer_size = 0;

	ESP_LOGI(TAG, "après encryption: %s", rx_buffer);

	mbedtls_aes_free(&dec_ctx);

	ESP_LOGI(TAG, "[APP] Free memory: %d bytes", esp_get_free_heap_size());

}

unsigned char buf_md5_in[512] =
		"{ \"connected\":1, \"rq_type\":1, \"tick\":232352, \"flags\":12, \"th1\":{ \"sp_ht1\":225 } }";

unsigned char buf_md5_out[16];

char md5_out[32];

void hmac_crypt() {
	mbedtls_md5_ret(buf_md5_in, sizeof(buf_md5_in), buf_md5_out);

	unsigned char * p_md5;

	p_md5 = (unsigned char*) buf_md5_out;

	for (int is_md5 = 0; is_md5 < sizeof(buf_md5_out); ++is_md5) {
		sprintf(md5_out + (is_md5 * 2), "%02X", *p_md5);
		p_md5++;
	}
}

void udp_app_start() {

	/*memset(key, 0, 16);

	 memcpy(key, "IND88039D99AA4DU", 16);

	 aes_crypt();

	 hmac_crypt();

	 printf("le md5 is : %s\n",(char *)md5_out);

	 aes_dec();

	 aes_crypt();

	 aes_dec();*/

	if (UnitCfg.UDPConfig.Enable) {
		ESP_LOGI(TAG, "udp send task start");

		char txt[256];

		uint8_t mac[6];
		char mactxt[20];
		esp_efuse_mac_get_default(mac);
		sprintf(mactxt, "%02X%02X%02X%02X%02X%02X", mac[0], mac[1], mac[2],
				mac[3], mac[4], mac[5]);

		sprintf(txt,
				"{\"uid\":\"%s\",\"data\":[%ld,%0.1f,%0.1f,%d,%d,%d,%d,%ld]}",
				mactxt, UnitData.UpdateTime, UnitData.Temp, UnitData.Humidity,
				UnitData.Als, UnitData.aq_Co2Level, UnitData.aq_Tvoc,
				UnitData.aq_status, UnitData.LastDetTime);

		if (!UnitCfg.UDPConfig.ipv4_ipv6) {
			// IPV4
			ESP_LOGI(TAG, "IPV4 selected");
			struct sockaddr_in dest_addr;
			dest_addr.sin_addr.s_addr = inet_addr(UnitCfg.UDPConfig.Server);
			dest_addr.sin_family = AF_INET;
			dest_addr.sin_port = htons(UnitCfg.UDPConfig.Port);
			addr_family = AF_INET;
			ip_protocol = IPPROTO_IP;
			inet_ntoa_r(dest_addr.sin_addr, addr_str, sizeof(addr_str) - 1);
			sock = socket(addr_family, SOCK_DGRAM, ip_protocol);
			if (sock < 0) {
				ESP_LOGE(TAG, "Unable to create socket: errno %d", errno);
			}
			ESP_LOGI(TAG, "Socket created, sending to %s:%d",
					UnitCfg.UDPConfig.Server, UnitCfg.UDPConfig.Port);
			int err = sendto(sock, txt, strlen(txt), 0,
					(struct sockaddr * )&dest_addr, sizeof(dest_addr));

			if (err < 0) {
				ESP_LOGE(TAG, "Error occurred during sending: errno %d", errno);
			}

			err = send(sock, txt, strlen(txt), 0);

			if (err < 0) {
				ESP_LOGE(TAG, "Error occurred during sending: errno %d", errno);
			}
			ESP_LOGI(TAG, "Message sent");

		} else {
			// IPV6
			ESP_LOGI(TAG, "IPV6 selected");
			struct sockaddr_in6 dest_addr;
			inet6_aton(UnitCfg.UDPConfig.Server, &dest_addr.sin6_addr);
			dest_addr.sin6_family = AF_INET6;
			dest_addr.sin6_port = htons(UnitCfg.UDPConfig.Port);
			addr_family = AF_INET6;
			ip_protocol = IPPROTO_IPV6;
			inet6_ntoa_r(dest_addr.sin6_addr, addr_str, sizeof(addr_str) - 1);
			sock = socket(addr_family, SOCK_DGRAM, ip_protocol);
			if (sock < 0) {
				ESP_LOGE(TAG, "Unable to create socket: errno %d", errno);
			}
			ESP_LOGI(TAG, "Socket created, sending to %s:%d",
					UnitCfg.UDPConfig.Server, UnitCfg.UDPConfig.Port);

			struct timeval receiving_timeout;
			receiving_timeout.tv_sec = 5;
			receiving_timeout.tv_usec = 0;
			if (setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &receiving_timeout,
					sizeof(receiving_timeout)) < 0) {
				ESP_LOGE(TAG, "... failed to set socket receiving timeout");
				close(sock);
			}

			int err = sendto(sock, txt, strlen(txt), 0,
					(struct sockaddr * )&dest_addr, sizeof(dest_addr));

			if (err < 0) {
				ESP_LOGE(TAG, "Error occurred during sending: errno %d", errno);
			}

			err = send(sock, txt, strlen(txt), 0);

			if (err < 0) {
				ESP_LOGE(TAG, "Error occurred during sending: errno %d", errno);
			}
			ESP_LOGI(TAG, "Message sent");

		}
		/*
		 struct sockaddr_in source_addr; // Large enough for both IPv4 or IPv6
		 socklen_t socklen = sizeof(source_addr);
		 int len = recvfrom(sock, rx_buffer, sizeof(rx_buffer) - 1, 0, (struct sockaddr *)&source_addr, &socklen);

		 // Error occurred during receiving
		 if (len < 0) {
		 ESP_LOGE(TAG, "recvfrom failed: errno %d", errno);
		 }
		 // Data received
		 else {
		 rx_buffer[len] = 0; // Null-terminate whatever we received and treat like a string
		 ESP_LOGI(TAG, "Received %d bytes from %s:", len, addr_str);
		 ESP_LOGI(TAG, "%s", rx_buffer);

		 cJSON *json = cJSON_Parse(rx_buffer);

		 if(json == NULL) ESP_LOGE(TAG,"this is not json message...");
		 else
		 {

		 cJSON *man = 	cJSON_GetObjectItemCaseSensitive(json, "man");
		 cJSON *name = 	 cJSON_GetObjectItemCaseSensitive(json, "name");
		 cJSON *sn = 	 cJSON_GetObjectItemCaseSensitive(json, "sn");
		 cJSON *mac = 	 cJSON_GetObjectItemCaseSensitive(json, "mac");
		 cJSON *ip = 	 cJSON_GetObjectItemCaseSensitive(json, "ip");
		 cJSON *srv_port = 	 cJSON_GetObjectItemCaseSensitive(json, "srv_port");

		 if((cJSON_IsString(man) && (man->valuestring != NULL))&&(cJSON_IsString(name) && (name->valuestring != NULL))&&(cJSON_IsString(sn) && (sn->valuestring != NULL))
		 &&(cJSON_IsString(mac) && (mac->valuestring != NULL))&&(cJSON_IsString(ip) && (ip->valuestring != NULL))&&(cJSON_IsNumber(srv_port)))
		 {

		 ESP_LOGI(TAG, "From man received %s", man->valuestring);
		 ESP_LOGI(TAG, "From name received %s", name->valuestring);
		 ESP_LOGI(TAG, "From sn received %s", sn->valuestring);
		 ESP_LOGI(TAG, "From mac received %s", mac->valuestring);
		 ESP_LOGI(TAG, "From ip received %s", ip->valuestring);
		 ESP_LOGI(TAG, "From srv_port received %d", srv_port->valueint);

		 shutdown(sock, 0);
		 close(sock);

		 char addr_strs[128];
		 int addr_familys;
		 int ip_protocols;

		 int errc;
		 int socks;

		 struct sockaddr_in dest_addrs;
		 dest_addrs.sin_addr.s_addr = inet_addr(ip->valuestring);
		 dest_addrs.sin_family = AF_INET;
		 dest_addrs.sin_port = htons((uint16_t)srv_port->valueint);
		 addr_familys = AF_INET;
		 ip_protocols = IPPROTO_IP;
		 inet_ntoa_r(dest_addrs.sin_addr, addr_strs, sizeof(addr_strs) - 1);

		 socks =  socket(addr_familys, SOCK_STREAM, ip_protocols);

		 if (socks < 0) {
		 ESP_LOGE(TAG, "Unable to create socket: errno %d", errno);
		 }
		 ESP_LOGI(TAG, "Socket created, connecting to %s:%d", ip->valuestring, srv_port->valueint);

		 errc= connect(socks, (struct sockaddr *)&dest_addrs, sizeof(dest_addrs));
		 if (errc != 0) {
		 ESP_LOGE(TAG, "Socket unable to connect: errno %d", errno);
		 }
		 ESP_LOGI(TAG, "Successfully connected");

		 REQUET=malloc(sizeof(our_text));

		 cJSON_Delete(json);

		 while(1)
		 {
		 int err = send(socks, GET, strlen(GET), 0);
		 if (err < 0) {
		 ESP_LOGE(TAG, "Error occurred during sending: errno %d", errno);
		 break;
		 }

		 len= recv(socks, rx_buffer, sizeof(rx_buffer) - 1, 0);
		 // Error occurred during receiving
		 if (len < 0) {
		 ESP_LOGE(TAG, "recv failed: errno %d", errno);
		 break;
		 }
		 // Data received
		 else {
		 rx_buffer[len] = 0; // Null-terminate whatever we received and treat like a string
		 ESP_LOGI(TAG, "Received %d bytes from %s:", len, addr_strs);
		 ESP_LOGI(TAG, "%s", rx_buffer);
		 }
		 memset(key,0,16);

		 memcpy(key,"IND88039D99AA4DU",16);

		 mbedtls_aes_init(&enc_ctx);

		 sprintf(rx_buffer,"{ \"connected\":1, \"rq_type\":1, \"tick\":232352, \"flags\":12, \"th1\":{ \"sp_ht1\":%1.0f } }",UnitData.Temp*10);

		 aes_crypt();

		 mbedtls_aes_free(&enc_ctx);

		 memset(REQUET,0,sizeof(our_text));

		 sprintf(REQUET,"POST infos HTTP/1.1\r\n"
		 "Content-Length: %d\r\n"
		 "Baillconnect-Hmac: %s\r\n"
		 "\r\n"
		 "%s",strlen((char*)rx_buffer),(char*)buf_md5_out,rx_buffer);

		 err = send(socks, REQUET, strlen(REQUET), 0);
		 if (err < 0) {
		 ESP_LOGE(TAG, "Error occurred during sending: errno %d", errno);
		 break;
		 }

		 len= recv(socks, rx_buffer, sizeof(rx_buffer) - 1, 0);
		 // Error occurred during receiving
		 if (len < 0) {
		 ESP_LOGE(TAG, "recv failed: errno %d", errno);
		 break;
		 }
		 // Data received
		 else {
		 rx_buffer[len] = 0; // Null-terminate whatever we received and treat like a string
		 ESP_LOGI(TAG, "Received %d bytes from %s:", len, addr_strs);
		 ESP_LOGI(TAG, "%s", rx_buffer);
		 }

		 memset(REQUET,0,sizeof(our_text));

		 vTaskDelay(10000 / portTICK_PERIOD_MS);
		 }
		 if (socks != -1) {
		 ESP_LOGE(TAG, "Shutting down socket ...");
		 shutdown(socks, 0);
		 close(socks);
		 }
		 }
		 else ESP_LOGE(TAG, "your respond is wrong , who are you ?");
		 }

		 }*/
		if (sock != -1) {
			ESP_LOGE(TAG, "Shutting down socket ...");
			shutdown(sock, 0);
			close(sock);
		}
	}
	vTaskDelete(NULL);
}
