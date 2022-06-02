/*
 * main.c
 *
 *  Created on: 19 août 2022
 *      Author: raki
 */
#include "string.h"
#include "esp_log.h"
#include "sdkconfig.h"

#include "main.h"

#include "unitcfg.h"
#include "system_init.h"
#include "tcp_server.h"
#include "udp_server.h"
#include "nat_router.h"
#include "app_gpio.h"
#include "http_server.h"
#include "base_mac_address.h"
#include "aes.h"
#include "uvc_task.h"

const char *MAIN_TAG = "MAIN";

int app_main(void)
{

	// Initiate ESP32 SYSTEM
	systemInit();

	setUnitStatus(UNIT_STATUS_LOADING);

	// Initiate basic mac address
	// BaseMacInit();

	// Initiate and restore the storage data
	if (!InitLoadCfg())
	{
		setUnitStatus(UNIT_STATUS_NONE);
		return -1;
	}

	// Initiate UVC task
	uvcStatInit();

	// Initiate LED indicator
	LedStatInit();

	// Initiate nat WIFI
	natRouter();

	// Initiate WEB server
	startWebserver();

	// Initiate TCP protocol
	TCPServer();

	// Initiate UDP protocol
	UDPServer();

	setUnitStatus(UNIT_STATUS_IDLE);
	
	//delay(60000);

	//setUnitStatus(UNIT_STATUS_UVC_STARTING);

	return 0;
}
