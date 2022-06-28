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
#include "i2c.h"
#include "uvc_task.h"
#include "autouvc.h"
#include "smtp_client.h"
#include "emailclient.h"
#include "espnow_master.h"

const char *MAIN_TAG = "MAIN";

int app_main(void)
{

	// Initiate ESP32 SYSTEM
	systemInit();

	setUnitStatus(UNIT_STATUS_LOADING);

	// Initiate basic mac address
	BaseMacInit();

	// Initiate i2c communication
	I2c_Init();

	// Initiate and restore the storage data
	if (!InitLoadCfg())
	{
		setUnitStatus(UNIT_STATUS_NONE);
		return -1;
	}

	// Initiate UVC task
	uvcStatInit();

	// Initiate auto uvc
	AutoUVCDevice();

	// Initiate LED indicator
	LedStatInit();

	// Initiate nat WIFI
	natRouter();

	// Initiate WEB server
	startWebserver();

	// Initiate UDP protocol
	//UDPServer();

	// Initiate ESPNOW protocol
	espnowMaster();

	// Initiate TCP protocol
	TCPServer();

	// Initiate SMTP protocol
	//smtpClient();

	// Initiate SMTP 2 protocol
	emailClient();

	setUnitStatus(UNIT_STATUS_IDLE);

	// /*

	/*char hex[sizeof(encryptedHex)];
	memset(hex, 0, sizeof(hex));
	setTextToEncrypt("{\"data\":\"INFO\",\"name\":\"HuBBoX-39:19:84\",\"state\":\"IDLE\",\"wifi\":[\"DEEPLIGHT-HuBBoX-X001\",\"Deliled9318\"],\"timeDYS\":[10,300],\"dataDYS\":[\"Deliled\",\"ROBOT-D001\",\"Room 1\"]}");
	ESP_LOGI(MAIN_TAG, "the text is %s with size %d \nthe encrypted hex is %s with size %d", plaintext, strlen(plaintext), encryptedHex, strlen(encryptedHex));
	sprintf(encryptedHex, hex);
	setTextToDecrypt(hex);
	ESP_LOGI(MAIN_TAG, "the decrypted hex is %s with size %d", plaintext, strlen(plaintext));
	ESP_LOGI(MAIN_TAG, "Free memory: %d bytes", esp_get_free_heap_size());
	*/

	// */

	return 0;
}
