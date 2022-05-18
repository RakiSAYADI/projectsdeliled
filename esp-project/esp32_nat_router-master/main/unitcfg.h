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

#define DEVICE_NAME_DEFAULT "DEEPLIGHT"
#define DEFAULT_AP_SSID "X001"
#define DEFAULT_AP_PASSWORD "Deliled9318"
#define DEFAULT_AP_IP "192.168.2.1"
#define DEFAULT_DNS "8.8.8.8"

#define DEFAULT_MANUFACTURE "DELILED"
#define DEFAULT_SERIAL_NUMBER "00001233154"

#define MAXSLAVES 5

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
	uint32_t UVCTimeExecution;
	uint32_t UVCLifeTime;
	uint32_t NumberOfDisinfection;
} SlaveConfig_Typedef;

typedef struct
{
	char UnitName[32];
	char Company[64];
	char OperatorName[64];
	char RoomName[64];
	uint8_t Version;
	uint32_t DisinfictionTime;
	uint32_t ActivationTime;
	SlaveConfig_Typedef UVCSlaves[MAXSLAVES];
	char FirmwareVersion[6];
	char UnitTimeZone[64];
	WifiConfig_Typedef WifiCfg;
	char FLASH_MEMORY[3];
} UnitConfig_Typedef;

extern UnitConfig_Typedef UnitCfg;

void saveDataTask(bool savenvsFlag);
void syncTime(time_t t, char tzone[64]);

bool strContains(char *string, char *toFind);
bool jsonparse(char *src, char *dst, char *label, unsigned short arrayindex);

void Default_saving();
bool InitLoadCfg();
bool SaveNVS(UnitConfig_Typedef *data);

#endif /* MAIN_UNITCFG_H_ */
