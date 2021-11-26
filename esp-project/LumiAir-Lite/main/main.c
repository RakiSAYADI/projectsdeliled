#include "esp_log.h"
#include "string.h"
#include "stdio.h"
#include "nvs_flash.h"
#include "stdlib.h"

#include "sdkconfig.h"

#include "i2c.h"
#include "adc.h"
#include "main.h"
#include "app_gpio.h"
#include "lightcontrol.h"
#include "unitcfg.h"
#include "webservice.h"
#include "autolight.h"
#include "bluetooth.h"
#include "base_mac_address.h"

const char *TAG = "MAIN";

void app_main() {

	// Initialize NVS.
    esp_err_t err = nvs_flash_init();
    if (err == ESP_ERR_NVS_NO_FREE_PAGES || err == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        err = nvs_flash_init();
    }
	
    ESP_ERROR_CHECK( err );

	ESP_LOGI(TAG, "[APP] Startup..");
	ESP_LOGI(TAG, "[APP] Free memory: %d bytes", esp_get_free_heap_size());
	ESP_LOGI(TAG, "[APP] IDF version: %s", esp_get_idf_version());

	BaseMacInit();

	LedStatInit();

	if (!InitLoadCfg()) {
		UnitSetStatus(UNIT_STATUS_ERROR);
		return;
	}

	if (!(strContains(UnitCfg.FLASH_MEMORY, "OK") == 1)) {
		ESP_LOGW(TAG, "Saving the default configuration ..");
		Default_saving();
	}

	UnitSetStatus(UNIT_STATUS_LOADING);

	I2c_Init();
	AdcInit();
	lightControl_Init();
	bt_main();

	WebService_Init();

}
