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

#define UVCROBOTNAME "DEEPLIGHT-G005"
#define FIRMWAREVERSIONNAME "3.0.0"
#define VERSION 0

typedef struct {
	char ZONE1[10];
	char ZONE2[10];
	char ZONE3[10];
	char ZONE4[10];
} Zones_Typedef;

typedef struct {
	bool state;
	time_t autoTrigTime;
	uint8_t duration;
	char hue[8];
	char zones[3];
	uint8_t startLumVal;
	uint8_t finishLumVal;
} AlarmDay_Typedef;

typedef struct {
	char Days[3];
	AlarmDay_Typedef alarmDay[7];
} Alarm_Typedef;

typedef struct {
	char name[10];
	char Hue[8];
} ColortrProfile_Typedef;

typedef struct {
	char WIFI_SSID[64];
	char WIFI_PASS[64];
} WifiConfig_Typedef;

typedef struct {
	char UnitName[64];
	uint8_t Version;
	char FirmwareVersion[7];
	Zones_Typedef Zones;
	WifiConfig_Typedef WifiCfg;
	ColortrProfile_Typedef Colorprofile[4];
	Alarm_Typedef AlarmClock;
	char FLASH_MEMORY[3];
} UnitConfig_Typedef;

extern UnitConfig_Typedef UnitCfg;

void saveDataTask(bool savenvsFlag);
void syncTime(time_t t, uint32_t tzone);

void Default_saving();
int InitLoadCfg();
int SaveNVS(UnitConfig_Typedef *data);

#endif /* MAIN_UNITCFG_H_ */
