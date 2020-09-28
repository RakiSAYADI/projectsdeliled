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


typedef struct
{
	uint16_t CcLevel;
	time_t CcTime;
}CcPoint_Typedef;


typedef struct
{
	char profile_name[16];
	char name[16];
	bool AutoTrigTimeEnb;
	time_t AutoTrigTime;
	time_t AutoStopTime;
	time_t PirTimeout;
	char Veille_days[8];
	bool AutoBrEnb;
	uint16_t AutoBrRef;
	bool seuil_eclairage;
	char Zone_lum[8];
	uint8_t FixedBrLevel_zone1;
	uint8_t FixedBrLevel_zone2;
	uint8_t FixedBrLevel_zone3;
	uint8_t FixedBrLevel_zone4;
	uint8_t FixedBrLevel_zone_010v;
	bool VeilleBrEnb;
	time_t NoticeTimeout;
	char veille_zone[8];
	bool CcEnb;
	char ZoneCc[2];
	CcPoint_Typedef Ccp[3];
}LightCtrProfile_Typedef;

typedef struct
{
	char WIFI_SSID[64];
	char WIFI_PASS[64];
}WifiConfig_Typedef;

typedef struct
{
	bool FtpLogEnb;
	char Server[64];
	uint16_t Port;
	char UserName[64];
	char Password[64];
}FtpConfig_Typedef;

typedef struct
{
	bool MqttLogEnb;
	char Server[64];
	uint16_t Port;
	char UserName[64];
	char Password[64];
	char Topic[64];
}MqttConfig_Typedef;

typedef struct
{
	char name[10];
	bool FAV;
	uint8_t Rouge;
	uint8_t Vert;
	uint8_t Bleu;
	uint8_t blanche;
}ColortrProfile_Typedef;

typedef struct
{
	bool Enable;
	char IP[16];
	char MASK[16];
	char GATE_WAY[16];
	char DNS_SERVER[16];
}Static_IP_Typedef;

typedef struct
{
	char UnitName[64];
	WifiConfig_Typedef WifiCfg;
	LightCtrProfile_Typedef UserLcProfile;
	ColortrProfile_Typedef ColortrProfile[4];
	bool Co2LevelWarEnb;
	uint16_t Co2LevelWar;
	bool Co2NotifyEnb;
	char Co2LevelSelect[8];
	char Email[64];
	uint16_t PirSensitivity;
	int8_t UnitTimeZone;
	FtpConfig_Typedef FtpConfig;
	MqttConfig_Typedef MqttConfig;
	Static_IP_Typedef Static_IP;
	char passBLE [16];
	bool Summer_time;
	bool first_summer;
	bool summer_count;
	uint8_t state;
}UnitConfig_Typedef;


#define UNIT_STAT_OFF 0
#define UNIT_STAT_REG_AUTO 1
#define UNIT_STAT_REG_MAN 2


typedef struct
{
	time_t UpdateTime;
	time_t LastDetTime;
	double Temp;
	double Humidity;
	uint16_t Als;
	uint16_t aq_Co2Level;
	uint16_t aq_Tvoc;
	uint8_t aq_status;
	int8_t Indice_Confinement;
	uint8_t unitStatus;
	uint8_t UpdateInfo;
	uint8_t auto_zone_1;
	uint8_t auto_zone_2;
	uint8_t auto_zone_3;
	uint8_t auto_zone_4;
	uint8_t auto_zone_010V;
}UnitData_Typedef;

extern UnitData_Typedef UnitData;
extern UnitConfig_Typedef UnitCfg;


int InitLoadCfg();
int SaveNVS(UnitConfig_Typedef *data);


#endif /* MAIN_UNITCFG_H_ */
