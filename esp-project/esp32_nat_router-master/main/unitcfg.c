/*
 * unitcfg.c
 *
 *  Created on: 19 août 2020
 *      Author: raki
 */
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_log.h"
#include <stdio.h>
#include <string.h>
#include <esp_err.h>
#include <esp_event.h>
#include <nvs.h>
#include <nvs_flash.h>
#include "sdkconfig.h"
#include <stdlib.h>
#include "stdbool.h"

#include "unitcfg.h"

UnitConfig_Typedef UnitCfg;

#define UNITCFG_NAMESPACE "unitcfgnvs"
#define KEY_CONNECTION_INFO "unitcfg"
#define KEY_VERSION "key"
#define KEY_VERSION_VAL 0x01

const char *NVS_TAG = "NVS";

bool SaveNVS(UnitConfig_Typedef *data)
{
	nvs_handle handle;
	esp_err_t err = ESP_FAIL;

	err = nvs_open(UNITCFG_NAMESPACE, NVS_READWRITE, &handle);

	if (err != ESP_OK)
	{
		ESP_LOGE(NVS_TAG, "nvs_open: %x", err);
		return false;
	}

	err = nvs_set_blob(handle, KEY_CONNECTION_INFO, data, sizeof(UnitConfig_Typedef));

	if (err != ESP_OK)
	{
		ESP_LOGE(NVS_TAG, "Error Setting NVS Blob (%d).", err);
		nvs_close(handle);
		return false;
	}

	err = nvs_set_u32(handle, KEY_VERSION, KEY_VERSION_VAL);

	if (err != ESP_OK)
	{
		ESP_LOGE(NVS_TAG, "Error Setting Key version (%d).", err);
		nvs_close(handle);
		return false;
	}

	err = nvs_commit(handle);

	if (err != ESP_OK)
	{
		ESP_LOGE(NVS_TAG, "Error Writing NVS (%d).", err);
		nvs_close(handle);
		return false;
	}

	nvs_close(handle);

	ESP_LOGI(NVS_TAG, "Configuration saved");

	return true;
}

bool LoadNVS(UnitConfig_Typedef *data)
{
	nvs_handle handle;
	size_t size;
	esp_err_t err;
	uint32_t version;

	err = nvs_open(UNITCFG_NAMESPACE, NVS_READWRITE, &handle);

	if (err != 0)
	{
		ESP_LOGE(NVS_TAG, "nvs_open: %x", err);
		return false;
	}

	err = nvs_get_u32(handle, KEY_VERSION, &version);
	if (err != ESP_OK)
	{
		ESP_LOGE(NVS_TAG, "Incompatible versions (%d).", err);
		nvs_close(handle);
		return false;
	}

	size = sizeof(UnitConfig_Typedef);
	err = nvs_get_blob(handle, KEY_CONNECTION_INFO, data, &size);

	if (err != ESP_OK)
	{
		ESP_LOGE(NVS_TAG, "No Unit config record found (%d)", err);
		nvs_close(handle);
		return false;
	}

	nvs_close(handle);

	ESP_LOGI(NVS_TAG, "Configuration Loaded (%d) bytes", size);

	return true;
}

bool strContains(char *string, char *toFind)
{
	uint8_t slen = strlen(string);
	uint8_t tFlen = strlen(toFind);
	uint8_t found = 0;

	if (slen >= tFlen)
	{
		for (uint8_t s = 0, t = 0; s < slen; s++)
		{
			do
			{

				if (string[s] == toFind[t])
				{
					if (++found == tFlen)
						return true;
					s++;
					t++;
				}
				else
				{
					s -= found;
					found = 0;
					t = 0;
				}

			} while (found);
		}
		return true;
	}
	else
		return false;
}

bool InitLoadCfg()
{
	if (!LoadNVS(&UnitCfg))
	{
		Default_saving();
	}
	else
	{
		ESP_LOGI(NVS_TAG, "Unit Config Loading OK");
		// checking the data storage health
		if (!strstr(UnitCfg.FLASH_MEMORY, "OK"))
		{
			ESP_LOGE(NVS_TAG, "Saving the default configuration ..");
			Default_saving();
		}
	}
	return true;
}

void Default_saving()
{
	uint8_t mac[6];
	esp_efuse_mac_get_default(mac);
	sprintf(UnitCfg.UnitName, "HuBBoX-%02X:%02X:%02X", mac[3], mac[4], mac[5]);

	sprintf(UnitCfg.WifiCfg.AP_SSID, "%s-HuBBoX-%s",DEVICE_NAME_DEFAULT, DEFAULT_AP_SSID);
	strncpy(UnitCfg.WifiCfg.AP_PASS, DEFAULT_AP_PASSWORD, sizeof(UnitCfg.WifiCfg.AP_PASS));
	sprintf(UnitCfg.WifiCfg.AP_IP, DEFAULT_AP_IP);
	strncpy(UnitCfg.WifiCfg.STA_SSID, "", sizeof(UnitCfg.WifiCfg.STA_SSID));
	strncpy(UnitCfg.WifiCfg.STA_PASS, "", sizeof(UnitCfg.WifiCfg.STA_PASS));
	strncpy(UnitCfg.WifiCfg.STA_IP_STATIC, "", sizeof(UnitCfg.WifiCfg.STA_IP_STATIC));
	strncpy(UnitCfg.WifiCfg.STA_SUBNET_MASK, "", sizeof(UnitCfg.WifiCfg.STA_SUBNET_MASK));
	strncpy(UnitCfg.WifiCfg.STA_GATEWAY, "", sizeof(UnitCfg.WifiCfg.STA_GATEWAY));

	sprintf(UnitCfg.Company, "Deliled");
	sprintf(UnitCfg.OperatorName, "ROBOT-D001");
	sprintf(UnitCfg.RoomName, "Room 1");

	UnitCfg.DisinfictionTime = 0;
	UnitCfg.ActivationTime = 0;

	for (int i = 0; i < MAXSLAVES; i++)
	{
		UnitCfg.UVCSlaves[i].UVCTimeExecution = 0;
		UnitCfg.UVCSlaves[i].UVCLifeTime = 32400000;
		UnitCfg.UVCSlaves[i].NumberOfDisinfection = 0;
	}

	sprintf(UnitCfg.UnitTimeZone, "CET-1CEST-2,M3.5.0/02:00:00,M10.5.0/03:00:00");

	UnitCfg.Version = VERSION;

	sprintf(UnitCfg.FirmwareVersion, FIRMWAREVERSIONNAME);

	sprintf(UnitCfg.FLASH_MEMORY, "OK");

	if (SaveNVS(&UnitCfg))
	{
		ESP_LOGI(NVS_TAG, "Unit Config saving OK");
	}
	else
	{
		ESP_LOGE(NVS_TAG, "Unit Config saving NOT OK");
	}
}

void saveDataTask(bool savenvsFlag)
{
	if (savenvsFlag)
	{
		SaveNVS(&UnitCfg);
		savenvsFlag = false;
	}
	else
	{
		ESP_LOGE(NVS_TAG, "Unit Config NOT saved");
	}
}

void syncTime(time_t t, char tzone[64])
{
	struct tm tm_time;
	struct timeval tv_time;
	time_t epoch = t;
	char strftime_buf[64];

	// set timezone
	setenv("TZ", tzone, 1);
	tzset();

	// set time
	tv_time.tv_sec = epoch;
	tv_time.tv_usec = 0;

	settimeofday(&tv_time, 0);

	time(&epoch);

	localtime_r(&epoch, &tm_time);
	strftime(strftime_buf, sizeof(strftime_buf), "%c", &tm_time);
	ESP_LOGW(NVS_TAG, "The current date/time UTC is: %s", strftime_buf);
}

bool jsonparse(char *src, char *dst, char *label, unsigned short arrayindex)
{
	char *sp = 0, *ep = 0, *ic = 0;
	char tmp[64];

	sp = strstr(src, label);

	if (sp == NULL)
	{
		// ESP_LOGE(NVS_TAG, "label %s not found",label);
		return false;
	}

	sp = strchr(sp, ':');
	if (sp == NULL)
	{
		ESP_LOGE(NVS_TAG, "value start not found");
		return false;
	}

	if (sp[1] == '"')
	{
		sp++;
		ep = strchr(sp + 1, '"');
		ic = strchr(sp + 1, ',');
		if ((ep == NULL) || ((ep > ic) && (ic != NULL)))
		{
			ESP_LOGE(NVS_TAG, "type string parsing error");
			return false;
		}
	}
	else if (sp[1] == '[')
	{
		sp++;
		ep = strchr(sp + 1, ']');
		ic = strchr(sp + 1, ':');
		if ((ep == NULL) || ((ep > ic) && (ic != NULL)))
		{
			ESP_LOGE(NVS_TAG, "type array parsing error");
			return false;
		}

		ic = strchr(sp + 1, ',');
		if ((ic < ep) && (ic != NULL))
			ep = ic;

		for (int i = 0; i < arrayindex; i++)
		{
			sp = ep;
			ep = strchr(sp + 1, ',');

			if (ep == NULL)
			{
				ic = strchr(sp + 1, ']');
				ep = ic;
			}
		}

		if (sp[1] == '"')
		{
			sp++;
			ep = strchr(sp + 1, '"');
		}
	}
	else
	{
		ep = strchr(sp + 1, ',');
		if (ep == NULL)
			ep = strchr(sp + 1, '}');
		ic = strchr(sp + 1, ':');
		if ((ep == NULL) || ((ep > ic) && (ic != NULL)))
		{
			ESP_LOGE(NVS_TAG, "type int parsing error");
			return false;
		}
	}

	strncpy(tmp, sp + 1, ep - sp - 1);
	tmp[ep - sp - 1] = 0;

	memset(dst, 0x00, strlen(tmp) + 1);
	memcpy(dst, tmp, strlen(tmp));

	return true;
}