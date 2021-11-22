/* BSD Socket API Example

 This example code is in the Public Domain (or CC0 licensed, at your option.)

 Unless required by applicable law or agreed to in writing, this
 software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 CONDITIONS OF ANY KIND, either express or implied.
 */
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "freertos/portmacro.h"
#include "freertos/event_groups.h"
#include "sys/errno.h"
#include "cJSON.h"

#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include "lwip/netdb.h"
#include "lwip/dns.h"
#include "lwip/api.h"

#include "sdkconfig.h"

const char *payload = "Message from CLIENT";

#include "main.h"

/* Constants that aren't configurable in menuconfig */
#define TCP_SERVER "192.168.1.1"
#define TCP_PORT 80

const char *TCP_CLIENT_TAG = "TCP_CLIENT";

const char *TCP_OK = "TCP OK";

EventGroupHandle_t wifi_event_group_client;
const int CONNECTED_BIT_CLIENT = BIT0;
wifi_mode_t wifi_mode_client;

// modification for testing

void udp_client_task(void *pvParameters);

bool SlaveTaskState;

TaskHandle_t xSlaveTask;

//

esp_err_t event_handler_client(void *ctx, system_event_t *event) {
	switch (event->event_id) {
	case SYSTEM_EVENT_STA_START: {
		esp_wifi_connect();
		break;
	}
	case SYSTEM_EVENT_STA_GOT_IP: {
		xEventGroupSetBits(wifi_event_group_client, CONNECTED_BIT_CLIENT);
		ESP_LOGI(TCP_CLIENT_TAG, "Got IP");
		ESP_LOGI(TCP_CLIENT_TAG, "IP: %s\r",
				ip4addr_ntoa(&event->event_info.got_ip.ip_info.ip));
		ESP_LOGI(TCP_CLIENT_TAG, "MASK: %s\r",
				ip4addr_ntoa(&event->event_info.got_ip.ip_info.netmask));
		ESP_LOGI(TCP_CLIENT_TAG, "GATEWAY: %s\r",
				ip4addr_ntoa(&event->event_info.got_ip.ip_info.gw));

		// modification for testing

		delay(1000);

		/* Start the http client */
		xTaskCreate(udp_client_task, "udp_client_task", 4096, NULL, 5,
				&xSlaveTask);

		//

		break;
	}
	case SYSTEM_EVENT_STA_DISCONNECTED: {
		xEventGroupClearBits(wifi_event_group_client, CONNECTED_BIT_CLIENT);
		ESP_LOGI(TCP_CLIENT_TAG, "retry to connect to the AP");

		// modification for testing

		if (SlaveTaskState) {
			ESP_LOGI(TCP_CLIENT_TAG, "the task is dying now ! ");
			vTaskDelete(xSlaveTask);
			SlaveTaskState = false;
		}

		esp_wifi_connect();

		if (UVTreatementIsOn) {
			stopIsPressed = true;
		}
		break;
	}
	default:
		break;
	}
	return ESP_OK;
}

#include "driver/gpio.h"

struct sockaddr_in dest_addr;

char addr_str[128];
int addr_family;
int ip_protocol;
int sock;

void CheckingPressence(void *pvParameters) {
	while (1) {
		if (UVTreatementIsOn) {

			if (detectionTriggered) {
				char* UVDetection;

				UVDetection = malloc(50);

				memset(UVDetection, 0, 50);

				sprintf(UVDetection, "Detection : 1");

				int err = sendto(sock, UVDetection, strlen(UVDetection), 0,
						(struct sockaddr * )&dest_addr, sizeof(dest_addr));
				if (err < 0) {
					ESP_LOGE(TCP_CLIENT_TAG,
							"Error occurred during sending: errno %d", errno);
					free(UVDetection);
					break;
				}
				ESP_LOGI(TCP_CLIENT_TAG, "Sending Successful");
				free(UVDetection);
				break;
			}
		} else {
			break;
		}
		delay(100);
	}
	vTaskDelete(NULL);
}

void udp_client_task(void *pvParameters) {

	SlaveTaskState = true;

	while (1) {

		dest_addr.sin_addr.s_addr = inet_addr(TCP_SERVER);
		dest_addr.sin_family = AF_INET;
		dest_addr.sin_port = htons(TCP_PORT);
		addr_family = AF_INET;
		ip_protocol = IPPROTO_IP;
		inet_ntoa_r(dest_addr.sin_addr, addr_str, sizeof(addr_str) - 1);

		sock = socket(addr_family, SOCK_DGRAM, ip_protocol);
		if (sock < 0) {
			ESP_LOGE(TCP_CLIENT_TAG, "Unable to create socket: errno %d",
					errno);
			goto OUT;
		}
		ESP_LOGI(TCP_CLIENT_TAG, "Socket created, sending to %s:%d", TCP_SERVER,
				TCP_PORT);

//		struct timeval receiving_timeout;
//		receiving_timeout.tv_sec = 1;
//		receiving_timeout.tv_usec = 0;
//		if (setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &receiving_timeout,
//				sizeof(receiving_timeout)) < 0) {
//			ESP_LOGE(TCP_CLIENT_TAG,
//					"... failed to set socket receiving timeout");
//			goto OUT;
//		}
//
//		ESP_LOGI(TCP_CLIENT_TAG, "Timeout Successful");

		char rx_buffer[128];

		bool firstconnecting = true;

		while (1) {

			if (firstconnecting) {

				int err = sendto(sock, payload, strlen(payload), 0,
						(struct sockaddr * )&dest_addr, sizeof(dest_addr));
				if (err < 0) {
					ESP_LOGE(TCP_CLIENT_TAG,
							"Error occurred during sending: errno %d", errno);
					break;
				}
				ESP_LOGI(TCP_CLIENT_TAG, "Message sent");
				firstconnecting = false;
			} else {

				struct sockaddr_in source_addr; // Large enough for both IPv4 or IPv6
				socklen_t socklen = sizeof(source_addr);
				int len = recvfrom(sock, rx_buffer, sizeof(rx_buffer) - 1, 0,
						(struct sockaddr * )&source_addr, &socklen);

				// Error occurred during receiving
				if (len < 0) {
					ESP_LOGE(TCP_CLIENT_TAG, "recvfrom failed: errno %d",
							errno);
					if (errno != 11) {
						goto Exit;
					}
				}
				// Data received
				else {
					rx_buffer[len] = 0; // Null-terminate whatever we received and treat like a string
					ESP_LOGI(TCP_CLIENT_TAG, "Received %d bytes from %s:", len,
							addr_str);
					ESP_LOGI(TCP_CLIENT_TAG, "%s", rx_buffer);

					if (strContains(rx_buffer, "UVC IS ON") == 1) {
						if(!UVCThreadState){
							UVCThreadState = true;
							xTaskCreate(&UVCTreatement, "UVCTreatement",
							configMINIMAL_STACK_SIZE * 3, NULL, 5,
							NULL);
						}
					}
					if (strContains(rx_buffer, "DisinfictionTime") == 1) {
						cJSON *messageJson, *DisinfictionTimeData,
								*ActivationTimeData;
						messageJson = cJSON_Parse(rx_buffer);
						DisinfictionTimeData = cJSON_GetObjectItemCaseSensitive(
								messageJson, "DisinfictionTime");
						ActivationTimeData = cJSON_GetObjectItemCaseSensitive(
								messageJson, "ActivationTime");
						UnitCfg.DisinfictionTime =
								DisinfictionTimeData->valueint;
						UnitCfg.ActivationTime = ActivationTimeData->valueint;
						cJSON_Delete(messageJson);
					}
					if (strContains(rx_buffer, "STOP UVC") == 1) {
						stopIsPressed = true;
					}
				}

				Exit:
				ESP_LOGI(TCP_CLIENT_TAG, "Reading again");
			}
		}
		OUT:
		ESP_LOGE(TCP_CLIENT_TAG, "Shutting down socket and restarting...");
		shutdown(sock, 0);
		close(sock);
		delay(100);
	}
	vTaskDelete(NULL);
}

void initialize_wifi_client(void) {

	ESP_LOGI(TCP_CLIENT_TAG, "WIFI CLIENT TASK START");

	tcpip_adapter_init();
	wifi_event_group_client = xEventGroupCreate();
	ESP_ERROR_CHECK(esp_event_loop_init(event_handler_client, NULL));

	wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT()
	;
	ESP_ERROR_CHECK(esp_wifi_init(&cfg));
	ESP_ERROR_CHECK(esp_wifi_set_storage(WIFI_STORAGE_RAM));
	ESP_ERROR_CHECK(esp_wifi_set_mode(wifi_mode_client));

	wifi_config_t conf = { .sta = { .ssid = SSIDNAME, .password = PASSWORD,
			.bssid_set = false } };

	ESP_ERROR_CHECK(esp_wifi_set_config(ESP_IF_WIFI_STA, &conf));
	ESP_ERROR_CHECK(esp_wifi_start());

}

void wifiConnectionClient() {
	ESP_LOGI(TCP_CLIENT_TAG, "WIFI TASK START");

	/* Start the wifi user */
	wifi_mode_client = WIFI_MODE_STA;
	initialize_wifi_client();

	ESP_LOGI(TCP_CLIENT_TAG, "THIS IS SLAVE");
}
