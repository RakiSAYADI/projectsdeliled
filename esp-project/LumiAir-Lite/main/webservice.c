#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "nvs_flash.h"

#include "lwip/err.h"
#include "lwip/sys.h"

#include "sdkconfig.h"

#include "webservice.h"
#include "unitcfg.h"
#include "app_gpio.h"
#include "sntpservice.h"
#include "https_ota.h"

#define WIFI_CONNECTED_BIT BIT0
#define WIFI_FAIL_BIT BIT1

#define WIFI_RETRY_MAX 5

EventGroupHandle_t s_wifi_event_group;

const char *WEBSERVICE_TAG = "WEB_SERVICE";

int s_retry_num = 0;

bool WifiConnectedFlag = false;

esp_err_t event_wifi_handler(void *arg, esp_event_base_t event_base, int32_t event_id, void *event_data)
{
	if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START)
	{
		esp_wifi_connect();
	}
	else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_DISCONNECTED)
	{
		if (s_retry_num < WIFI_RETRY_MAX)
		{
			esp_wifi_connect();
			s_retry_num++;
			UnitSetStatus(UNIT_STATUS_WIFI_GETTING_IP);
			ESP_LOGI(WEBSERVICE_TAG, "retry to connect to the AP");
		}
		else
		{
			UnitSetStatus(UNIT_STATUS_WIFI_NO_IP);
			xEventGroupSetBits(s_wifi_event_group, WIFI_FAIL_BIT);
		}
		ESP_LOGI(WEBSERVICE_TAG, "connect to the AP fail");
		WifiConnectedFlag = false;
	}
	else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP)
	{
		ip_event_got_ip_t *event = (ip_event_got_ip_t *)event_data;
		ESP_LOGI(WEBSERVICE_TAG, "got ip:" IPSTR, IP2STR(&event->ip_info.ip));
		s_retry_num = 0;
		WifiConnectedFlag = true;
		// Start SNTP Task
		xTaskCreatePinnedToCore(&sntp_task, "sntp_task", 4000, NULL, 2, NULL, 1);
		// Start OTA Task
		xTaskCreatePinnedToCore(&advanced_ota_task, "ota_task", 1024 * 8, NULL, 2, NULL, 1);
		UnitSetStatus(UNIT_STATUS_WIFI_GOT_IP);
		xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
	}
	return ESP_OK;
}

void WebService_Init()
{
	s_wifi_event_group = xEventGroupCreate();

	ESP_ERROR_CHECK(esp_netif_init());

	ESP_ERROR_CHECK(esp_event_loop_create_default());
	esp_netif_create_default_wifi_sta();

	wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
	ESP_ERROR_CHECK(esp_wifi_init(&cfg));

	esp_event_handler_instance_t instance_any_id;
	esp_event_handler_instance_t instance_got_ip;
	ESP_ERROR_CHECK(esp_event_handler_instance_register(WIFI_EVENT, ESP_EVENT_ANY_ID, &event_wifi_handler, NULL, &instance_any_id));
	ESP_ERROR_CHECK(esp_event_handler_instance_register(IP_EVENT, IP_EVENT_STA_GOT_IP, &event_wifi_handler, NULL, &instance_got_ip));

	wifi_config_t wifi_config;

	memset(&wifi_config, 0, sizeof(wifi_config_t));

	wifi_config.sta.pmf_cfg.capable = true;
	wifi_config.sta.pmf_cfg.required = false;
	wifi_config.sta.threshold.authmode = WIFI_AUTH_WPA2_PSK;

	memcpy(wifi_config.sta.ssid, UnitCfg.WifiCfg.WIFI_SSID, strlen(UnitCfg.WifiCfg.WIFI_SSID) + 1);
	memcpy(wifi_config.sta.password, UnitCfg.WifiCfg.WIFI_PASS, strlen(UnitCfg.WifiCfg.WIFI_PASS) + 1);

	ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
	ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, &wifi_config));
	ESP_ERROR_CHECK(esp_wifi_start());

	UnitSetStatus(UNIT_STATUS_WIFI_STA);

	ESP_LOGI(WEBSERVICE_TAG, "wifi_init_sta finished.");

	EventBits_t bits = xEventGroupWaitBits(s_wifi_event_group, WIFI_CONNECTED_BIT | WIFI_FAIL_BIT, pdFALSE, pdFALSE, portMAX_DELAY);

	if (bits & WIFI_CONNECTED_BIT)
	{
		ESP_LOGI(WEBSERVICE_TAG, "connected to ap SSID:%s password:%s", UnitCfg.WifiCfg.WIFI_SSID, UnitCfg.WifiCfg.WIFI_PASS);
	}
	else if (bits & WIFI_FAIL_BIT)
	{
		ESP_LOGI(WEBSERVICE_TAG, "Failed to connect to SSID:%s, password:%s", UnitCfg.WifiCfg.WIFI_SSID, UnitCfg.WifiCfg.WIFI_PASS);
		UnitSetStatus(UNIT_STATUS_WIFI_NO_IP);
	}
	else
	{
		ESP_LOGE(WEBSERVICE_TAG, "UNEXPECTED EVENT");
	}

	/* The event will not be processed after unregister */
	ESP_ERROR_CHECK(esp_event_handler_instance_unregister(IP_EVENT, IP_EVENT_STA_GOT_IP, instance_got_ip));
	ESP_ERROR_CHECK(esp_event_handler_instance_unregister(WIFI_EVENT, ESP_EVENT_ANY_ID, instance_any_id));
	vEventGroupDelete(s_wifi_event_group);
}
