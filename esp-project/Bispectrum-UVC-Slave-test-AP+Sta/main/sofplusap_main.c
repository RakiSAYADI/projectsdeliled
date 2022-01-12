/*  WiFi softAP Example

 This example code is in the Public Domain (or CC0 licensed, at your option.)

 Unless required by applicable law or agreed to in writing, this
 software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 CONDITIONS OF ANY KIND, either express or implied.
 */
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "driver/gpio.h"
#include "sdkconfig.h"

#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include "lwip/netdb.h"
#include "lwip/dns.h"
#include "lwip/api.h"

#include "lwip/apps/sntp.h"

/* The examples use WiFi configuration that you can set via 'make menuconfig'.

 If you'd rather not, just change the below entries to strings with
 the config you want - ie #define EXAMPLE_WIFI_SSID "mywifissid"
 */

#define EXAMPLE_ESP_WIFI_AP_SSID      "myesp32"
#define EXAMPLE_ESP_WIFI_AP_PASS      "123456789"
#define EXAMPLE_MAX_STA_CONN          10

#define EXAMPLE_ESP_WIFI_STA_SSID      "TT_A3F0"
#define EXAMPLE_ESP_WIFI_STA_PASS      "b6s4j9r63g"

#define EXAMPLE_ESP_WIFI_STATE_BLINK      GPIO_NUM_2

#define delay(ms) (vTaskDelay(ms/portTICK_RATE_MS))

/* FreeRTOS event group to signal when we are connected*/
static EventGroupHandle_t s_wifi_event_group;
const int CONNECTED_BIT_CLIENT = BIT0;
static const char *TAG = "wifi softAP+STA";

esp_err_t event_handler_client(void *ctx, system_event_t *event_data) {
	switch (event_data->event_id) {
		case SYSTEM_EVENT_STA_START: {
			esp_wifi_connect();
			break;
		}
		case WIFI_EVENT_AP_STACONNECTED: {
			wifi_event_ap_staconnected_t* event =
					(wifi_event_ap_staconnected_t*) event_data;
			ESP_LOGI(TAG, "station "MACSTR" join, AID=%d", MAC2STR(event->mac),
					event->aid);
			break;
		}
		case WIFI_EVENT_AP_STADISCONNECTED: {
			wifi_event_ap_stadisconnected_t* event =
					(wifi_event_ap_stadisconnected_t*) event_data;
			ESP_LOGI(TAG, "station "MACSTR" leave, AID=%d", MAC2STR(event->mac),
					event->aid);
			break;
		}
		case SYSTEM_EVENT_STA_GOT_IP: {
			xEventGroupSetBits(s_wifi_event_group, CONNECTED_BIT_CLIENT);
			ESP_LOGI(TAG, "Got IP");
			ESP_LOGI(TAG, "IP: %s\r",
					ip4addr_ntoa(&event_data->event_info.got_ip.ip_info.ip));
			ESP_LOGI(TAG, "MASK: %s\r",
					ip4addr_ntoa(&event_data->event_info.got_ip.ip_info.netmask));
			ESP_LOGI(TAG, "GATEWAY: %s\r",
					ip4addr_ntoa(&event_data->event_info.got_ip.ip_info.gw));
			//

			break;
		}
		case SYSTEM_EVENT_STA_DISCONNECTED: {
			xEventGroupClearBits(s_wifi_event_group, CONNECTED_BIT_CLIENT);
			ESP_LOGI(TAG, "retry to connect to the AP");
			esp_wifi_connect();
			break;
		}
		default:
			break;
	}
	return ESP_OK;
}

void wifi_init_APplusSTA() {
	s_wifi_event_group = xEventGroupCreate();

	tcpip_adapter_init();
	ESP_ERROR_CHECK(esp_event_loop_create_default());
	ESP_ERROR_CHECK(esp_event_loop_init(event_handler_client, NULL));

	wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT()
	;
	ESP_ERROR_CHECK(esp_wifi_init(&cfg));

	wifi_config_t wifi_config_ap = {
			.ap = {
					.ssid = EXAMPLE_ESP_WIFI_AP_SSID,
					.ssid_len = strlen(EXAMPLE_ESP_WIFI_AP_SSID),
					.password = EXAMPLE_ESP_WIFI_AP_PASS,
					.max_connection = EXAMPLE_MAX_STA_CONN,
					.authmode =	WIFI_AUTH_WPA_WPA2_PSK
			},
	};

	wifi_config_t wifi_config_sta = {
			.sta = {
					.ssid = EXAMPLE_ESP_WIFI_STA_SSID,
					.password = EXAMPLE_ESP_WIFI_STA_PASS
			},
	};

	if (strlen(EXAMPLE_ESP_WIFI_AP_PASS) == 0) {
		wifi_config_ap.ap.authmode = WIFI_AUTH_OPEN;
	}

	ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_APSTA));
	ESP_ERROR_CHECK(esp_wifi_set_config(ESP_IF_WIFI_AP, &wifi_config_ap));
	ESP_ERROR_CHECK(esp_wifi_set_config(ESP_IF_WIFI_STA, &wifi_config_sta));
	ESP_ERROR_CHECK(esp_wifi_start());

	ESP_LOGI(TAG, "wifi_init_softap finished. SSID:%s password:%s",
			EXAMPLE_ESP_WIFI_AP_SSID, EXAMPLE_ESP_WIFI_AP_PASS);

	ESP_LOGI(TAG, "connect to ap SSID:%s password:%s",
			EXAMPLE_ESP_WIFI_STA_SSID, EXAMPLE_ESP_WIFI_STA_PASS);
}

void wifi_State_indicator() {
	while (true) {
		ESP_LOGI(TAG, "GPIO BLINK STATE METHOD");
		delay(10000);
	}
}

void app_main() {
	ESP_LOGI(TAG, "Set APP INIT STATE");

	//Initialize NVS

	esp_err_t ret = nvs_flash_init();
	if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
		ESP_ERROR_CHECK(nvs_flash_erase());
		ret = nvs_flash_init();
	}
	ESP_ERROR_CHECK(ret);

	ESP_LOGI(TAG, "Set GPIO BLINK STATE");

	// initialize the gpio

	gpio_pad_select_gpio(EXAMPLE_ESP_WIFI_STATE_BLINK);
	ESP_ERROR_CHECK(gpio_set_direction(EXAMPLE_ESP_WIFI_STATE_BLINK, GPIO_MODE_OUTPUT));
	// setting BLINK GPIO OFF
	ESP_ERROR_CHECK(gpio_set_level(EXAMPLE_ESP_WIFI_STATE_BLINK, 0));


	ESP_LOGI(TAG, "ESP_WIFI_MODE_AP and ESP_WIFI_MODE_STA");
	wifi_init_APplusSTA();

	//xTaskCreate(&wifi_State_indicator, "GPIO BLINK STATE", 2048, NULL, 2,NULL);
}
