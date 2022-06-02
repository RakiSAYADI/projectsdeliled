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
#include "system_init.h"

const char *INIT_TAG = "app_init";

UnitStatDef UnitStat = UNIT_STATUS_LOADING;
UnitStatDef LastUnitStat = UNIT_STATUS_NONE;

void setUnitStatus(UnitStatDef NewStat)
{
	if (NewStat == UnitStat)
		return;
	LastUnitStat = UnitStat;
	UnitStat = NewStat;
}

UnitStatDef getUnitState()
{
	return UnitStat;
}

UnitStatDef getUnitLastState()
{
	return LastUnitStat;
}

void systemInit()
{
	esp_err_t err = nvs_flash_init();
	if (err == ESP_ERR_NVS_NO_FREE_PAGES || err == ESP_ERR_NVS_NEW_VERSION_FOUND)
	{
		ESP_ERROR_CHECK(nvs_flash_erase());
		err = nvs_flash_init();
	}
	ESP_ERROR_CHECK(err);

	ESP_LOGI(INIT_TAG, "INITIATE ESP32 SYSTEM");
	ESP_ERROR_CHECK(esp_netif_init());
	ESP_ERROR_CHECK(esp_event_loop_create_default());

	ESP_LOGI(INIT_TAG, "[APP] Free memory: %d bytes", esp_get_free_heap_size());
}
