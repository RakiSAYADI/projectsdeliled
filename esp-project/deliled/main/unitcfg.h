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
	char profile_name[16];
	char name[16];
	//pdata
	bool AutoTrigTimeEnb;
	char Trig_days[8];
	char Trig_zone[8];
	time_t AutoTrigTime;
	bool AutoTrigTime2Enb;
	char Trig2_days[8];
	char Trig2_zone[8];
	time_t AutoTrigTime2;
	bool AutoStopTimeEnb;
	char Stop_days[8];
	char Stop_zone[8];
	time_t AutoStopTime;
	bool AutoStopTime2Enb;
	char Stop2_days[8];
	char Stop2_zone[8];
	time_t AutoStopTime2;
	//PIR (veille)
	bool Alum_Exten_enb;
	bool PIRBrEnb;
	time_t PirTimeout;
	char PIR_days[8];
	char PIR_zone[8];
	//lum
	bool AutoBrEnb;
	uint16_t AutoBrRef;
	bool seuil_eclairage;
	char Zone_lum[8];
	uint8_t FixedBrLevel_zone1;
	uint8_t FixedBrLevel_zone2;
	uint8_t FixedBrLevel_zone3;
	uint8_t FixedBrLevel_zone4;
	uint8_t FixedBrLevel_zone_010v;
	bool Auto_or_fixe;
	char Zone_fixe_lum[8];
	time_t FixeStartTime;
	uint8_t FixedStartLum_zone1;
	uint8_t FixedStartLum_zone2;
	uint8_t FixedStartLum_zone3;
	uint8_t FixedStartLum_zone4;
	uint8_t FixedStartLum_zone_010v;
	time_t FixeStopTime;
	uint8_t FixedStopLum_zone1;
	uint8_t FixedStopLum_zone2;
	uint8_t FixedStopLum_zone3;
	uint8_t FixedStopLum_zone4;
	uint8_t FixedStopLum_zone_010v;
	time_t FixeStartTime_2;
	uint8_t FixedStartLum_zone1_2;
	uint8_t FixedStartLum_zone2_2;
	uint8_t FixedStartLum_zone3_2;
	uint8_t FixedStartLum_zone4_2;
	uint8_t FixedStartLum_zone_010v_2;
	time_t FixeStopTime_2;
	uint8_t FixedStopLum_zone1_2;
	uint8_t FixedStopLum_zone2_2;
	uint8_t FixedStopLum_zone3_2;
	uint8_t FixedStopLum_zone4_2;
	uint8_t FixedStopLum_zone_010v_2;
	//cycle
	bool CcEnb;
	char ZoneCc[2];
	char EnbCc[2];
	bool CcBetweenTimes;
	CcPoint_Typedef Ccp[4];
} LightCtrProfile_Typedef;

typedef struct {
	char WIFI_SSID[64];
	char WIFI_PASS[64];
} WifiConfig_Typedef;

typedef struct {
	char Color[10];
	uint8_t Luminosite;
	uint8_t Stabilisation;
	uint8_t Temperature;
} ZonesInfo_Typedef;

typedef struct {
	bool FtpLogEnb;
	char Server[64];
	uint16_t Port;
	char UserName[64];
	char Password[64];
	char Client_id[64];
	uint16_t FtpTimeout_send;
	bool ftp_now_or_later;
	time_t ftp_send;
} FtpConfig_Typedef;

typedef struct {
	bool MqttLogEnb;
	char Server[64];
	uint16_t Port;
	char UserName[64];
	char Password[64];
	char Topic[64];
	char sousTopic[5];
	uint16_t TopicTimeout;
} MqttConfig_Typedef;

typedef struct {
	char name[10];
	uint8_t Rouge;
	uint8_t Vert;
	uint8_t Bleu;
	uint8_t Blanche;
	uint8_t stabilisation;
	uint8_t intensity;
	char zone[2];
} ColortrProfile_Typedef;

typedef struct {
	bool Enable;
	char IP[16];
	char MASK[16];
	char GATE_WAY[16];
	char DNS_SERVER[16];
} Static_IP_Typedef;

typedef struct {
	bool Enable;
	bool ipv4_ipv6;
	char Server[64];
	uint16_t Port;
} UDPConfig_Typedef;

typedef struct {
	char ZONE_1[10];
	char ZONE_2[10];
	char ZONE_3[10];
	char ZONE_4[10];
} Zones_Typedef;

typedef struct {
	bool Scene_switch;
	time_t SceneTrigTime;
	time_t SceneStopTime;
	char Zone[3];
	bool Infiniti_scene;
	char scene_seq[512];
} Scenes_Typedef;

typedef struct {
	char UnitName[64];
	WifiConfig_Typedef WifiCfg;
	LightCtrProfile_Typedef UserLcProfile;
	ColortrProfile_Typedef ColortrProfile[4];
	Scenes_Typedef Scenes;
	bool Co2LevelWarEnb;
	bool Co2LevelEmailEnb;
	char Email[64];
	bool Co2NotifyEnb;
	bool Co2LevelZoneEnb;
	char Co2LevelSelect[8];
	uint16_t Co2LevelWar;
	uint16_t PirSensitivity;
	int8_t UnitTimeZone;
	ZonesInfo_Typedef Zones_info[3];
	uint8_t Lum_10V;
	UDPConfig_Typedef UDPConfig;
	FtpConfig_Typedef FtpConfig;
	MqttConfig_Typedef MqttConfig;
	Static_IP_Typedef Static_IP;
	Zones_Typedef Zones;
	char passBLE[16];
	bool Summer_time;
	bool first_summer;
	bool summer_count;
	uint8_t MODE;
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
	int8_t Indice_Confinement;
	uint8_t UpdateInfo;
	uint8_t auto_zone_1;
	uint8_t auto_zone_2;
	uint8_t auto_zone_3;
	uint8_t auto_zone_4;
	uint8_t auto_zone_010V;
	uint8_t state;
	uint8_t percent_ota;
	uint8_t ota_check;
	uint8_t scene_state;
} UnitData_Typedef;

extern UnitData_Typedef UnitData;
extern UnitConfig_Typedef UnitCfg;

void Default_saving();
void Default_favoris_saving();
void Default_profile_saving();
int InitLoadCfg();
int SaveNVS(UnitConfig_Typedef *data);

#endif /* MAIN_UNITCFG_H_ */
