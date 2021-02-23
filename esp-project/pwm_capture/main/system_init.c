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

#include "wificonnect.h"

char* INIT_TAG = "app_init";

void systemInit() {

	ESP_LOGI(INIT_TAG, "INITIATE ESP32 SYSTEM \n");
	ESP_ERROR_CHECK(nvs_flash_init());
	tcpip_adapter_init();
	ESP_ERROR_CHECK(esp_event_loop_create_default());

	stateConnection = false;

	ESP_LOGI(INIT_TAG, "[APP] Free memory: %d bytes", esp_get_free_heap_size());
}
