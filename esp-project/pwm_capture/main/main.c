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

#include "webservice.h"
#include "unitcfg.h"
#include "pwm_capture.h"
#include "base_mac_address.h"
#include "bluetooth.h"

char* TAG = "app_main";

int app_main(void) {

	ESP_ERROR_CHECK(nvs_flash_init());

	// Initialize Base Mac Address.
	BaseMacInit();

	// Initialize and restore the storage data
	if (InitLoadCfg() != 0) {
		return -1;
	}

	// Initiate reading PWM signal.
	pwm_main();

	ESP_LOGI(TAG, "[APP] Free memory: %d bytes", esp_get_free_heap_size());

	// Initiate Bluetooth services.
	bt_main();

	// Initiate connect to Web service.
	WebService_Init();

	return 0;
}
