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

char* TAG = "MAIN";

int app_main(void) {

	ESP_ERROR_CHECK(nvs_flash_init());

	// Initialize Base Mac Address.
	//BaseMacInit();

	// Initialize GPIOs.
	LedStatInit();

	// Initialize and restore the storage data
	if (InitLoadCfg() != 0) {
		return -1;
	}

	//Default_saving();

	// delay of 3s for the MASTER to Initiate 
	delay(3000);

	//Intialize WIFI NETWORK for the client
	wifiConnectionClient();

	return 0;
}