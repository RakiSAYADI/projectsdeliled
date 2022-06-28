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

#include "unitcfg.h"
#include "uvc_task.h"
#include "system_init.h"
#include "udp_client.h"

#define JOIN_TIMEOUT_MS (2000)

const char *UDP_CLIENT_TAG = "UDP_CLIENT";

const int CONNECTED_BIT_CLIENT = BIT0;
const int CONNECTED_BIT = BIT0;

EventGroupHandle_t wifi_event_group_client;
TaskHandle_t xSlaveTask;
esp_netif_t *wifiSTA;

void udp_client_task(void *pvParameters);

struct sockaddr_in dest_addr;

char addr_str[128];
int sock;

esp_err_t event_handler_client(void *ctx, system_event_t *event)
{
	switch (event->event_id)
	{
	case SYSTEM_EVENT_STA_START:
		esp_wifi_connect();
		break;
	case SYSTEM_EVENT_STA_GOT_IP:
		ESP_LOGI(UDP_CLIENT_TAG, "Got IP");
		ESP_LOGI(UDP_CLIENT_TAG, "IP: %s\r", ip4addr_ntoa(&event->event_info.got_ip.ip_info.ip));
		ESP_LOGI(UDP_CLIENT_TAG, "MASK: %s\r", ip4addr_ntoa(&event->event_info.got_ip.ip_info.netmask));
		ESP_LOGI(UDP_CLIENT_TAG, "GATEWAY: %s\r", ip4addr_ntoa(&event->event_info.got_ip.ip_info.gw));
		xEventGroupSetBits(wifi_event_group_client, CONNECTED_BIT_CLIENT);
		/* Start the udp client */
		//xTaskCreate(udp_client_task, "udp_client_task", 4096, NULL, 3, &xSlaveTask);
		break;
	case SYSTEM_EVENT_STA_DISCONNECTED:
		ESP_LOGI(UDP_CLIENT_TAG, "retry to connect to the AP");
		esp_wifi_connect();
		xEventGroupClearBits(wifi_event_group_client, CONNECTED_BIT_CLIENT);
		break;
	default:
		break;
	}
	return ESP_OK;
}

bool sendUDPData(const char *data)
{
	int err = sendto(sock, data, strlen(data), 0, (struct sockaddr *)&dest_addr, sizeof(dest_addr));
	if (err < 0)
	{
		ESP_LOGE(UDP_CLIENT_TAG, "Error occurred during sending: errno %d", errno);
		return false;
	}
	ESP_LOGI(UDP_CLIENT_TAG, "Sending Successful");
	return true;
}

void udp_client_task(void *pvParameters)
{
	char tmp[64];
	char rx_buffer[256];
	char tx_buffer[256];
	struct sockaddr_in source_addr; // Large enough for both IPv4 or IPv6
	int len, err;
	dest_addr.sin_addr.s_addr = inet_addr(UDP_SERVER);
	dest_addr.sin_family = AF_INET;
	dest_addr.sin_port = htons(UDP_PORT);
	inet_ntoa_r(dest_addr.sin_addr, addr_str, sizeof(addr_str) - 1);

	socklen_t socklen;

	struct timeval receiving_timeout;
	receiving_timeout.tv_sec = 1;
	receiving_timeout.tv_usec = 0;

	double time_taken;

	while (1)
	{
		//clock_t t;
		//t = clock();

		sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
		if (sock < 0)
		{
			ESP_LOGE(UDP_CLIENT_TAG, "Unable to create socket: errno %d", errno);
			esp_restart();
		}
		ESP_LOGI(UDP_CLIENT_TAG, "Socket created, sending to %s:%d", UDP_SERVER, UDP_PORT);

		if (setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &receiving_timeout, sizeof(receiving_timeout)) < 0)
		{
			ESP_LOGE(UDP_CLIENT_TAG, "... failed to set socket receiving timeout");
			esp_restart();
		}
		ESP_LOGI(UDP_CLIENT_TAG, "Timeout Successful");

		sprintf(tx_buffer, "{\"detec\":%d,\"state\":%d,\"slave\":%d}", detectionEventTrigered, getUnitState(), SLAVE_ID);

		err = sendto(sock, tx_buffer, strlen(tx_buffer), 0, (struct sockaddr *)&dest_addr, sizeof(dest_addr));
		if (err < 0)
		{
			ESP_LOGE(UDP_CLIENT_TAG, "Error occurred during sending: errno %d", errno);
			esp_restart();
		}
		ESP_LOGI(UDP_CLIENT_TAG, "Message sent");

		socklen = sizeof(source_addr);
		len = recvfrom(sock, rx_buffer, sizeof(rx_buffer) - 1, 0, (struct sockaddr *)&source_addr, &socklen);
		// Error occurred during receiving
		if (len < 0)
		{
			ESP_LOGE(UDP_CLIENT_TAG, "recvfrom failed: errno %d", errno);
			esp_restart();
		}
		// Data received
		else
		{
			rx_buffer[len] = 0; // Null-terminate whatever we received and treat like a string
			ESP_LOGI(UDP_CLIENT_TAG, "Received %d bytes from %s:", len, addr_str);
			ESP_LOGI(UDP_CLIENT_TAG, "%s", rx_buffer);

			if (getUnitState() == UNIT_STATUS_UVC_TREATEMENT || getUnitState() == UNIT_STATUS_UVC_STARTING)
			{
				if (jsonparse(rx_buffer, tmp, "stop", 0))
				{
					stopEventTrigered = atoi(tmp);
				}
			}
			if (jsonparse(rx_buffer, tmp, "DES", 0))
			{
				UnitCfg.DisinfictionTime = atoi(tmp);
			}
			if (jsonparse(rx_buffer, tmp, "ACT", 0))
			{
				UnitCfg.ActivationTime = atoi(tmp);
			}
			if (jsonparse(rx_buffer, tmp, "state", 0))
			{
				if (atoi(tmp) == UNIT_STATUS_UVC_STARTING)
				{
					if (getUnitState() == UNIT_STATUS_IDLE || getUnitState() == UNIT_STATUS_UVC_ERROR)
					{
						setUnitStatus(UNIT_STATUS_UVC_STARTING);
					}
				}
			}
		}
		shutdown(sock, 0);
		close(sock);
		//t = clock() - t;
		//time_taken = ((double)t) / CLOCKS_PER_SEC; // in seconds
		//ESP_LOGI(UDP_CLIENT_TAG, "Shutting down socket and restarting... %f", time_taken);
		ESP_LOGI(UDP_CLIENT_TAG, "Shutting down socket and restarting...");
		delay(SLAVE_ID * 750);
	}
	shutdown(sock, 0);
	close(sock);
	vTaskDelete(NULL);
}

void UDPClient()
{

	ESP_LOGI(UDP_CLIENT_TAG, "WIFI CLIENT TASK START");

	wifi_event_group_client = xEventGroupCreate();
	ESP_ERROR_CHECK(esp_event_loop_init(event_handler_client, NULL));

	wifiSTA = esp_netif_create_default_wifi_sta();

	wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
	ESP_ERROR_CHECK(esp_wifi_init(&cfg));
	ESP_ERROR_CHECK(esp_wifi_set_storage(WIFI_STORAGE_RAM));
	ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));

	xEventGroupWaitBits(wifi_event_group_client, CONNECTED_BIT, pdFALSE, pdTRUE, JOIN_TIMEOUT_MS / portTICK_PERIOD_MS);

	wifi_config_t conf = {.sta = {.ssid = SSIDNAME, .password = PASSWORD, .bssid_set = false}};

	ESP_ERROR_CHECK(esp_wifi_set_config(ESP_IF_WIFI_STA, &conf));
	ESP_ERROR_CHECK(esp_wifi_start());
}
