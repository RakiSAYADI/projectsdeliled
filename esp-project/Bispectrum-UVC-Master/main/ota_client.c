#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"

#include "esp_ota_ops.h"
#include "esp_http_client.h"
#include "esp_https_ota.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event_loop.h"
#include "cJSON.h"
#include "esp_log.h"
#include "string.h"

#include "esp_err.h"
#include "esp_partition.h"
#include "esp_spi_flash.h"
#include "esp_image_format.h"
#include "esp_secure_boot.h"
#include "esp_flash_encrypt.h"
#include "esp_spi_flash.h"

//#include <curl/curl.h>

#include "sdkconfig.h"
#include "webservice.h"
#include "unitcfg.h"

#define FIRMWARE_VERSION	0.1
#define UPDATE_JSON_URL_HTTP		"http://3d-protect.fr/Update_firmware_data/deliled_bin.json"     // link for the json file
const char *TAG = "OTA_TASK";

extern const uint8_t server_cert_pem_start[] asm("_binary_ca_cert_pem_start");
extern const uint8_t server_cert_pem_end[] asm("_binary_ca_cert_pem_end");

// receive buffer

char rcv_buffer[500];
char * URL[400];
uint32_t File_size;

esp_err_t validate_image_header_ota(esp_app_desc_t *new_app_info) {
	if (new_app_info == NULL) {
		return ESP_ERR_INVALID_ARG;
	}

	const esp_partition_t *running = esp_ota_get_running_partition();
	File_size = running->size;
	esp_app_desc_t running_app_info;
	if (esp_ota_get_partition_description(running, &running_app_info) == ESP_OK) {
		ESP_LOGI(TAG, "Running firmware version: %s", running_app_info.version);
	}

	if (memcmp(new_app_info->version, running_app_info.version,
			sizeof(new_app_info->version)) == 0) {
		ESP_LOGW(TAG,
				"Current running version is the same as a new. We will not continue the update.");
		UnitData.UpdateInfo = 1;
		return ESP_FAIL;
	}
	return ESP_OK;
}

void advanced_ota_example_task() {
	ESP_LOGI(TAG, "Starting Advanced OTA example");

	esp_err_t ota_finish_err = ESP_OK;
	esp_http_client_config_t config = { .url = (char*) URL, .cert_pem =
			(char *) server_cert_pem_start, };

	esp_https_ota_config_t ota_config = { .http_config = &config, };

	esp_https_ota_handle_t https_ota_handle = NULL;
	esp_err_t err = esp_https_ota_begin(&ota_config, &https_ota_handle);
	if (err != ESP_OK) {
		ESP_LOGE(TAG, "ESP HTTPS OTA Begin failed");
	} else {
		ESP_LOGI(TAG, "ESP HTTPS OTA Begin succeed");
	}

	esp_app_desc_t app_desc;
	err = esp_https_ota_get_img_desc(https_ota_handle, &app_desc);
	if (err != ESP_OK) {
		ESP_LOGE(TAG, "esp_https_ota_read_img_desc failed");
		goto ota_end;
	} else {
		ESP_LOGI(TAG, "esp_https_ota_read_img_desc succeed");
	}
	err = validate_image_header_ota(&app_desc);
	if (err != ESP_OK) {
		ESP_LOGE(TAG, "image header verification failed");
		goto ota_end;
	} else {
		ESP_LOGI(TAG, "image header verification succeed");
	}

	vTaskDelay(3000 / portTICK_PERIOD_MS);

	UnitData.UpdateInfo = 2;
	while (1) {
		UnitData.UpdateInfo = 2;
		err = esp_https_ota_perform(https_ota_handle);
		if (err != ESP_ERR_HTTPS_OTA_IN_PROGRESS) {
			break;
		}
		// esp_https_ota_perform returns after every read operation which gives user the ability to
		// monitor the status of OTA upgrade by calling esp_https_ota_get_image_len_read, which gives length of image
		// data read so far.
		UnitData.percent_ota = ((float) esp_https_ota_get_image_len_read(
				https_ota_handle) / (float) File_size) * (int) 100;
		ESP_LOGI(TAG, "Image bytes read: %d\n", UnitData.percent_ota);
	}

	ota_end: ota_finish_err = esp_https_ota_finish(https_ota_handle);
	if ((err == ESP_OK) && (ota_finish_err == ESP_OK)) {
		ESP_LOGI(TAG, "ESP_HTTPS_OTA upgrade successful. Rebooting ...");
		UnitData.UpdateInfo = 0;
		vTaskDelay(3000 / portTICK_PERIOD_MS);
		esp_restart();
	} else {
		UnitData.UpdateInfo = 1;
		vTaskDelay(3000 / portTICK_PERIOD_MS);
		ESP_LOGE(TAG, "ESP_HTTPS_OTA upgrade failed...");
	}
}

esp_err_t _http_event_handler(esp_http_client_event_t *evt) {
	switch (evt->event_id) {
	case HTTP_EVENT_ERROR:
		ESP_LOGD(TAG, "HTTP_EVENT_ERROR");
		break;
	case HTTP_EVENT_ON_CONNECTED:
		ESP_LOGD(TAG, "HTTP_EVENT_ON_CONNECTED");
		break;
	case HTTP_EVENT_HEADER_SENT:
		ESP_LOGD(TAG, "HTTP_EVENT_HEADER_SENT");
		break;
	case HTTP_EVENT_ON_HEADER:
		ESP_LOGD(TAG, "HTTP_EVENT_ON_HEADER, key=%s, value=%s", evt->header_key,
				evt->header_value);
		break;
	case HTTP_EVENT_ON_DATA:
		ESP_LOGD(TAG, "HTTP_EVENT_ON_DATA, len=%d", evt->data_len);
		if (!esp_http_client_is_chunked_response(evt->client)) {
			strncpy(rcv_buffer, (char*) evt->data, evt->data_len);
		}
		break;
	case HTTP_EVENT_ON_FINISH:
		ESP_LOGD(TAG, "HTTP_EVENT_ON_FINISH");
		break;
	case HTTP_EVENT_DISCONNECTED:
		ESP_LOGD(TAG, "HTTP_EVENT_DISCONNECTED");
		break;
	}
	return ESP_OK;
}

void ota_task() {
	ESP_LOGI(TAG, "OTA HTTP TASK \n");

	UnitData.UpdateInfo = 0;

	ESP_LOGI(TAG, "Starting OTA - Waiting for network");

	/* Wait for the callback to set the CONNECTED_BIT in the
	 event group.
	 */

	ESP_LOGI(TAG, "Firmware Version is : %.1f\n\n", FIRMWARE_VERSION);

	ESP_LOGI(TAG,
			"Connected to WiFi network! Attempting to connect to server...");

	esp_http_client_config_t config =
			{ .url = UPDATE_JSON_URL_HTTP, .cert_pem =
					(char *) server_cert_pem_start, .event_handler =
					_http_event_handler, };

	esp_http_client_handle_t client = esp_http_client_init(&config);

	// downloading the json file

	esp_err_t err = esp_http_client_perform(client);
	if (err == ESP_OK) {

		// parse the json file

		ESP_LOGI(TAG, "BUFFER IS : %s \n", rcv_buffer);

		cJSON *json = cJSON_Parse(rcv_buffer);
		if (json == NULL)
			ESP_LOGE(TAG, "downloaded file is not a valid json, aborting...\n");
		else {
			cJSON *version = cJSON_GetObjectItemCaseSensitive(json, "version");
			cJSON *file = cJSON_GetObjectItemCaseSensitive(json, "file");

			// check the version

			if (!cJSON_IsNumber(version))
				ESP_LOGE(TAG, "unable to read new version, aborting...\n");
			else {

				double new_version = version->valuedouble;
				if (new_version > FIRMWARE_VERSION) {
					ESP_LOGI(TAG,
							"current firmware version (%.1f) is lower than the available one (%.1f), upgrading...\n",
							FIRMWARE_VERSION, new_version);
					if (cJSON_IsString(file) && (file->valuestring != NULL)) {

						ESP_LOGI(TAG,
								"downloading and installing new firmware (%s)...\n",
								file->valuestring);

						sprintf((char*) URL, file->valuestring);

						//xTaskCreatePinnedToCore(&advanced_ota_example_task, "advanced_ota_example_task", 1024 * 8, NULL, 2, NULL,1);
						advanced_ota_example_task();

					}

					else
						ESP_LOGE(TAG,
								"unable to read the new file name, aborting...\n");

				}

				else {
					ESP_LOGE(TAG,
							"current firmware version (%.1f) is greater or equal to the available one (%.1f), nothing to do...\n",
							FIRMWARE_VERSION, new_version);

				}
			}
		}
	} else {
		ESP_LOGE(TAG, "unable to download the json file, aborting...\n");
	}

	// cleanup

	ESP_LOGI(TAG, "Clean up request http!");

	esp_http_client_cleanup(client);

	vTaskDelay(1000 / portTICK_PERIOD_MS);

	UnitData.UpdateInfo = 0;

	vTaskDelete(NULL);
}

