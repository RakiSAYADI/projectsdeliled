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
#include "freertos/portmacro.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "sdkconfig.h"
#include "sys/errno.h"

#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include <lwip/netdb.h>
#include "main.h"

#define PORT 80

const char *TCP_SERVER_TAG = "TCP_SERVER";

//const char *payload = "Message from SERVER ";
const char *UVCOrdreSlave = "UVC IS ON";
const char *stopUVCOrdreSlave = "STOP UVC";

EventGroupHandle_t wifi_event_group_server;
wifi_mode_t wifi_mode_server;

char addr_str[128];

esp_err_t event_handler_server(void *ctx, system_event_t *event) {
	ESP_LOGI(TCP_SERVER_TAG, "SYSTEM EVENT : %d", event->event_id);
	switch (event->event_id) {
	case SYSTEM_EVENT_AP_START:
		// AP has started up. Now start the DHCP server.
		ESP_LOGI(TCP_SERVER_TAG, "SYSTEM EVENT AP START");
		// Configure the IP address and DHCP server.
		tcpip_adapter_ip_info_t ipInfo;
		IP4_ADDR(&ipInfo.ip, 192, 168, 1, 1);
		IP4_ADDR(&ipInfo.gw, 192, 168, 1, 1);
		IP4_ADDR(&ipInfo.netmask, 255, 255, 255, 0);
		tcpip_adapter_dhcps_stop(TCPIP_ADAPTER_IF_AP);
		if (tcpip_adapter_set_ip_info(TCPIP_ADAPTER_IF_AP, &ipInfo) == ESP_OK) {
			ESP_LOGI(TCP_SERVER_TAG, "starting DHCP server");
			esp_err_t espResult;
			espResult = tcpip_adapter_dhcps_start(TCPIP_ADAPTER_IF_AP);
			if (espResult == ESP_OK) {
				ESP_LOGI(TCP_SERVER_TAG, "DHCP server is started !");
				return espResult;
			} else {
				ESP_LOGE(TCP_SERVER_TAG,
						"DHCP server is not started , err = %x", espResult);
				return espResult;
			}
		}
		break;
	case SYSTEM_EVENT_AP_STOP:
		// AP is STOPPING
		ESP_LOGI(TCP_SERVER_TAG, "SYSTEM EVENT AP STOP");
		break;
	case SYSTEM_EVENT_AP_STACONNECTED:
		// user is connected to the AP station
		ESP_LOGI(TCP_SERVER_TAG, "A USER IS CONNECTED");
		break;
	case SYSTEM_EVENT_AP_STADISCONNECTED:
		// user is disconnected from the AP station
		ESP_LOGI(TCP_SERVER_TAG, "A USER IS DISCONNECTED");
		break;
	default:
		break;
	}
	return ESP_OK;
}

struct sockaddr_in6 source_addr; // Large enough for both IPv4 or IPv6
bool DetectionOnSlave = false;
int slave_number = 1;

void SlaveTask(void *pvParameters) {
	const int sock = (int) pvParameters;
	struct sockaddr_in6 source_addr_slave = source_addr; // Large enough for both IPv4 or IPv6

	int slaveid = slave_number++;

	ESP_LOGI(TCP_SERVER_TAG, "Slave number = %d", slaveid);

	while (1) {
		if (UVTaskIsOn) {
			char* UVCData;

			stopIsPressed = false;

			delay(slaveid * 100);

			ESP_LOGI(TCP_SERVER_TAG, "UVC order to %d", slaveid);

			UVCData = malloc(100);

			memset(UVCData, 0, 100);

			sprintf(UVCData, "{\"DisinfictionTime\":%d,\"ActivationTime\":%d}",
					UnitCfg.DisinfictionTime, UnitCfg.ActivationTime);

			// send message to Slaves

			int err = sendto(sock, UVCData, strlen(UVCData), 0,
					(struct sockaddr * )&source_addr_slave,
					sizeof(source_addr_slave));
			if (err < 0) {
				ESP_LOGE(TCP_SERVER_TAG,
						"Error occurred during sending: errno %d", errno);
				break;
			}
			ESP_LOGI(TCP_SERVER_TAG, "Sending Successful time data");
			free(UVCData);

			// send message to Slaves

			err = sendto(sock, UVCOrdreSlave, strlen(UVCOrdreSlave), 0,
					(struct sockaddr * )&source_addr_slave,
					sizeof(source_addr_slave));

			if (err < 0) {
				ESP_LOGE(TCP_SERVER_TAG,
						"Error occurred during sending: errno %d", errno);
				break;
			}
			ESP_LOGI(TCP_SERVER_TAG, "Sending Successful uvc ordre");

			UVTaskIsOn = false;
		}

		if (DetectionOnSlave) {
			stopIsPressed = true;
			delay(slaveid * 100);
			DetectionOnSlave = false;
			detectionTriggered = true;
//			ESP_LOGI(TCP_SERVER_TAG, "Dectection slave order to %d", slaveid);
//
//			int err = sendto(sock, stopUVCOrdreSlave, strlen(stopUVCOrdreSlave),
//					0, (struct sockaddr * )&source_addr, sizeof(source_addr));
//
//			if (err < 0) {
//				ESP_LOGE(TCP_SERVER_TAG,
//						"Error occurred during sending: errno %d", errno);
//			}
//			ESP_LOGI(TCP_SERVER_TAG, "Sending detection message Successful");
			UVTaskIsOn = false;
		}
		if (detectionTriggered) {
			delay(slaveid * 100);
			ESP_LOGI(TCP_SERVER_TAG, "STOP order to %d", slaveid);
			int err = sendto(sock, stopUVCOrdreSlave, strlen(stopUVCOrdreSlave),
					0, (struct sockaddr * )&source_addr_slave,
					sizeof(source_addr_slave));

			if (err < 0) {
				ESP_LOGE(TCP_SERVER_TAG,
						"Error occurred during sending: errno %d", errno);
			}
			ESP_LOGI(TCP_SERVER_TAG, "Sending detection message Successful");
			delay(2000);
			detectionTriggered = false;
			UVTaskIsOn = false;
		}

		if (stopEventTrigerred) {
			stopIsPressed = true;
			delay(slaveid * 100);
			stopEventTrigerred = false;
			ESP_LOGI(TCP_SERVER_TAG, "STOP order to %d", slaveid);
			int err = sendto(sock, stopUVCOrdreSlave, strlen(stopUVCOrdreSlave),
					0, (struct sockaddr * )&source_addr_slave,
					sizeof(source_addr_slave));

			if (err < 0) {
				ESP_LOGE(TCP_SERVER_TAG,
						"Error occurred during sending: errno %d", errno);
			}
			ESP_LOGI(TCP_SERVER_TAG, "Sending stop message Successful");
			detectionTriggered = true;
			delay(2000);
			detectionTriggered = false;
			UVTaskIsOn = false;
		}

		//TEST of disconnecting
		if (errno != 11 && errno != 0) {
			printf("%d\n", errno);
			ESP_LOGE(TCP_SERVER_TAG, "Disconnecting Client");
			break;
		}
		delay(100);
	}
	vTaskDelete(NULL);
}

void udp_server_task(void *pvParameters) {

	int addr_family;
	int ip_protocol;

	while (1) {
		struct sockaddr_in dest_addr;
		dest_addr.sin_addr.s_addr = htonl(INADDR_ANY);
		dest_addr.sin_family = AF_INET;
		dest_addr.sin_port = htons(PORT);
		addr_family = AF_INET;
		ip_protocol = IPPROTO_IP;
		inet_ntoa_r(dest_addr.sin_addr, addr_str, sizeof(addr_str) - 1);

		int sock = socket(addr_family, SOCK_DGRAM, ip_protocol);
		if (sock < 0) {
			ESP_LOGE(TCP_SERVER_TAG, "Unable to create socket: errno %d",
					errno);
			goto OUT;
		}
		ESP_LOGI(TCP_SERVER_TAG, "Socket created");

		int err = bind(sock, (struct sockaddr * )&dest_addr, sizeof(dest_addr));
		if (err < 0) {
			ESP_LOGE(TCP_SERVER_TAG, "Socket unable to bind: errno %d", errno);
			goto OUT;
		}
		ESP_LOGI(TCP_SERVER_TAG, "Socket bound, port %d", PORT);

//		struct timeval receiving_timeout;
//		receiving_timeout.tv_sec = 5;
//		receiving_timeout.tv_usec = 0;
//		if (setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &receiving_timeout,
//				sizeof(receiving_timeout)) < 0) {
//			ESP_LOGE(TCP_SERVER_TAG,
//					"... failed to set socket receiving timeout");
//			goto OUT;
//		}
//
//		ESP_LOGI(TCP_SERVER_TAG, "Timeout Successful");

		char rx_buffer[128];

		while (1) {

			ESP_LOGI(TCP_SERVER_TAG, "Waiting for data from Esclave");
			socklen_t socklen = sizeof(source_addr);
			int len = recvfrom(sock, rx_buffer, sizeof(rx_buffer) - 1, 0,
					(struct sockaddr * )&source_addr, &socklen);

			// Error occurred during receiving
			if (len < 0) {
				if (errno == 11) {
					ESP_LOGI(TCP_SERVER_TAG, "Timeout on recieving");
				} else {
					ESP_LOGE(TCP_SERVER_TAG, "recvfrom failed: errno %d",
							errno);
				}
			}
			// Data received
			else {

				// Get the sender's ip address as string
				if (source_addr.sin6_family == PF_INET) {
					inet_ntoa_r(
							((struct sockaddr_in * )&source_addr)->sin_addr.s_addr,
							addr_str, sizeof(addr_str) - 1);
				} else if (source_addr.sin6_family == PF_INET6) {
					inet6_ntoa_r(source_addr.sin6_addr, addr_str,
							sizeof(addr_str) - 1);
				}

				rx_buffer[len] = 0; // Null-terminate whatever we received and treat like a string...
				ESP_LOGI(TCP_SERVER_TAG, "Received %d bytes from %s:", len,
						addr_str);
				ESP_LOGI(TCP_SERVER_TAG, "%s", rx_buffer);
				if (strContains(rx_buffer, "Detection : 1") == 1) {
					stopEventTrigerred = true;
				}
				if (strContains(rx_buffer, "Message from CLIENT") == 1) {
					xTaskCreate(SlaveTask, "SlaveTask", 4096, (void*) sock, 1,
					NULL);
				} else {
					ESP_LOGI(TCP_SERVER_TAG, "this is not the password");
				}
			}
			ESP_LOGI(TCP_SERVER_TAG, "Reading again");
		}

		OUT:
		ESP_LOGE(TCP_SERVER_TAG, "Shutting down socket and restarting...");
		shutdown(sock, 0);
		close(sock);
		delay(1000);
	}
	vTaskDelete(NULL);
}

void initialize_wifi_server(void) {

	ESP_LOGI(TCP_SERVER_TAG, "WIFI STATION TASK START");

	tcpip_adapter_init();
	wifi_event_group_server = xEventGroupCreate();
	ESP_ERROR_CHECK(esp_event_loop_init(event_handler_server, NULL));

	wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT()
	;
	ESP_ERROR_CHECK(esp_wifi_init(&cfg));
	ESP_ERROR_CHECK(esp_wifi_set_storage(WIFI_STORAGE_RAM));
	ESP_ERROR_CHECK(esp_wifi_set_mode(wifi_mode_server));

	wifi_config_t conf = { .ap = { .ssid = UVCROBOTNAME, .ssid_len = 14,
			.password = PASSWORD, .authmode = WIFI_AUTH_WPA2_PSK, .ssid_hidden =
					0, .max_connection = 5 } };

	ESP_ERROR_CHECK(esp_wifi_set_config(ESP_IF_WIFI_AP, &conf));
	ESP_ERROR_CHECK(esp_wifi_start());

}

void wifiConnectionServer() {
	ESP_LOGI(TCP_SERVER_TAG, "WIFI TASK START");

	/* Start the wifi station */
	wifi_mode_server = WIFI_MODE_AP;
	initialize_wifi_server();

	ESP_LOGI(TCP_SERVER_TAG, "THIS IS MASTER");

	xTaskCreate(udp_server_task, "udp_server_task", 4096, NULL, 5,
	NULL);
	delay(200);
	ESP_LOGI(TCP_SERVER_TAG, "[APP] Free memory: %d bytes",
			esp_get_free_heap_size());

}
