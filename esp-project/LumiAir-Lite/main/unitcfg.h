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

typedef struct {
	uint16_t CcLevel;
	time_t CcTime;
} CcPoint_Typedef;

typedef struct {
	//PIR (veille)
	bool PIRBrEnb;
	time_t PirTimeout;
	char PIR_days[8];
	char PIR_zone[8];
	//cycle
	bool CcEnb;
	char ZoneCc[3];
	CcPoint_Typedef Ccp[3];
} LightCtrProfile_Typedef;

typedef struct {
	char WIFI_SSID[64];
	char WIFI_PASS[64];
} WifiConfig_Typedef;

typedef struct {
	char zonename[20];
} ZonesInfo_Typedef;

typedef struct {
	char ambname[20];
	char Hue[10];
	char zone[2];
} ColortrProfile_Typedef;

typedef struct {
	char UnitName[64];
	WifiConfig_Typedef WifiCfg;
	LightCtrProfile_Typedef UserLcProfile;
	ColortrProfile_Typedef ColortrProfile[4];
	bool Co2LevelWarEnb;
	bool Co2LevelEmailEnb;
	char Email[64];
	bool Co2NotifyEnb;
	bool Co2LevelZoneEnb;
	char Co2LevelSelect[8];
	uint16_t Co2LevelWar;
	uint16_t PirSensitivity;
	int8_t UnitTimeZone;
	ZonesInfo_Typedef Zones_info[4];
	uint8_t Lum_10V;
	char passBLE[16];
	char FLASH_MEMORY[3];
} UnitConfig_Typedef;

#define UNIT_STAT_OFF 0
#define UNIT_STAT_REG_AUTO 1
#define UNIT_STAT_REG_MAN 2

typedef struct {
	time_t UpdateTime;
	time_t LastDetTime;
	double Temp;
	double Humidity;
	uint16_t Als;
	uint16_t aq_Co2Level;
	uint16_t aq_Tvoc;
	uint8_t aq_status;
	uint8_t UpdateInfo;
	uint8_t state;
} UnitData_Typedef;

extern UnitData_Typedef UnitData;
extern UnitConfig_Typedef UnitCfg;

void Default_saving();
bool InitLoadCfg();
bool SaveNVS(UnitConfig_Typedef *data);

void syncTime(time_t t, uint32_t tzone);

#endif /* MAIN_UNITCFG_H_ */