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
#include <stdlib.h>
#include "stdbool.h"

#include "main.h"

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
			ESP_LOGI(NVS_TAG, "Saving the default configuration ..");
			Default_saving();
		}

	}
	return (0);
}

void Default_saving() {
//	uint8_t mac[6];
//	esp_efuse_mac_get_default(mac);
//
//	sprintf(UnitCfg.UnitName, "UVCROBOT-%02X:%02X:%02X", mac[3], mac[4],
//			mac[5]);
	sprintf(UnitCfg.UnitName, UVCROBOTNAME);
	sprintf(UnitCfg.Company, "Deliled");
	sprintf(UnitCfg.OperatorName, "ROBOT-D001");
	sprintf(UnitCfg.RoomName, "Room 1");

	UnitCfg.DisinfictionTime = 0;
	UnitCfg.ActivationTime = 0;

	sprintf(UnitCfg.FLASH_MEMORY, "OK");

	if (SaveNVS(&UnitCfg) == 0) {
		ESP_LOGI(NVS_TAG, "Unit Config saving OK");
	} else {
		ESP_LOGE(NVS_TAG, "Unit Config saving NOT OK");
	}
}
