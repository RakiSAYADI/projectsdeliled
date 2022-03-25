/*
 * unitcfg.c
 *
 *  Created on: Dec 26, 2018
 *      Author: mdt
 */

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_log.h"
#include "driver/uart.h"
#include "driver/gpio.h"
#include "soc/uart_struct.h"
#include "string.h"
#include <stdio.h>
#include <string.h>
#include <freertos/FreeRTOS.h>
#include <freertos/task.h>
#include <esp_log.h>
#include <esp_err.h>
#include <esp_system.h>
#include <esp_event_loop.h>
#include "esp_wifi.h"
#include <nvs.h>
#include <nvs_flash.h>
#include <driver/gpio.h>
#include <tcpip_adapter.h>
#include "sdkconfig.h"
#include "esp_system.h"
#include <stdlib.h>
#include "stdbool.h"

#include "unitcfg.h"

UnitConfig_Typedef UnitCfg;
UnitData_Typedef UnitData;

#define UNITCFG_NAMESPACE "unitcfgnvs"
#define KEY_CONNECTION_INFO "unitcfg"
#define KEY_VERSION "key"
#define KEY_VERSION_VAL 0x01

int SaveNVS(UnitConfig_Typedef *data) {
	nvs_handle handle;
	esp_err_t err = ESP_FAIL;

	err = nvs_open(UNITCFG_NAMESPACE, NVS_READWRITE, &handle);

	if (err != ESP_OK) {
		ESP_LOGE("NVS", "nvs_open: %x", err);
		return -1;
	}

	err = nvs_set_blob(handle, KEY_CONNECTION_INFO, data,
			sizeof(UnitConfig_Typedef));

	if (err != ESP_OK) {
		ESP_LOGE("NVS", "Error Setting NVS Blob (%d).", err);
		nvs_close(handle);
		return -1;
	}

	err = nvs_set_u32(handle, KEY_VERSION, KEY_VERSION_VAL);

	if (err != ESP_OK) {
		ESP_LOGE("NVS", "Error Setting Key version (%d).", err);
		nvs_close(handle);
		return -1;
	}

	err = nvs_commit(handle);

	if (err != ESP_OK) {
		ESP_LOGE("NVS", "Error Writing NVS (%d).", err);
		nvs_close(handle);
		return -1;
	}

	nvs_close(handle);

	ESP_LOGI("NVS", "Configuration saved");

	return (0);
}

int LoadNVS(UnitConfig_Typedef *data) {
	nvs_handle handle;
	size_t size;
	esp_err_t err;
	uint32_t version;

	err = nvs_open(UNITCFG_NAMESPACE, NVS_READWRITE, &handle);

	if (err != 0) {
		ESP_LOGE("NVS", "nvs_open: %x", err);
		return -1;
	}

	err = nvs_get_u32(handle, KEY_VERSION, &version);
	if (err != ESP_OK) {
		ESP_LOGE("NVS", "Incompatible versions (%d).", err);
		nvs_close(handle);
		return -1;
	}

	size = sizeof(UnitConfig_Typedef);
	err = nvs_get_blob(handle, KEY_CONNECTION_INFO, data, &size);

	if (err != ESP_OK) {
		ESP_LOGE("NVS", "No Unit config record found (%d)", err);
		nvs_close(handle);
		return -1;
	}

	nvs_close(handle);

	//ESP_LOGI("NVS", "Configuration Loaded (%d) bytes",size);

	ESP_LOGI("NVS", "Configuration Loaded (%d) bytes", sizeof(UnitCfg));

	return 0;
}

int InitLoadCfg() {
	if (LoadNVS(&UnitCfg) != 0) {
		Default_saving();
	} else {
		ESP_LOGI("NVS", "Unit Config Loading OK");
	}

	return (0);
}

void Default_saving() {
	uint8_t mac[6];
	esp_efuse_mac_get_default(mac);

	sprintf(UnitCfg.UnitName, "MAESTRO-%02X:%02X:%02X", mac[3], mac[4], mac[5]);

	sprintf(UnitCfg.UserLcProfile.name, "Bureau");
	sprintf(UnitCfg.UserLcProfile.profile_name, "PROFILE_1");

	UnitCfg.UserLcProfile.Alum_Exten_enb = false;

	UnitCfg.UserLcProfile.AutoTrigTimeEnb = false;
	sprintf(UnitCfg.UserLcProfile.Trig_days, "0");
	sprintf(UnitCfg.UserLcProfile.Trig_zone, "0");
	UnitCfg.UserLcProfile.AutoTrigTime = 0;

	UnitCfg.UserLcProfile.AutoTrigTime2Enb = false;
	sprintf(UnitCfg.UserLcProfile.Trig2_days, "0");
	sprintf(UnitCfg.UserLcProfile.Trig2_zone, "0");
	UnitCfg.UserLcProfile.AutoTrigTime2 = 0;

	UnitCfg.UserLcProfile.AutoStopTimeEnb = false;
	sprintf(UnitCfg.UserLcProfile.Stop_days, "0");
	sprintf(UnitCfg.UserLcProfile.Stop_zone, "0");
	UnitCfg.UserLcProfile.AutoStopTime = 0;

	UnitCfg.UserLcProfile.AutoStopTime2Enb = false;
	sprintf(UnitCfg.UserLcProfile.Stop2_days, "0");
	sprintf(UnitCfg.UserLcProfile.Stop2_zone, "0");
	UnitCfg.UserLcProfile.AutoStopTime2 = 0;

	UnitCfg.UserLcProfile.PIRBrEnb = false;
	UnitCfg.UserLcProfile.PirTimeout = 0;
	sprintf(UnitCfg.UserLcProfile.PIR_days, "0");
	sprintf(UnitCfg.UserLcProfile.PIR_zone, "0");

	UnitCfg.UserLcProfile.AutoBrEnb = false;
	UnitCfg.UserLcProfile.AutoBrRef = 0;
	sprintf(UnitCfg.UserLcProfile.Zone_lum, "0");
	UnitCfg.UserLcProfile.FixedBrLevel_zone1 = 0;
	UnitCfg.UserLcProfile.FixedBrLevel_zone2 = 0;
	UnitCfg.UserLcProfile.FixedBrLevel_zone3 = 0;
	UnitCfg.UserLcProfile.FixedBrLevel_zone4 = 0;
	UnitCfg.UserLcProfile.FixedBrLevel_zone_010v = 0;
	UnitCfg.UserLcProfile.seuil_eclairage = false;

	UnitCfg.UserLcProfile.Auto_or_fixe = false;
	sprintf(UnitCfg.UserLcProfile.Zone_fixe_lum, "0");
	UnitCfg.UserLcProfile.FixeStartTime = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone1 = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone2 = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone3 = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone4 = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone_010v = 0;
	UnitCfg.UserLcProfile.FixeStopTime = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone1 = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone2 = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone3 = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone4 = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone_010v = 0;
	UnitCfg.UserLcProfile.FixeStartTime_2 = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone1_2 = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone2_2 = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone3_2 = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone4_2 = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone_010v_2 = 0;
	UnitCfg.UserLcProfile.FixeStopTime_2 = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone1_2 = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone2_2 = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone3_2 = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone4_2 = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone_010v_2 = 0;

	UnitCfg.UserLcProfile.CcEnb = false;
	sprintf(UnitCfg.UserLcProfile.ZoneCc, "0");
	sprintf(UnitCfg.UserLcProfile.EnbCc, "0");
	UnitCfg.UserLcProfile.CcBetweenTimes = false;
	UnitCfg.UserLcProfile.Ccp[0].CcLevel = 0;
	UnitCfg.UserLcProfile.Ccp[0].CcTime = 0;
	UnitCfg.UserLcProfile.Ccp[1].CcLevel = 0;
	UnitCfg.UserLcProfile.Ccp[1].CcTime = 0;
	UnitCfg.UserLcProfile.Ccp[2].CcLevel = 0;
	UnitCfg.UserLcProfile.Ccp[2].CcTime = 0;
	UnitCfg.UserLcProfile.Ccp[3].CcLevel = 0;
	UnitCfg.UserLcProfile.Ccp[3].CcTime = 0;

	sprintf(UnitCfg.Zones_info[0].Color, "000000");
	UnitCfg.Zones_info[0].Luminosite = 0;
	UnitCfg.Zones_info[0].Stabilisation = 0;
	UnitCfg.Zones_info[0].Temperature = 0;
	sprintf(UnitCfg.Zones_info[1].Color, "000000");
	UnitCfg.Zones_info[1].Luminosite = 0;
	UnitCfg.Zones_info[1].Stabilisation = 0;
	UnitCfg.Zones_info[1].Temperature = 0;
	sprintf(UnitCfg.Zones_info[2].Color, "000000");
	UnitCfg.Zones_info[2].Luminosite = 0;
	UnitCfg.Zones_info[2].Stabilisation = 0;
	UnitCfg.Zones_info[2].Temperature = 0;
	sprintf(UnitCfg.Zones_info[3].Color, "000000");
	UnitCfg.Zones_info[3].Luminosite = 0;
	UnitCfg.Zones_info[3].Stabilisation = 0;
	UnitCfg.Zones_info[3].Temperature = 0;

	sprintf(UnitCfg.ColortrProfile[0].name, "Ambiance1");
	UnitCfg.ColortrProfile[0].stabilisation = 0;
	UnitCfg.ColortrProfile[0].Rouge = 0;
	UnitCfg.ColortrProfile[0].Vert = 0;
	UnitCfg.ColortrProfile[0].Bleu = 0;
	UnitCfg.ColortrProfile[0].Blanche = 0;
	UnitCfg.ColortrProfile[0].intensity = 0;
	sprintf(UnitCfg.ColortrProfile[0].zone, "0");
	sprintf(UnitCfg.ColortrProfile[1].name, "Ambiance2");
	UnitCfg.ColortrProfile[1].stabilisation = 0;
	UnitCfg.ColortrProfile[1].Rouge = 0;
	UnitCfg.ColortrProfile[1].Vert = 0;
	UnitCfg.ColortrProfile[1].Bleu = 0;
	UnitCfg.ColortrProfile[1].Blanche = 0;
	UnitCfg.ColortrProfile[1].intensity = 0;
	sprintf(UnitCfg.ColortrProfile[1].zone, "0");
	sprintf(UnitCfg.ColortrProfile[2].name, "Ambiance3");
	UnitCfg.ColortrProfile[2].stabilisation = 0;
	UnitCfg.ColortrProfile[2].Rouge = 0;
	UnitCfg.ColortrProfile[2].Vert = 0;
	UnitCfg.ColortrProfile[2].Bleu = 0;
	UnitCfg.ColortrProfile[2].Blanche = 0;
	UnitCfg.ColortrProfile[2].intensity = 0;
	sprintf(UnitCfg.ColortrProfile[2].zone, "0");
	sprintf(UnitCfg.ColortrProfile[3].name, "Ambiance4");
	UnitCfg.ColortrProfile[3].stabilisation = 0;
	UnitCfg.ColortrProfile[3].Rouge = 0;
	UnitCfg.ColortrProfile[3].Vert = 0;
	UnitCfg.ColortrProfile[3].Bleu = 0;
	UnitCfg.ColortrProfile[3].Blanche = 0;
	UnitCfg.ColortrProfile[3].intensity = 0;
	sprintf(UnitCfg.ColortrProfile[3].zone, "0");

	UnitCfg.Scenes.Scene_switch = false;
	sprintf(UnitCfg.Scenes.Zone, "0");
	UnitCfg.Scenes.Infiniti_scene = false;
	sprintf(UnitCfg.Scenes.scene_seq,
			"{\"0\":[0,0,0],\"1\":[1,0,0],\"2\":[2,0,0],\"3\":[3,0,0]}");

	UnitData.state = 0;

	sprintf(UnitCfg.WifiCfg.WIFI_SSID, "ssid");
	sprintf(UnitCfg.WifiCfg.WIFI_PASS, "password");

	UnitCfg.Co2NotifyEnb = true;
	UnitCfg.Co2LevelWarEnb = false;
	UnitCfg.Co2LevelEmailEnb = false;
	sprintf(UnitCfg.Email, "exemple@mail.com");
	UnitCfg.Co2NotifyEnb = false;
	UnitCfg.Co2LevelZoneEnb = false;
	sprintf(UnitCfg.Co2LevelSelect, "0");
	UnitCfg.Co2LevelWar = 1500;

	UnitCfg.PirSensitivity = 500;
	UnitCfg.UnitTimeZone = 0;

	UnitCfg.FtpConfig.FtpLogEnb = false;
	sprintf(UnitCfg.FtpConfig.Server, "ftpserver");
	UnitCfg.FtpConfig.Port = 21;
	sprintf(UnitCfg.FtpConfig.UserName, "ftpuser");
	sprintf(UnitCfg.FtpConfig.Password, "ftppassword");
	sprintf(UnitCfg.FtpConfig.Client_id, "client_1");
	UnitCfg.FtpConfig.ftp_now_or_later = false;
	UnitCfg.FtpConfig.FtpTimeout_send = 0;
	UnitCfg.FtpConfig.ftp_send = 0;

	UnitCfg.MqttConfig.MqttLogEnb = false;
	sprintf(UnitCfg.MqttConfig.Server, "mqttserver");
	UnitCfg.FtpConfig.Port = 80;
	sprintf(UnitCfg.MqttConfig.UserName, "mqttuser");
	sprintf(UnitCfg.MqttConfig.Password, "mqttpassword");
	sprintf(UnitCfg.MqttConfig.Topic, "mqtttopic");
	sprintf(UnitCfg.MqttConfig.sousTopic, "all");
	UnitCfg.MqttConfig.TopicTimeout = 0;
	UnitCfg.Summer_time = false;
	UnitCfg.first_summer = false;

	UnitCfg.Static_IP.Enable = false;
	sprintf(UnitCfg.Static_IP.IP, "192.168.1.22");
	sprintf(UnitCfg.Static_IP.MASK, "255.255.255.0");
	sprintf(UnitCfg.Static_IP.GATE_WAY, "192.168.1.254");
	sprintf(UnitCfg.Static_IP.DNS_SERVER, "8.8.8.8");

	UnitCfg.UDPConfig.Enable = false;
	UnitCfg.UDPConfig.ipv4_ipv6 = false; //default ipv4
	sprintf(UnitCfg.UDPConfig.Server, "192.168.1.22");
	UnitCfg.UDPConfig.Port = 3333;

	sprintf(UnitCfg.Zones.ZONE_1, "Zone 1");
	sprintf(UnitCfg.Zones.ZONE_2, "Zone 2");
	sprintf(UnitCfg.Zones.ZONE_3, "Zone 3");
	sprintf(UnitCfg.Zones.ZONE_4, "Zone 4");

	sprintf(UnitCfg.FLASH_MEMORY, "OK");

	if (SaveNVS(&UnitCfg) == 0) {
		ESP_LOGI("NVS", "Unit Config saving OK");
	} else {
		ESP_LOGE("NVS", "Unit Config saving NOT OK");
	}
}

void Default_profile_saving() {
	sprintf(UnitCfg.UserLcProfile.name, "Bureau");
	sprintf(UnitCfg.UserLcProfile.profile_name, "PROFILE_1");
	UnitCfg.UserLcProfile.Alum_Exten_enb = false;
	sprintf(UnitCfg.UserLcProfile.Trig_days, "0");
	sprintf(UnitCfg.UserLcProfile.Trig_zone, "0");
	UnitCfg.UserLcProfile.PIRBrEnb = false;
	sprintf(UnitCfg.UserLcProfile.Stop_days, "0");
	sprintf(UnitCfg.UserLcProfile.Stop_zone, "0");
	sprintf(UnitCfg.UserLcProfile.PIR_days, "0");
	sprintf(UnitCfg.UserLcProfile.PIR_zone, "0");
	UnitCfg.UserLcProfile.AutoStopTime2Enb = false;
	sprintf(UnitCfg.UserLcProfile.Stop2_days, "0");
	sprintf(UnitCfg.UserLcProfile.Stop2_zone, "0");
	UnitCfg.UserLcProfile.AutoStopTime2 = 0;
	UnitCfg.UserLcProfile.AutoTrigTime2Enb = false;
	sprintf(UnitCfg.UserLcProfile.Trig2_days, "0");
	sprintf(UnitCfg.UserLcProfile.Trig2_zone, "0");
	UnitCfg.UserLcProfile.AutoTrigTime2 = 0;
	UnitCfg.UserLcProfile.seuil_eclairage = false;
	UnitCfg.UserLcProfile.AutoTrigTime = 0;
	UnitCfg.UserLcProfile.AutoTrigTimeEnb = false;
	UnitCfg.UserLcProfile.AutoStopTimeEnb = false;
	UnitCfg.UserLcProfile.AutoStopTime = 0;
	UnitCfg.UserLcProfile.PirTimeout = 0;
	UnitCfg.UserLcProfile.AutoBrEnb = false;
	UnitCfg.UserLcProfile.AutoBrRef = 0;
	sprintf(UnitCfg.UserLcProfile.Zone_lum, "0");
	UnitCfg.UserLcProfile.FixedBrLevel_zone1 = 0;
	UnitCfg.UserLcProfile.FixedBrLevel_zone2 = 0;
	UnitCfg.UserLcProfile.FixedBrLevel_zone3 = 0;
	UnitCfg.UserLcProfile.FixedBrLevel_zone4 = 0;
	UnitCfg.UserLcProfile.FixedBrLevel_zone_010v = 0;

	UnitCfg.UserLcProfile.Auto_or_fixe = false;
	sprintf(UnitCfg.UserLcProfile.Zone_fixe_lum, "0");
	UnitCfg.UserLcProfile.FixeStartTime = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone1 = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone2 = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone3 = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone4 = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone_010v = 0;
	UnitCfg.UserLcProfile.FixeStopTime = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone1 = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone2 = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone3 = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone4 = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone_010v = 0;
	UnitCfg.UserLcProfile.FixeStartTime_2 = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone1_2 = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone2_2 = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone3_2 = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone4_2 = 0;
	UnitCfg.UserLcProfile.FixedStartLum_zone_010v_2 = 0;
	UnitCfg.UserLcProfile.FixeStopTime_2 = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone1_2 = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone2_2 = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone3_2 = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone4_2 = 0;
	UnitCfg.UserLcProfile.FixedStopLum_zone_010v_2 = 0;

	UnitCfg.UserLcProfile.CcEnb = false;
	sprintf(UnitCfg.UserLcProfile.ZoneCc, "0");
	sprintf(UnitCfg.UserLcProfile.EnbCc, "0");
	UnitCfg.UserLcProfile.CcBetweenTimes = false;
	UnitCfg.UserLcProfile.Ccp[0].CcLevel = 0;
	UnitCfg.UserLcProfile.Ccp[0].CcTime = 0;
	UnitCfg.UserLcProfile.Ccp[1].CcLevel = 0;
	UnitCfg.UserLcProfile.Ccp[1].CcTime = 0;
	UnitCfg.UserLcProfile.Ccp[2].CcLevel = 0;
	UnitCfg.UserLcProfile.Ccp[2].CcTime = 0;
	UnitCfg.UserLcProfile.Ccp[3].CcLevel = 0;
	UnitCfg.UserLcProfile.Ccp[3].CcTime = 0;

	UnitCfg.Co2LevelWarEnb = false;
	UnitCfg.Co2LevelEmailEnb = false;
	sprintf(UnitCfg.Email, "exemple@mail.com");
	UnitCfg.Co2NotifyEnb = false;
	UnitCfg.Co2LevelZoneEnb = false;
	sprintf(UnitCfg.Co2LevelSelect, "0");
	UnitCfg.Co2LevelWar = 1500;

	if (SaveNVS(&UnitCfg) == 0) {
		ESP_LOGI("NVS", "Unit Config saving OK");
	} else {
		ESP_LOGE("NVS", "Unit Config saving NOT OK");
	}
}

void Default_favoris_saving() {

	sprintf(UnitCfg.ColortrProfile[0].name, "Ambiance1");
	UnitCfg.ColortrProfile[0].stabilisation = 0;
	UnitCfg.ColortrProfile[0].Rouge = 0;
	UnitCfg.ColortrProfile[0].Vert = 0;
	UnitCfg.ColortrProfile[0].Bleu = 0;
	UnitCfg.ColortrProfile[0].Blanche = 0;
	UnitCfg.ColortrProfile[0].intensity = 0;
	sprintf(UnitCfg.ColortrProfile[0].zone, "0");
	sprintf(UnitCfg.ColortrProfile[1].name, "Ambiance2");
	UnitCfg.ColortrProfile[1].stabilisation = 0;
	UnitCfg.ColortrProfile[1].Rouge = 0;
	UnitCfg.ColortrProfile[1].Vert = 0;
	UnitCfg.ColortrProfile[1].Bleu = 0;
	UnitCfg.ColortrProfile[1].Blanche = 0;
	UnitCfg.ColortrProfile[1].intensity = 0;
	sprintf(UnitCfg.ColortrProfile[1].zone, "0");
	sprintf(UnitCfg.ColortrProfile[2].name, "Ambiance3");
	UnitCfg.ColortrProfile[2].stabilisation = 0;
	UnitCfg.ColortrProfile[2].Rouge = 0;
	UnitCfg.ColortrProfile[2].Vert = 0;
	UnitCfg.ColortrProfile[2].Bleu = 0;
	UnitCfg.ColortrProfile[2].Blanche = 0;
	UnitCfg.ColortrProfile[2].intensity = 0;
	sprintf(UnitCfg.ColortrProfile[2].zone, "0");
	sprintf(UnitCfg.ColortrProfile[3].name, "Ambiance4");
	UnitCfg.ColortrProfile[3].stabilisation = 0;
	UnitCfg.ColortrProfile[3].Rouge = 0;
	UnitCfg.ColortrProfile[3].Vert = 0;
	UnitCfg.ColortrProfile[3].Bleu = 0;
	UnitCfg.ColortrProfile[3].Blanche = 0;
	UnitCfg.ColortrProfile[3].intensity = 0;
	sprintf(UnitCfg.ColortrProfile[3].zone, "0");

	if (SaveNVS(&UnitCfg) == 0) {
		ESP_LOGI("NVS", "Unit Config saving OK");
	} else {
		ESP_LOGE("NVS", "Unit Config saving NOT OK");
	}
}

