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

#include "scanwifi.h"
#include "wificonnect.h"
#include "unitcfg.h"

EventGroupHandle_t s_wifi_event_group;

const char *SCAN_TAG = "WEB_SERVICE";

void removeSpaces(char *str1)
{
    char *str2;
    str2=str1;
    while (*str2==' ') str2++;
    if (str2!=str1) memmove(str1,str2,strlen(str2)+1);
}
char* getAuthModeName(wifi_auth_mode_t auth_mode) {

	char *names[] = { "OPEN", "WEP", "WPA PSK", "WPA2 PSK", "WPA WPA2 PSK",
			"MAX" };
	return names[auth_mode];
}

void scanWIFITask() {
	// WIFI Init State
	scanResult = false;
	s_wifi_event_group = xEventGroupCreate();

	ESP_LOGI(SCAN_TAG, "ACTIVATING WIFI SCANNING \n");
	// configure, initialize and start the wifi driver
	wifi_init_config_t wifi_config = WIFI_INIT_CONFIG_DEFAULT()
	;
	ESP_ERROR_CHECK(esp_wifi_init(&wifi_config));
	ESP_ERROR_CHECK(esp_wifi_set_storage(WIFI_STORAGE_RAM));
	ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
	ESP_ERROR_CHECK(esp_wifi_start());

	// Scan WIFI Modems
	ap_num = MAX_APs;
	wifi_scan_time_t scanningTime;
	wifi_active_scan_time_t activeScanning = { .min = 500, .max = 1000 };
	scanningTime.active = activeScanning;
	wifi_scan_config_t scan_config = { .ssid = 0, .bssid = 0, .channel = 0,
			.scan_time = scanningTime, .show_hidden = true };
	printf("Start scanning…");
	ESP_ERROR_CHECK(esp_wifi_scan_start(&scan_config, true));
	printf(" completed!\n");
	printf("\n");

	wifi_ap_record_t ap_records[MAX_APs];
	ESP_ERROR_CHECK(esp_wifi_scan_get_ap_records(&ap_num, ap_records));

	printf("Found %d access points:\n", ap_num);
	printf("\n");
	printf(" SSID | Channel | RSSI | Auth Mode \n");
	printf("—————————————————————-\n");
	for (int i = 0; i < ap_num; i++) {
		printf("%32s | %7d | %4d | %12s\n", (char *) ap_records[i].ssid,
				ap_records[i].primary, ap_records[i].rssi,
				getAuthModeName(ap_records[i].authmode));
	}
	printf("—————————————————————-\n");

	ESP_LOGI(SCAN_TAG, "SCANNING WIFI IS COMPLETED \n");

	for (int i = 0; i < ap_num; i++) {
		sprintf(stationRecords[i].ap_records, "%32s",
				(char *) ap_records[i].ssid);
		removeSpaces(stationRecords[i].ap_records);
		ESP_LOGI(SCAN_TAG, "stationRecords[%d].ap_records = %s", i,
				stationRecords[i].ap_records);
	}
	scanResult = true;
}
