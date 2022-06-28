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

#include "unitcfg.h"

UnitConfig_Typedef UnitCfg;

#define UNITCFG_NAMESPACE "unitcfgnvs"
#define KEY_CONNECTION_INFO "unitcfg"
#define KEY_VERSION "key"
#define KEY_VERSION_VAL 0x01

char *NVS_TAG = "NVS";

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

void Default_saving()
{
	sprintf(UnitCfg.UnitName, UVCROBOTNAME);
	sprintf(UnitCfg.Company, "Deliled");
	sprintf(UnitCfg.OperatorName, "ROBOT-D001");
	sprintf(UnitCfg.RoomName, "Room 1");

	UnitCfg.DisinfictionTime = 10;
	UnitCfg.ActivationTime = 30;

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
