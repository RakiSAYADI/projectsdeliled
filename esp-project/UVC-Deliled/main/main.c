/*
 * main.c
 *
 *  Created on: 19 août 2020
 *      Author: raki
 */
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_log.h"
#include "driver/uart.h"
#include "string.h"
#include <stdio.h>
#include <esp_log.h>
#include <nvs.h>
#include <nvs_flash.h>
#include "sdkconfig.h"
#include <stdlib.h>
#include "stdbool.h"

#include "main.h"

char* TAG = "app_main";

int app_main(void) {

	esp_err_t ret;
    // Initialize NVS.
    ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK( ret );

	// Initialize Base Mac Address.
	BaseMacInit();

	// Initialize GPIOs.
	LedStatInit();

	// Initialize and restore the storage data
	if (InitLoadCfg() != 0) {
		return -1;
	}

    //Default_saving();

	// Initiate Bluetooth services (only for SERVER).
	bt_main();

	return 0;
}
