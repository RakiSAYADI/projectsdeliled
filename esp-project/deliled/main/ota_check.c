/*
 * ota_check.c
 *
 *  Created on: 17 juil. 2019
 *      Author: raki
 */
#include "esp_https_ota.h"
#include "esp_err.h"
#include "esp_partition.h"
#include "esp_spi_flash.h"
#include "esp_image_format.h"
#include "esp_secure_boot.h"
#include "esp_flash_encrypt.h"
#include "esp_spi_flash.h"

#include "sdkconfig.h"
#include "webservice.h"
#include "unitcfg.h"
#include "ota_check.h"

#define UPDATE_JSON_URL_HTTP		"http://3d-protect.fr/Update_firmware_data/deliled_bin.bin"
static const char *TAG = "CHECK_TASK";

esp_err_t validate_image_header(esp_app_desc_t *new_app_info) {
	if (new_app_info == NULL) {
		return ESP_ERR_INVALID_ARG;
	}

	const esp_partition_t *running = esp_ota_get_running_partition();
	esp_app_desc_t running_app_info;
	if (esp_ota_get_partition_description(running, &running_app_info) == ESP_OK) {
		ESP_LOGI(TAG, "Running firmware version: %s", running_app_info.version);
		ESP_LOGI(TAG, "firmware version online : %s", new_app_info->version);
	}

	if (memcmp(new_app_info->version, running_app_info.version,
			sizeof(new_app_info->version)) == 0) {
		ESP_LOGI(TAG, "Current running version is the same as a new !");
		return ESP_FAIL;
	} else {
		return ESP_OK;
	}
}

esp_https_ota_handle_t https_ota_handle = NULL;
esp_err_t err;
esp_app_desc_t app_desc;

void checking_ota() {
	esp_http_client_config_t config = { .url = (char*) UPDATE_JSON_URL_HTTP, };

	esp_https_ota_config_t ota_config = { .http_config = &config, };

	while (1) {
		err = esp_https_ota_begin(&ota_config, &https_ota_handle);
		ESP_LOGI(TAG, "Starting OTA CHECKING");
		if (err != ESP_OK) {
			ESP_LOGE(TAG, "ESP HTTPS OTA Begin failed");
		} else {
			ESP_LOGI(TAG, "ESP HTTPS OTA Begin succeed");
		}
		err = esp_https_ota_get_img_desc(https_ota_handle, &app_desc);
		if (err != ESP_OK) {
			ESP_LOGE(TAG, "esp_https_ota_read_img_desc failed");
		} else {
			ESP_LOGI(TAG, "esp_https_ota_read_img_desc succeed");
		}
		err = validate_image_header(&app_desc);
		if (err != ESP_OK) {
			ESP_LOGI(TAG, "This version is updated !");
			UnitData.ota_check = 0;
		} else {
			ESP_LOGW(TAG, "New version is Available !");
			UnitData.ota_check = 1;
		}
		err = esp_https_ota_finish(https_ota_handle);
		if (err != ESP_OK) {
			ESP_LOGE(TAG, "esp_https_ota_finish failed (No internet !)");
			UnitData.ota_check = 0;
		} else {
			ESP_LOGI(TAG, "esp_https_ota_finish succeed");
		}
		vTaskDelay(86400000 / portTICK_RATE_MS);
		//ESP_LOGI(TAG, "[APP] Free memory: %d bytes", esp_get_free_heap_size());
		//vTaskDelay(10000 / portTICK_RATE_MS);
	}
	vTaskDelete(NULL);
}

