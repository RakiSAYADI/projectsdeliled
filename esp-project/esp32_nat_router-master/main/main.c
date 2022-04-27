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
#include "nat_router.h"
#include "app_gpio.h"
#include "http_server.h"
#include "base_mac_address.h"
#include "aes.h"

const char *MAIN_TAG = "app_main";

int app_main(void)
{

	// Initiate ESP32 SYSTEM
	systemInit();

	// Initiate basic mac address
	// BaseMacInit();

	// Initiate and restore the storage data
	if (!InitLoadCfg())
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

	setTextToEncrypt("Hello");

	encodeAESCBC();
	decodeAESCBC();

	return 0;
}
