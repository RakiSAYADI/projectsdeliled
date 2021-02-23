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
#include <esp_event.h>
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
#include "lightcontrol.h"

UnitConfig_Typedef UnitCfg;

#define UNITCFG_NAMESPACE "unitcfgnvs"
#define KEY_CONNECTION_INFO "unitcfg"
#define KEY_VERSION "key"
#define KEY_VERSION_VAL 0x01

char* NVS_TAG = "NVS";

int SaveNVS(UnitConfig_Typedef *data) {
	nvs_handle handle;
	esp_err_t err = ESP_FAIL;

	err = nvs_open(UNITCFG_NAMESPACE, NVS_READWRITE, &handle);

	if (err != ESP_OK) {
		ESP_LOGE(NVS_TAG, "nvs_open: %x", err);
		return -1;
	}

	err = nvs_set_blob(handle, KEY_CONNECTION_INFO, data,
			sizeof(UnitConfig_Typedef));

	if (err != ESP_OK) {
		ESP_LOGE(NVS_TAG, "Error Setting NVS Blob (%d).", err);
		nvs_close(handle);
		return -1;
	}

	err = nvs_set_u32(handle, KEY_VERSION, KEY_VERSION_VAL);

	if (err != ESP_OK) {
		ESP_LOGE(NVS_TAG, "Error Setting Key version (%d).", err);
		nvs_close(handle);
		return -1;
	}

	err = nvs_commit(handle);

	if (err != ESP_OK) {
		ESP_LOGE(NVS_TAG, "Error Writing NVS (%d).", err);
		nvs_close(handle);
		return -1;
	}

	nvs_close(handle);

	ESP_LOGI(NVS_TAG, "Configuration saved");

	return (0);
}

int LoadNVS(UnitConfig_Typedef *data) {
	nvs_handle handle;
	size_t size;
	esp_err_t err;
	uint32_t version;

	err = nvs_open(UNITCFG_NAMESPACE, NVS_READWRITE, &handle);

	if (err != 0) {
		ESP_LOGE(NVS_TAG, "nvs_open: %x", err);
		return -1;
	}

	err = nvs_get_u32(handle, KEY_VERSION, &version);
	if (err != ESP_OK) {
		ESP_LOGE(NVS_TAG, "Incompatible versions (%d).", err);
		nvs_close(handle);
		return -1;
	}

	size = sizeof(UnitConfig_Typedef);
	err = nvs_get_blob(handle, KEY_CONNECTION_INFO, data, &size);

	if (err != ESP_OK) {
		ESP_LOGE(NVS_TAG, "No Unit config record found (%d)", err);
		nvs_close(handle);
		return -1;
	}

	nvs_close(handle);

	ESP_LOGI(NVS_TAG, "Configuration Loaded (%d) bytes", size);

	//ESP_LOGI(NVS_TAG, "Configuration Loaded (%d) bytes", sizeof(UnitCfg));

	return 0;
}

int InitLoadCfg() {
	if (LoadNVS(&UnitCfg) != 0) {
		Default_saving();
	} else {
		ESP_LOGI(NVS_TAG, "Unit Config Loading OK");
		//checking the data storage health
		if (!(strContains(UnitCfg.FLASH_MEMORY, "OK") == 1)) {
			ESP_LOGE(NVS_TAG, "Saving the default configuration ..");
			Default_saving();
		}

	}
	return (0);
}

void Default_saving() {

	sprintf(UnitCfg.UnitName, ROBOTNAME);

	sprintf(UnitCfg.Zones.ZONE1, "Zone 1");
	sprintf(UnitCfg.Zones.ZONE2, "Zone 2");
	sprintf(UnitCfg.Zones.ZONE3, "Zone 3");
	sprintf(UnitCfg.Zones.ZONE4, "Zone 4");

	for (int i = 0; i < 7; i++) {
		UnitCfg.alarmDay[i].state = false;
		UnitCfg.alarmDay[i].autoTrigTime = 0;
		UnitCfg.alarmDay[i].duration = 0;
		sprintf(UnitCfg.alarmDay[i].hue, "00A6FF");
		sprintf(UnitCfg.alarmDay[i].zones, "F");
		UnitCfg.alarmDay[i].startLumVal = 0;
		UnitCfg.alarmDay[i].finishLumVal = 0;
	}

	for (int i = 0; i < 6; i++) {
		sprintf(UnitCfg.ColortrProfile[i].name, "Ambiance %d", i + 1);
		sprintf(UnitCfg.ColortrProfile[i].Hue, "00A6FF");
	}

	sprintf(UnitCfg.WifiCfg.WIFI_SSID, "ssid");
	sprintf(UnitCfg.WifiCfg.WIFI_PASS, "password");

	UnitCfg.Version = VERSION;

	sprintf(UnitCfg.FirmwareVersion, FIRMWAREVERSIONNAME);

	sprintf(UnitCfg.FLASH_MEMORY, "OK");

	if (SaveNVS(&UnitCfg) == 0) {
		ESP_LOGI(NVS_TAG, "Unit Config saving OK");
	} else {
		ESP_LOGE(NVS_TAG, "Unit Config saving NOT OK");
	}
}

void saveDataTask(bool savenvsFlag) {

	if (savenvsFlag) {
		SaveNVS(&UnitCfg);
		savenvsFlag = false;
	}
}

void syncTime(time_t t, uint32_t tzone) {
	struct tm tm_time;
	struct timeval tv_time;
	time_t epoch = t;
	char strftime_buf[64];

	//set timezone

	char tz[10];
	int32_t tzc = 0;

	tzc = tzone / 3600;

	if (tzc == 0) {
		sprintf(tz, "CET0");
	} else if (tzc < 0) {
		sprintf(tz, "CET%d", tzc);
	} else {
		sprintf(tz, "CET-%d", tzc);
	}

	setenv("TZ", tz, 1);
	tzset();

	// set time
	tv_time.tv_sec = epoch;
	tv_time.tv_usec = 0;

	settimeofday(&tv_time, 0);

	time(&epoch);

	localtime_r(&epoch, &tm_time);
	strftime(strftime_buf, sizeof(strftime_buf), "%c", &tm_time);
	ESP_LOGE(NVS_TAG, "The current date/time UTC is: %s", strftime_buf);
}
