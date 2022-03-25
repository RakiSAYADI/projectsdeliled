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
#include "sntp_client.h"
#include "mqttclient.h"
#include "app_gpio.h"
#include "ftpclient.h"
#include "emailclient.h"
#include "ota_client.h"
#include "ota_check.h"
#include "udp_client.h"

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
		UnitSetStatus(UNIT_STATUS_WIFI_GOT_IP);
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

	tcpip_adapter_init();
	ESP_ERROR_CHECK(esp_event_loop_init(event_handler, NULL));

//	if (UnitCfg.Static_IP.Enable) {
//
//		tcpip_adapter_dhcpc_stop(TCPIP_ADAPTER_IF_STA); // Don't run a DHCP client
//
//		//Set static IP
//		tcpip_adapter_ip_info_t ipInfo;
//		inet_pton(AF_INET, UnitCfg.Static_IP.IP, &ipInfo.ip);
//		inet_pton(AF_INET, UnitCfg.Static_IP.GATE_WAY, &ipInfo.gw);
//		inet_pton(AF_INET, UnitCfg.Static_IP.MASK, &ipInfo.netmask);
//		tcpip_adapter_set_ip_info(TCPIP_ADAPTER_IF_STA, &ipInfo);
//
//		//Set Main DNS server
//		tcpip_adapter_dns_info_t dnsInfo;
//		inet_pton(AF_INET, UnitCfg.Static_IP.DNS_SERVER, &dnsInfo.ip);
//		tcpip_adapter_set_dns_info(TCPIP_ADAPTER_IF_STA, TCPIP_ADAPTER_DNS_MAIN,
//				&dnsInfo);
//
//	}

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

	while (WifiConnectedFlag == false) {
		UnitData.UpdateInfo = 3;
		if (s_retry_num >= 5) {
			ESP_LOGI(TAG, "Destroying the WIFI Thread !");
			esp_wifi_stop();
			esp_wifi_deinit();
			vTaskDelete(NULL);
		}
		vTaskDelay(2000 / portTICK_PERIOD_MS);
	}

	// Start SNTP Task
	xTaskCreatePinnedToCore(&sntp_task, "sntp_task", 4000, NULL, 2, NULL, 1);
	while (sntpTimeSetFlag == false) {
		vTaskDelay(1000 / portTICK_PERIOD_MS);
	}
	// Start FTP Task
	xTaskCreatePinnedToCore(&ftp_task, "ftp_task", 4000, NULL, 4, NULL, 1);
	// Start MQTT Client Task
	xTaskCreatePinnedToCore(&mqtt_app_start, "mqtt_app_start", 4000, NULL, 4,
			NULL, 1);
	// Start UDP CLIENT Service
	xTaskCreatePinnedToCore(&udp_app_start, "udp_app_start", 4000, NULL, 4,
			NULL, 1);
	// Start OTA checking Service
	xTaskCreatePinnedToCore(&checking_ota, "checking_ota", 2001, NULL, 3, NULL,
			1);
}
