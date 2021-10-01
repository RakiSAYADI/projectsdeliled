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
#include <esp_err.h>
#include <nvs.h>
#include <nvs_flash.h>
#include "sdkconfig.h"
#include <stdlib.h>
#include "stdbool.h"

#include "unitcfg.h"

UnitConfig_Typedef UnitCfg;
UnitData_Typedef UnitData;

#define UNITCFG_NAMESPACE "unitcfgnvs"
#define KEY_CONNECTION_INFO "unitcfg"
#define KEY_VERSION "key"
#define KEY_VERSION_VAL 0x01

int SaveNVS(UnitConfig_Typedef *data)
{
	nvs_handle handle;
	esp_err_t err = ESP_FAIL;

	err = nvs_open(UNITCFG_NAMESPACE, NVS_READWRITE, &handle);

	if (err != ESP_OK)
	{
		ESP_LOGE("NVS", "nvs_open: %x", err);
		return -1;
	}

	err = nvs_set_blob(handle, KEY_CONNECTION_INFO, data,
					   sizeof(UnitConfig_Typedef));

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

	return (0);
}

int LoadNVS(UnitConfig_Typedef *data)
{
	nvs_handle handle;
	size_t size;
	esp_err_t err;
	uint32_t version;

	err = nvs_open(UNITCFG_NAMESPACE, NVS_READWRITE, &handle);

	if (err != 0)
	{
		ESP_LOGE("NVS", "nvs_open: %x", err);
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
	err = nvs_get_blob(handle, KEY_CONNECTION_INFO, data, &size);

	if (err != ESP_OK)
	{
		ESP_LOGE("NVS", "No Unit config record found (%d)", err);
		nvs_close(handle);
		return -1;
	}

	nvs_close(handle);

	//ESP_LOGI("NVS", "Configuration Loaded (%d) bytes",size);

	ESP_LOGI("NVS", "Configuration Loaded (%d) bytes", sizeof(UnitCfg));

	return 0;
}

int InitLoadCfg()
{
	if (LoadNVS(&UnitCfg) != 0)
	{
		Default_saving();
	}
	else
	{
		ESP_LOGI("NVS", "Unit Config Loading OK");
	}

	return (0);
}

void Default_saving()
{
	uint8_t mac[6];
	esp_efuse_mac_get_default(mac);

	sprintf(UnitCfg.UnitName, "MAESTRO-%02X:%02X:%02X", mac[3], mac[4], mac[5]);

	sprintf(UnitCfg.UserLcProfile.name, "Bureau");
	sprintf(UnitCfg.UserLcProfile.profile_name, "PROFILE_1");

	UnitCfg.UserLcProfile.CcEnb = false;
	sprintf(UnitCfg.UserLcProfile.ZoneCc, "0");

	for (int i = 0; i < 3; i++)
	{
		UnitCfg.UserLcProfile.Ccp[i].CcLevel = 0;
		UnitCfg.UserLcProfile.Ccp[i].CcTime = 0;
	}

	for (int i = 0; i < 4; i++)
	{
		sprintf(UnitCfg.Zones_info[i].name, "Zone %d", i + 1);

		sprintf(UnitCfg.ColortrProfile[i].name, "Ambiance%d", i + 1);
		UnitCfg.ColortrProfile[i].stabilisation = 0;
		UnitCfg.ColortrProfile[i].Rouge = 0;
		UnitCfg.ColortrProfile[i].Vert = 0;
		UnitCfg.ColortrProfile[i].Bleu = 0;
		UnitCfg.ColortrProfile[i].Blanche = 0;
		UnitCfg.ColortrProfile[i].intensity = 0;
		sprintf(UnitCfg.ColortrProfile[i].zone, "0");
	}

	UnitData.state = 0;

	sprintf(UnitCfg.WifiCfg.WIFI_SSID, "ssid");
	sprintf(UnitCfg.WifiCfg.WIFI_PASS, "password");

	UnitCfg.Co2LevelWarEnb = false;
	UnitCfg.Co2LevelEmailEnb = false;
	sprintf(UnitCfg.Email, "exemple@mail.com");
	UnitCfg.Co2NotifyEnb = false;
	UnitCfg.Co2LevelZoneEnb = false;
	sprintf(UnitCfg.Co2LevelSelect, "0");
	UnitCfg.Co2LevelWar = 1500;

	UnitCfg.PirSensitivity = 500;
	UnitCfg.UnitTimeZone = 0;

	sprintf(UnitCfg.FLASH_MEMORY, "OK");

	if (SaveNVS(&UnitCfg) == 0)
	{
		ESP_LOGI("NVS", "Unit Config saving OK");
	}
	else
	{
		ESP_LOGE("NVS", "Unit Config saving NOT OK");
	}
}
