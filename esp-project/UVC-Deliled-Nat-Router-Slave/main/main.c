/*
 * main.c
 *
 *  Created on: 19 août 2020
 *      Author: raki
 */
#include "string.h"
#include "esp_system.h"
#include "esp_log.h"

#include "sdkconfig.h"

#include "main.h"
#include "unitcfg.h"
#include "app_gpio.h"
#include "uvc_task.h"
#include "base_mac_address.h"
#include "udp_client.h"
#include "uvc_task.h"
#include "system_init.h"
#include "espnow_slave.h"

char *TAG = "app_main";

int app_main(void)
{
	// Initiate ESP32 SYSTEM
	systemInit();

	setUnitStatus(UNIT_STATUS_LOADING);

	// Initialize Base Mac Address.
	BaseMacInit();

	// Initiate UVC task
	uvcStatInit();

	// Initialize GPIOs.
	relayStatInit();

	// Initialize and restore the storage data
	if (!InitLoadCfg())
	{
		setUnitStatus(UNIT_STATUS_NONE);
		return -1;
	}

	// Intialize WIFI NETWORK for the client
	//UDPClient();

	// Intialize WIFINOW NETWORK for the client
	espnowSlave();

	setUnitStatus(UNIT_STATUS_IDLE);

	return 0;
}
