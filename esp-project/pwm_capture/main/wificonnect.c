#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
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

#include "wificonnect.h"
#include "unitcfg.h"

EventGroupHandle_t s_wifi_event_group;

bool stateConnection;

const char *CONNECT_TAG = "WEB_SERVICE";

esp_err_t event_handler(void *ctx, system_event_t *event) {
	switch (event->event_id) {
	case SYSTEM_EVENT_STA_START:
		esp_wifi_connect();
		break;
	case SYSTEM_EVENT_STA_GOT_IP:
		xEventGroupSetBits(s_wifi_event_group, BIT0);
		ESP_LOGI(CONNECT_TAG, "Got IP");
		ESP_LOGI(CONNECT_TAG, "IP: %s\r",
				ip4addr_ntoa(&event->event_info.got_ip.ip_info.ip));
		ESP_LOGI(CONNECT_TAG, "MASK: %s\r",
				ip4addr_ntoa(&event->event_info.got_ip.ip_info.netmask));
		ESP_LOGI(CONNECT_TAG, "GATEWAY: %s\r",
				ip4addr_ntoa(&event->event_info.got_ip.ip_info.gw));

		stateConnection = true;

		break;
	case SYSTEM_EVENT_STA_DISCONNECTED: {
		//esp_wifi_connect();
		xEventGroupClearBits(s_wifi_event_group, BIT0);
		ESP_LOGI(CONNECT_TAG, "retry to connect to the AP");
		stateConnection = false;
		break;
	}
	default:
		break;
	}
	return ESP_OK;
}

void connectWIFITask() {
	s_wifi_event_group = xEventGroupCreate();
	// Connecting WIFI
	ESP_ERROR_CHECK(esp_event_loop_init(event_handler, NULL));

	wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT()
	;
	ESP_ERROR_CHECK(esp_wifi_init(&cfg));

	ESP_ERROR_CHECK(esp_wifi_set_storage(WIFI_STORAGE_RAM));

	wifi_config_t wifiConfigConnect;

	memset(&wifiConfigConnect, 0, sizeof(wifi_config_t));
	memcpy(wifiConfigConnect.sta.ssid, UnitCfg.WifiCfg.WIFI_SSID,
			strlen(UnitCfg.WifiCfg.WIFI_SSID) + 1);
	memcpy(wifiConfigConnect.sta.password, UnitCfg.WifiCfg.WIFI_PASS,
			strlen(UnitCfg.WifiCfg.WIFI_PASS) + 1);

	ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
	ESP_ERROR_CHECK(esp_wifi_set_config(ESP_IF_WIFI_STA, &wifiConfigConnect));

	ESP_ERROR_CHECK(esp_wifi_start());

	ESP_LOGI(CONNECT_TAG, "wifi_init_sta finished.");
	ESP_LOGI(CONNECT_TAG, "connect to ap SSID:%s. password:%s.",
			wifiConfigConnect.sta.ssid, wifiConfigConnect.sta.password);
}
