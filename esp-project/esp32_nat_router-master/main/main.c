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

#include "unitcfg.h"
#include "system_init.h"
#include "tcp_server.h"
#include "nat_router.h"
#include "app_gpio.h"
#include "http_server.h"
#include "base_mac_address.h"

char *MAIN_TAG = "app_main";

int app_main(void)
{

	// Initiate ESP32 SYSTEM
	systemInit();

	// Initiate basic mac address
	//BaseMacInit();

	// Initiate and restore the storage data
	if (InitLoadCfg() != 0)
	{
		return -1;
	}

	// Initiate nat WIFI
	natRouter();

	// Initiate LED indicator
	LedStatInit();

	// Initiate WEB server
	start_webserver();

	// Initiate TCP protocol
	TCPServer();

	return 0;
}
