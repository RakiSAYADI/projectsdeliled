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

	ESP_ERROR_CHECK(nvs_flash_init());

	// Initialize GPIOs.
	LedStatInit();

	// Initialize and restore the storage data
	if (InitLoadCfg() != 0) {
		return -1;
	}

	//Intialize WIFI NETWORK for the server
	//wifiConnectionServer();

	//Intialize WIFI NETWORK for the client
	wifiConnectionClient();


	// Initiate Bluetooth services (only for SERVER).
	//bt_main();

	return 0;
}