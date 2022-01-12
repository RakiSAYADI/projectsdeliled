/*
 * ftc_client.c
 *
 *  Created on: Dec 26, 2018
 *      Author: mdt
 */

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_log.h"
#include "driver/uart.h"
#include "driver/gpio.h"
#include "soc/uart_struct.h"
#include "string.h"
#include <stdio.h>
#include <string.h>
#include <freertos/FreeRTOS.h>
#include <freertos/task.h>
#include <esp_log.h>
#include <esp_err.h>
#include <esp_system.h>
#include <esp_event_loop.h>
#include "esp_wifi.h"
#include <nvs.h>
#include <nvs_flash.h>
#include <driver/gpio.h>
#include <tcpip_adapter.h>
#include "sdkconfig.h"
#include "esp_system.h"
#include "stdlib.h"
#include "stdbool.h"

#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include <lwip/netdb.h>
#include <ctype.h>

#include "webservice.h"
#include "unitcfg.h"
#include "sntp_client.h"
#include "sdkconfig.h"

#include "sys/errno.h"

#define TAG "FTP_CLIENT"

char *ftp_buffer;
uint32_t ftp_buffer_size = 0;

bool curlTaskEnb = false;
void FTP_task();
void sending_ftp();

#define FTP_BUFFER_SIZE 1500000

char fulladd[100];

struct tm now_ftp = { 0 };
struct tm trigtimeinfo_ftp = { 0 };

uint32_t trigparttime;
uint32_t cparttime;

struct timeval tv;

uint32_t timeout;

char udt[64];
char ldt[64];

void ftp_task() {
	if ((UnitCfg.FtpConfig.FtpLogEnb)) {
		char txt[256];
		uint8_t mac[6];
		char mactxt[20];

		ESP_LOGI(TAG, "ftp task Started");

		esp_efuse_mac_get_default(mac);
		sprintf(mactxt, "%02X%02X%02X%02X%02X%02X", mac[0], mac[1], mac[2],
				mac[3], mac[4], mac[5]);

		heap_caps_malloc_extmem_enable(100);

		ftp_buffer = malloc(FTP_BUFFER_SIZE);

		memset(ftp_buffer, 0, FTP_BUFFER_SIZE);

		if (ftp_buffer == NULL) {
			ESP_LOGE(TAG, "Buffer malloc error ... Halt");
			vTaskDelete(NULL);
		} else
			ESP_LOGI(TAG, "Buffer malloc %d bytes OK", FTP_BUFFER_SIZE);

		sprintf(ftp_buffer,
				"MAC ;Update time (with timestamp) ;Temperature(C) ;Humidity(percent) ;ALS(Lux) ;CO2(ppm) ;TVOC(ppb) ;AQ Status ;Last detection time (with timestamp)\n");

		ftp_buffer_size = strlen(ftp_buffer);

		xTaskCreatePinnedToCore(&sending_ftp, "sending_ftp", 2050, NULL, 5,
				NULL, 1);

		while (1) {
			if (UnitCfg.FtpConfig.FtpLogEnb == true) {
				time(&UnitData.UpdateTime);

				localtime_r(&UnitData.UpdateTime, &sntp_timeinfo);
				strftime(udt, sizeof(udt), "%c", &sntp_timeinfo);

				localtime_r(&UnitData.LastDetTime, &sntp_timeinfo);
				strftime(ldt, sizeof(ldt), "%c", &sntp_timeinfo);

				sprintf(txt,
						"%s ;%s(%ld) ;%0.1f ;%0.1f ;%d ;%d ;%d ;%d ;%s(%ld)\n",
						mactxt, udt, UnitData.UpdateTime, UnitData.Temp,
						UnitData.Humidity, UnitData.Als, UnitData.aq_Co2Level,
						UnitData.aq_Tvoc, UnitData.aq_status, ldt,
						UnitData.LastDetTime);

				memcpy(ftp_buffer + ftp_buffer_size, txt, strlen(txt));

				ftp_buffer_size += strlen(txt);

				ESP_LOGI(TAG, "Added to buffer %d bytes, total %d bytes",
						strlen(txt), ftp_buffer_size);

			}
			vTaskDelay(10000 / portTICK_PERIOD_MS);
		}
	}
	vTaskDelete(NULL);
}

void sending_ftp() {
	while (1) {
		//ESP_LOGI(TAG,"Waiting For Time !");

		gmtime_r(&UnitCfg.FtpConfig.ftp_send, &trigtimeinfo_ftp);

		gettimeofday(&tv, NULL);

		localtime_r(&tv.tv_sec, &now_ftp);

		cparttime = now_ftp.tm_hour * 3600 + now_ftp.tm_min * 60
				+ now_ftp.tm_sec;

		trigparttime = trigtimeinfo_ftp.tm_hour * 3600
				+ trigtimeinfo_ftp.tm_min * 60 + trigtimeinfo_ftp.tm_sec;

		if (UnitCfg.FtpConfig.FtpTimeout_send == 0) {
			timeout = 60;
		}
		if (UnitCfg.FtpConfig.FtpTimeout_send == 1) {
			timeout = 120;
		}
		if (UnitCfg.FtpConfig.FtpTimeout_send == 2) {
			timeout = 300;
		}
		if (UnitCfg.FtpConfig.FtpTimeout_send == 3) {
			timeout = 600;
		}
		if (UnitCfg.FtpConfig.FtpTimeout_send == 4) {
			timeout = 900;
		}
		if (UnitCfg.FtpConfig.FtpTimeout_send == 5) {
			timeout = 1800;
		}
		if (UnitCfg.FtpConfig.FtpTimeout_send == 6) {
			timeout = 3600;
		}
		if (UnitCfg.FtpConfig.FtpTimeout_send == 7) {
			timeout = 7200;
		}
		if (UnitCfg.FtpConfig.FtpTimeout_send == 8) {
			timeout = 14400;
		}
		if (UnitCfg.FtpConfig.FtpTimeout_send == 9) {
			timeout = 21600;
		}
		if (UnitCfg.FtpConfig.FtpTimeout_send == 10) {
			timeout = 43200;
		}

		if (((!UnitCfg.FtpConfig.ftp_now_or_later && cparttime == trigparttime)
				|| (UnitCfg.FtpConfig.ftp_now_or_later
						&& (cparttime % timeout == 0)))
				&& (UnitCfg.FtpConfig.FtpLogEnb == true)) {
			ESP_LOGI(TAG, "Sending File %s_%s_%s.csv to server",
					UnitCfg.FtpConfig.Client_id, UnitCfg.UnitName, udt);

			sprintf(fulladd, "%s_%s_%s.csv", UnitCfg.FtpConfig.Client_id,
					UnitCfg.UnitName, udt);

			if (WifiConnectedFlag == false) {
				vTaskDelay(1000 / portTICK_PERIOD_MS);
				goto stop;
			}

			curlTaskEnb = true;

			xTaskCreatePinnedToCore(&FTP_task, "FTP_task", 3000, NULL, 4, NULL,
					1);

			//FTP_task();

			while (curlTaskEnb == true) {
				vTaskDelay(10 / portTICK_PERIOD_MS);
			}

			ESP_LOGI(TAG, "Clearing buffer");

			memset(ftp_buffer, 0, FTP_BUFFER_SIZE);

			ftp_buffer_size = 0;

			sprintf(ftp_buffer,
					"MAC ;Update time (with timestamp) ;Temperature(C) ;Humidity(percent) ;ALS(Lux) ;CO2(ppm) ;TVOC(ppb) ;AQ Status ;Last detection time (with timestamp)\n");

			ftp_buffer_size = strlen(ftp_buffer);

			stop: {
				ESP_LOGI(TAG, "ending the sending task !");
			};
		}
		if ((UnitCfg.FtpConfig.FtpLogEnb == false)) {
			ESP_LOGI(TAG, "Clearing buffer");

			memset(ftp_buffer, 0, FTP_BUFFER_SIZE);

			ftp_buffer_size = 0;

			sprintf(ftp_buffer,
					"MAC ;Update time (with timestamp) ;Temperature(C) ;Humidity(percent) ;ALS(Lux) ;CO2(ppm) ;TVOC(ppb) ;AQ Status ;Last detection time (with timestamp)\n");

			ftp_buffer_size = strlen(ftp_buffer);
		}
		vTaskDelay(1000 / portTICK_PERIOD_MS);
	}
	vTaskDelete(NULL);
}

struct WriteThis {
	const char *readptr;
	size_t sizeleft;
};

char recv_buf[128];

int socket_control, socket_data, reading;

char USER[100];

char PASSWORD[100];

char STORING[100];

char snum[5];

char *CHECKING_DIRECTORY = "PWD\r\n";

char *PASSIVE_MODE = "EPSV\r\n";

char *CHECKING_TYPE = "TYPE I\r\n";

char *QUIT = "QUIT\r\n";

char *subString; // the "result"

void FTP_task() {

	if (WifiConnectedFlag == false) {
		vTaskDelete(NULL);
	}

	struct WriteThis upload;

	upload.readptr = ftp_buffer;
	upload.sizeleft = ftp_buffer_size;

	ftp_buffer[ftp_buffer_size] = 0;

	const struct addrinfo hints = { .ai_family = AF_INET, .ai_socktype =
			SOCK_STREAM, };
	struct addrinfo *res;
	struct in_addr *addr;

	itoa(UnitCfg.FtpConfig.Port, snum, 10);

	sprintf(USER, "USER %s\r\n", UnitCfg.FtpConfig.UserName);

	sprintf(PASSWORD, "PASS %s\r\n", UnitCfg.FtpConfig.Password);

	sprintf(STORING, "STOR %s\r\n", fulladd);

	int err = getaddrinfo(UnitCfg.FtpConfig.Server, snum, &hints, &res);

	if (err != 0 || res == NULL) {
		ESP_LOGE(TAG, "DNS lookup failed err=%d res=%p", err, res);
		vTaskDelay(1000 / portTICK_PERIOD_MS);
	}

	/* Code to print the resolved IP.

	 Note: inet_ntoa is non-reentrant, look at ipaddr_ntoa_r for "real" code */

	addr = &((struct sockaddr_in *) res->ai_addr)->sin_addr;
	ESP_LOGI(TAG, "DNS lookup succeeded. IP=%s", inet_ntoa(*addr));

	socket_control = socket(res->ai_family, res->ai_socktype, 0);
	if (socket_control < 0) {
		ESP_LOGE(TAG, "... Failed to allocate socket.");
		freeaddrinfo(res);
		vTaskDelay(1000 / portTICK_PERIOD_MS);
		goto exit;
	}
	ESP_LOGI(TAG, "... allocated socket");

	if (connect(socket_control, res->ai_addr, res->ai_addrlen) != 0) {
		ESP_LOGE(TAG, "... socket connect failed errno=%d", errno);
		close(socket_control);
		freeaddrinfo(res);
		vTaskDelay(4000 / portTICK_PERIOD_MS);
		goto exit;
	}

	ESP_LOGI(TAG, "... connected");
	freeaddrinfo(res);

	struct timeval receiving_timeout;
	receiving_timeout.tv_sec = 3;
	receiving_timeout.tv_usec = 0;
	if (setsockopt(socket_control, SOL_SOCKET, SO_RCVTIMEO, &receiving_timeout,
			sizeof(receiving_timeout)) < 0) {
		ESP_LOGE(TAG, "... failed to set socket receiving timeout");
		close(socket_control);
		vTaskDelay(4000 / portTICK_PERIOD_MS);
		goto exit;
	}
	ESP_LOGI(TAG, "... set socket receiving timeout success");

	if (write(socket_control, USER, strlen(USER)) < 0) {
		ESP_LOGE(TAG, "... socket user send failed");
		close(socket_control);
		vTaskDelay(4000 / portTICK_PERIOD_MS);
		goto exit;
	}
	ESP_LOGI(TAG, "... socket user send success");

	if (write(socket_control, PASSWORD, strlen(PASSWORD)) < 0) {
		ESP_LOGE(TAG, "... socket password send failed");
		close(socket_control);
		vTaskDelay(4000 / portTICK_PERIOD_MS);
		goto exit;
	}
	ESP_LOGI(TAG, "... socket password send success");

	if (write(socket_control, CHECKING_DIRECTORY, strlen(CHECKING_DIRECTORY))
			< 0) {
		ESP_LOGE(TAG, "... socket checking the directory send failed");
		close(socket_control);
		vTaskDelay(4000 / portTICK_PERIOD_MS);
		goto exit;
	}
	/* Read HTTP response */
	do {
		bzero(recv_buf, sizeof(recv_buf));
		reading = read(socket_control, recv_buf, sizeof(recv_buf) - 1);
		for (int i = 0; i < reading; i++) {
			putchar(recv_buf[i]);
		}
	} while (reading > 0);

	ESP_LOGI(TAG, "... socket checking the directory send success");

	if (write(socket_control, PASSIVE_MODE, strlen(PASSIVE_MODE)) < 0) {
		ESP_LOGE(TAG, "... socket putting passive mode send failed");
		close(socket_control);
		vTaskDelay(4000 / portTICK_PERIOD_MS);
		goto exit;
	}
	ESP_LOGI(TAG, "... socket putting passive mode send success");

	/* Read HTTP response */
	do {
		reading = read(socket_control, recv_buf, sizeof(recv_buf) - 1);
		for (int i = 0; i < reading; i++) {
			putchar(recv_buf[i]);
		}
	} while (reading > 0);

	//strcpy(line, recv_buf);

	subString = strtok(recv_buf, "(|||"); // find the first double quote
	subString = strtok(NULL, "|)");   // find the second double quote

	printf("the passive mode port is : '%s'\n", subString);

	err = getaddrinfo(UnitCfg.FtpConfig.Server, subString, &hints, &res);

	if (err != 0 || res == NULL) {
		ESP_LOGE(TAG, "DNS lookup failed err=%d res=%p", err, res);
		vTaskDelay(1000 / portTICK_PERIOD_MS);
		goto exit;
	}

	//Code to print the resolved IP.

	// Note: inet_ntoa is non-reentrant, look at ipaddr_ntoa_r for "real" code
	addr = &((struct sockaddr_in *) res->ai_addr)->sin_addr;
	ESP_LOGI(TAG, "DNS lookup succeeded. IP=%s", inet_ntoa(*addr));

	socket_data = socket(res->ai_family, res->ai_socktype, 0);
	if (socket_data < 0) {
		ESP_LOGE(TAG, "... Failed to allocate socket.");
		freeaddrinfo(res);
		vTaskDelay(1000 / portTICK_PERIOD_MS);
		goto exit;
	}

	ESP_LOGI(TAG, "... allocated socket");

	if (connect(socket_data, res->ai_addr, res->ai_addrlen) != 0) {
		ESP_LOGE(TAG, "... socket connect failed errno=%d", errno);
		close(socket_data);
		freeaddrinfo(res);
		vTaskDelay(4000 / portTICK_PERIOD_MS);
		goto exit;
	}

	ESP_LOGI(TAG, "... connected");
	freeaddrinfo(res);

	if (write(socket_control, CHECKING_TYPE, strlen(CHECKING_TYPE)) < 0) {
		ESP_LOGE(TAG, "... socket checking type send failed");
		close(socket_control);
		vTaskDelay(4000 / portTICK_PERIOD_MS);
		goto exit;
	}
	ESP_LOGI(TAG, "... socket checking type send success");

	if (write(socket_control, STORING, strlen(STORING)) < 0) {
		ESP_LOGE(TAG, "... socket storing send failed");
		close(socket_control);
		vTaskDelay(4000 / portTICK_PERIOD_MS);
		goto exit;
	}

	ESP_LOGI(TAG, "... socket storing send success %s", STORING);

	if (write(socket_data, upload.readptr,(int)upload.sizeleft) < 0) {
		ESP_LOGE(TAG, "... socket uploading send failed");
		close(socket_data);
		vTaskDelay(4000 / portTICK_PERIOD_MS);
		goto exit;
	}
	ESP_LOGI(TAG, "... socket uploading send success");

	/* Read HTTP response */
	do {
		bzero(recv_buf, sizeof(recv_buf));
		reading = read(socket_control, recv_buf, sizeof(recv_buf) - 1);
		for (int i = 0; i < reading; i++) {
			putchar(recv_buf[i]);
		}
	} while (reading > 0);

	ESP_LOGI(TAG, "... done reading from socket. Last read return=%d errno=%d.",
			reading, errno);

	if (write(socket_control, QUIT, strlen(QUIT)) < 0) {
		ESP_LOGE(TAG, "... socket quit send failed");
		close(socket_control);
		vTaskDelay(4000 / portTICK_PERIOD_MS);
		goto exit;
	}

	ESP_LOGI(TAG, "... socket quit send success");

	exit: {
		close(socket_control);
		close(socket_data);
		memset(recv_buf, 0, sizeof(recv_buf));
		subString = "";
	};

	vTaskDelay(1000 / portTICK_PERIOD_MS);

	ESP_LOGI(TAG, "Done UPLOADING !");

	curlTaskEnb = false;

	vTaskDelete(NULL);
}

