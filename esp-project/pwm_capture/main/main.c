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

#include "scanwifi.h"
#include "wificonnect.h"
#include "autolight.h"
#include "unitcfg.h"
#include "pwm_capture.h"
#include "base_mac_address.h"
#include "bluetooth.h"
#include "system_init.h"

char* MAIN_TAG = "app_main";

int app_main(void) {

	// Initiate ESP32 SYSTEM
	systemInit();

	// Initiate Base Mac Address.
	BaseMacInit();

	// Initiate and restore the storage data
	if (InitLoadCfg() != 0) {
		return -1;
	}

	// Initiate reading PWM signal.
	pwm_main();

	// Initiate Bluetooth services.
	bt_main();

	// Initiate connecting WIFI.
	connectWIFITask();

	// Initiate Wake Up Program.
	autoLight();

	return 0;
}