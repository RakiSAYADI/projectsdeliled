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


int SaveNVS(UnitConfig_Typedef *data){
	nvs_handle handle;
	esp_err_t err = ESP_FAIL;

	err = nvs_open(UNITCFG_NAMESPACE, NVS_READWRITE, &handle);

	if(err != ESP_OK)
		{
			ESP_LOGE("NVS", "nvs_open: %x",  err);
			return -1;
		}

	err = nvs_set_blob(handle, KEY_CONNECTION_INFO, data,sizeof(UnitConfig_Typedef));

	if (err != ESP_OK)
		{
			ESP_LOGE("NVS", "Error Setting NVS Blob (%d).", err);
			nvs_close(handle);
			return -1;
		}

	err = nvs_set_u32(handle, KEY_VERSION, KEY_VERSION_VAL);

	if (err != ESP_OK)
		{
			ESP_LOGE("NVS", "Error Setting Key version (%d).", err);
			nvs_close(handle);
			return -1;
		}

	err = nvs_commit(handle);

	if (err != ESP_OK)
		{
			ESP_LOGE("NVS", "Error Writing NVS (%d).", err);
			nvs_close(handle);
			return -1;
		}

	nvs_close(handle);

	ESP_LOGI("NVS", "Configuration saved");

	return(0);
}

int LoadNVS(UnitConfig_Typedef *data)
{
	nvs_handle handle;
	size_t size;
	esp_err_t err;
	uint32_t version;

	err = nvs_open(UNITCFG_NAMESPACE, NVS_READWRITE, &handle);

	if(err != 0)
		{
			ESP_LOGE("NVS", "nvs_open: %x",  err);
			return -1;
		}

	err = nvs_get_u32(handle, KEY_VERSION, &version);
	if (err != ESP_OK)
		{
			ESP_LOGE("NVS", "Incompatible versions (%d).", err);
			nvs_close(handle);
			return -1;
		}

	size = sizeof(UnitConfig_Typedef);
	err = nvs_get_blob(handle, KEY_CONNECTION_INFO,data , &size);

	if (err != ESP_OK)
	{
		ESP_LOGE("NVS", "No Unit config record found (%d)", err);
		nvs_close(handle);
		return -1;
	}

		nvs_close(handle);

		ESP_LOGI("NVS", "Configuration Loaded (%d) bytes",sizeof(UnitCfg));

		return 0;
}


int InitLoadCfg()
{
	if (LoadNVS(&UnitCfg)!=0)
	{
		uint8_t mac[6];
		esp_efuse_mac_get_default(mac);

		sprintf(UnitCfg.UnitName,"MAESTRO-%02X:%02X:%02X",mac[3],mac[4],mac[5]);

		sprintf(UnitCfg.UserLcProfile.name,"Bureau");
		sprintf(UnitCfg.UserLcProfile.profile_name,"PROFILE_1");
		sprintf(UnitCfg.UserLcProfile.Veille_days,"0");
		UnitCfg.UserLcProfile.FixedBrLevel_zone1 = 0;
		UnitCfg.UserLcProfile.FixedBrLevel_zone2 = 0;
		UnitCfg.UserLcProfile.FixedBrLevel_zone3 = 0;
		UnitCfg.UserLcProfile.FixedBrLevel_zone4 = 0;
		UnitCfg.UserLcProfile.FixedBrLevel_zone_010v = 0;
		UnitCfg.UserLcProfile.seuil_eclairage =false;
		UnitCfg.UserLcProfile.VeilleBrEnb = 0;
		sprintf(UnitCfg.UserLcProfile.veille_zone,"0");
		UnitCfg.UserLcProfile.AutoTrigTime = 0;
		UnitCfg.UserLcProfile.AutoTrigTimeEnb = false;
		UnitCfg.UserLcProfile.AutoStopTime = 0;
		UnitCfg.UserLcProfile.PirTimeout = 0;
		UnitCfg.UserLcProfile.NoticeTimeout = 0;
		UnitCfg.UserLcProfile.AutoBrEnb = false;
		UnitCfg.UserLcProfile.AutoBrRef = 0;
		UnitCfg.UserLcProfile.CcEnb = false;
		sprintf(UnitCfg.UserLcProfile.ZoneCc,"0");
		UnitCfg.UserLcProfile.Ccp[0].CcLevel = 0;
		UnitCfg.UserLcProfile.Ccp[0].CcTime = 0;
		UnitCfg.UserLcProfile.Ccp[1].CcLevel = 0;
		UnitCfg.UserLcProfile.Ccp[1].CcTime = 0;
		UnitCfg.UserLcProfile.Ccp[2].CcLevel = 0;
		UnitCfg.UserLcProfile.Ccp[2].CcTime = 0;
		UnitCfg.Co2NotifyEnb=true;

		sprintf(UnitCfg.ColortrProfile[0].name,"Favoris1");
		UnitCfg.ColortrProfile[0].FAV=true;
		UnitCfg.ColortrProfile[0].blanche=50;
		UnitCfg.ColortrProfile[0].Rouge=205;
		UnitCfg.ColortrProfile[0].Vert=105;
		UnitCfg.ColortrProfile[0].Bleu=40;
		sprintf(UnitCfg.ColortrProfile[1].name,"Favoris2");
		UnitCfg.ColortrProfile[1].FAV=false;
		UnitCfg.ColortrProfile[1].blanche=50;
		UnitCfg.ColortrProfile[1].Rouge=100;
		UnitCfg.ColortrProfile[1].Vert=33;
		UnitCfg.ColortrProfile[1].Bleu=123;
		sprintf(UnitCfg.ColortrProfile[2].name,"Favoris3");
		UnitCfg.ColortrProfile[2].FAV=true;
		UnitCfg.ColortrProfile[2].blanche=50;
		UnitCfg.ColortrProfile[2].Rouge=50;
		UnitCfg.ColortrProfile[2].Vert=170;
		UnitCfg.ColortrProfile[2].Bleu=200;
		sprintf(UnitCfg.ColortrProfile[3].name,"Favoris4");
		UnitCfg.ColortrProfile[3].FAV=false;
		UnitCfg.ColortrProfile[3].blanche=50;
		UnitCfg.ColortrProfile[3].Rouge=159;
		UnitCfg.ColortrProfile[3].Vert=180;
		UnitCfg.ColortrProfile[3].Bleu=210;

		sprintf(UnitCfg.WifiCfg.WIFI_SSID,"ssid");
		sprintf(UnitCfg.WifiCfg.WIFI_PASS,"password");

		UnitCfg.Co2LevelWarEnb = false;
		UnitCfg.Co2LevelWar= 1000;
		sprintf(UnitCfg.Co2LevelSelect,"a");
		sprintf(UnitCfg.Email,"delitech.alert@gmail.com");
		UnitCfg.PirSensitivity = 500;
		UnitCfg.UnitTimeZone = 1;

		UnitCfg.FtpConfig.FtpLogEnb = false;
		sprintf(UnitCfg.FtpConfig.Server,"ftpserver");
		UnitCfg.FtpConfig.Port = 21;
		sprintf(UnitCfg.FtpConfig.UserName,"ftpuser");
		sprintf(UnitCfg.FtpConfig.Password,"ftppassword");


		UnitCfg.MqttConfig.MqttLogEnb = false;
		sprintf(UnitCfg.MqttConfig.Server,"mqttserver");
		UnitCfg.MqttConfig.Port = 80;
		sprintf(UnitCfg.MqttConfig.UserName,"mqttuser");
		sprintf(UnitCfg.MqttConfig.Password,"mqttpassword");
		sprintf(UnitCfg.MqttConfig.Topic,"mqttpassword");
		sprintf(UnitCfg.MqttConfig.Topic,"mqtttopic");

		UnitCfg.state=UNIT_STAT_OFF;

		UnitCfg.Static_IP.Enable=false;
		sprintf(UnitCfg.Static_IP.IP,"192.168.1.22");
		sprintf(UnitCfg.Static_IP.MASK,"255.255.255.0");
		sprintf(UnitCfg.Static_IP.GATE_WAY,"192.168.1.254");
		sprintf(UnitCfg.Static_IP.DNS_SERVER,"8.8.8.8");

		if (SaveNVS(&UnitCfg)==0)
			{
				ESP_LOGI("NVS","Unit Config saving OK");
			}
		else{
				return(-1);
			}

	}
	else
	{
		ESP_LOGI("NVS","Unit Config Loading OK");
	}

	return(0);
}



