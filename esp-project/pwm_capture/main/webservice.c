#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event_loop.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "esp_event.h"
#include "tcpip_adapter.h"
#include "lwip/err.h"
#include "lwip/sys.h"
#include "lwip/dns.h"
#include "lwip/ip_addr.h"
#include "lwip/ip4_addr.h"
#include "lwip/ip6_addr.h"
#include <lwip/sockets.h>
#include <lwip/api.h>
#include <lwip/netdb.h>

#include "sdkconfig.h"

#include "webservice.h"
#include "unitcfg.h"

bool WifiConnectedFlag = false;

EventGroupHandle_t s_wifi_event_group;
const int WIFI_CONNECTED_BIT = BIT0;

static const char *TAG = "WEB_SERVICE";

static int s_retry_num = 0;

static esp_err_t event_handler(void *ctx, system_event_t *event) {
	switch (event->event_id) {
	case SYSTEM_EVENT_STA_START:
		esp_wifi_connect();
		break;
	case SYSTEM_EVENT_STA_GOT_IP:
		s_retry_num = 0;
		WifiConnectedFlag = true;
		xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
		ESP_LOGI(TAG, "Got IP");
		ESP_LOGI(TAG, "IP: %s\r",
				ip4addr_ntoa(&event->event_info.got_ip.ip_info.ip));
		ESP_LOGI(TAG, "MASK: %s\r",
				ip4addr_ntoa(&event->event_info.got_ip.ip_info.netmask));
		ESP_LOGI(TAG, "GATEWAY: %s\r",
				ip4addr_ntoa(&event->event_info.got_ip.ip_info.gw));

		break;
	case SYSTEM_EVENT_STA_DISCONNECTED: {
		esp_wifi_connect();
		xEventGroupClearBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
		WifiConnectedFlag = false;
		s_retry_num++;
		ESP_LOGI(TAG, "retry to connect to the AP");
		break;
	}
	default:
		break;
	}
	return ESP_OK;
}

void WebService_Init() {
	s_wifi_event_group = xEventGroupCreate();

	ESP_LOGI(TAG, "ACTIVATING WIFI COMMUNICATION \n");

	tcpip_adapter_init();
	ESP_ERROR_CHECK(esp_event_loop_init(event_handler, NULL));

	wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT()
	;
	ESP_ERROR_CHECK(esp_wifi_init(&cfg));

	ESP_ERROR_CHECK(esp_wifi_set_storage(WIFI_STORAGE_RAM));

	wifi_config_t wifi_config;

	memset(&wifi_config, 0, sizeof(wifi_config_t));
	memcpy(wifi_config.sta.ssid, UnitCfg.WifiCfg.WIFI_SSID,
			strlen(UnitCfg.WifiCfg.WIFI_SSID) + 1);
	memcpy(wifi_config.sta.password, UnitCfg.WifiCfg.WIFI_PASS,
			strlen(UnitCfg.WifiCfg.WIFI_PASS) + 1);

	ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
	ESP_ERROR_CHECK(esp_wifi_set_config(ESP_IF_WIFI_STA, &wifi_config));

	ESP_ERROR_CHECK(esp_wifi_start());

	ESP_LOGI(TAG, "wifi_init_sta finished.");
	ESP_LOGI(TAG, "connect to ap SSID:%s. password:%s.", wifi_config.sta.ssid,
			wifi_config.sta.password);

	ESP_LOGI(TAG, "WIFI COMMUNICATION IS ACTIVATED \n");

	while (WifiConnectedFlag == false) {
		if (s_retry_num >= 5) {
			ESP_LOGI(TAG, "Destroying the WIFI Thread !");
			esp_wifi_stop();
			esp_wifi_deinit();
			vTaskDelete(NULL);
		}
		vTaskDelay(2000 / portTICK_PERIOD_MS);
	}
}
