/*
 * unitcfg.h
 *
 *  Created on: Dec 26, 2018
 *      Author: mdt
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "esp_system.h"

#include "sdkconfig.h"

#ifndef MAIN_UNITCFG_H_
#define MAIN_UNITCFG_H_

#define FIRMWAREVERSIONNAME "3.0.0"
#define VERSION 0
#define delay(ms) (vTaskDelay(ms / portTICK_RATE_MS))

#define DEFAULT_AP_SSID "Router"
#define DEFAULT_AP_IP "192.168.4.1"
#define DEFAULT_DNS "8.8.8.8"

typedef struct
{
	char AP_SSID[64];
	char AP_PASS[64];
	char AP_IP[20];
	char STA_SSID[64];
	char STA_PASS[64];
	char STA_IP_STATIC[64];
	char STA_SUBNET_MASK[64];
	char STA_GATEWAY[64];
} WifiConfig_Typedef;

typedef struct
{
	char UnitName[32];
	uint8_t Version;
	char FirmwareVersion[6];
	int8_t timeZone;
	WifiConfig_Typedef WifiCfg;
	char FLASH_MEMORY[3];
} UnitConfig_Typedef;

extern UnitConfig_Typedef UnitCfg;

void saveDataTask(bool savenvsFlag);
void syncTime(time_t t, char tzone[64]);

void Default_saving();
int InitLoadCfg();
int SaveNVS(UnitConfig_Typedef *data);

#endif /* MAIN_UNITCFG_H_ */
