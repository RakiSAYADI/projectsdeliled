
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

#include "sdkconfig.h"
#include "webservice.h"
#include "unitcfg.h"

#define FIRMWARE_VERSION	0.1
#define UPDATE_JSON_URL		"http://192.168.0.100:8000/deliled_bin.json"     // link for the json file
static const char *TAG = 	"OTA_TASK";

extern const uint8_t server_cert_pem_start[] asm("_binary_server_root_cert_pem_start");
extern const uint8_t server_cert_pem_end[] asm("_binary_server_root_cert_pem_end");

// receive buffer

char rcv_buffer[200];

esp_err_t _http_event_handler(esp_http_client_event_t *evt)
{
    switch(evt->event_id) {
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
            ESP_LOGD(TAG, "HTTP_EVENT_ON_HEADER, key=%s, value=%s", evt->header_key, evt->header_value);
            break;
        case HTTP_EVENT_ON_DATA:
            ESP_LOGD(TAG, "HTTP_EVENT_ON_DATA, len=%d", evt->data_len);
            if (!esp_http_client_is_chunked_response(evt->client))
            {
      				strncpy(rcv_buffer, (char*)evt->data, evt->data_len);
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

void ota_task()
{
	UnitData.UpdateInfo=0;

    ESP_LOGI(TAG, "Starting OTA - Waiting for network");

    /* Wait for the callback to set the CONNECTED_BIT in the
       event group.
    */

    while(WifiConnectedFlag==false)
    {
    	vTaskDelay(1000 / portTICK_PERIOD_MS);
    }

    ESP_LOGI(TAG,"Firmware Version is : %.1f\n\n", FIRMWARE_VERSION);

    ESP_LOGI(TAG, "Connected to WiFi network! Attempting to connect to server...");

    esp_http_client_config_t config = {
        .url = UPDATE_JSON_URL,
		.cert_pem = (char *)server_cert_pem_start,
        .event_handler = _http_event_handler,
    };

	esp_http_client_handle_t client = esp_http_client_init(&config);

	// downloading the json file

	esp_err_t err = esp_http_client_perform(client);
	if(err == ESP_OK) {

		// parse the json file

		cJSON *json = cJSON_Parse(rcv_buffer);
		if(json == NULL) ESP_LOGE(TAG,"downloaded file is not a valid json, aborting...\n");
		else {
			cJSON *version = cJSON_GetObjectItemCaseSensitive(json, "version");
			cJSON *file = 	 cJSON_GetObjectItemCaseSensitive(json, "file");

			// check the version

			if(!cJSON_IsNumber(version)) ESP_LOGE(TAG,"unable to read new version, aborting...\n");
			else
			{

				double new_version = version->valuedouble;
				if(new_version > FIRMWARE_VERSION)
				{
					UnitData.UpdateInfo=2;
					ESP_LOGE(TAG,"current firmware version (%.1f) is lower than the available one (%.1f), upgrading...\n", FIRMWARE_VERSION, new_version);
					if(cJSON_IsString(file) && (file->valuestring != NULL))
					{

						ESP_LOGE(TAG,"downloading and installing new firmware (%s)...\n", file->valuestring);

						esp_http_client_config_t ota_client_config = {
							.url = file->valuestring,
							.cert_pem = (char *)server_cert_pem_start,
						};

						esp_err_t ret = esp_https_ota(&ota_client_config);
						if (ret == ESP_OK)
						{

							ESP_LOGE(TAG,"OTA OK, restarting...\n");

							UnitData.UpdateInfo=0;

							vTaskDelay(2000 / portTICK_PERIOD_MS);

							esp_restart();

						}
						else
						{

							ESP_LOGE(TAG,"OTA failed...\n");

						}
					}

					else ESP_LOGE(TAG,"unable to read the new file name, aborting...\n");

				}

				else {ESP_LOGE(TAG,"current firmware version (%.1f) is greater or equal to the available one (%.1f), nothing to do...\n", FIRMWARE_VERSION, new_version);
				UnitData.UpdateInfo=1;
				}

			}
		}
	}

	else {ESP_LOGE(TAG,"unable to download the json file, aborting...\n");
	UnitData.UpdateInfo=1;}

	// cleanup

	esp_http_client_cleanup(client);

	vTaskDelay(2000 / portTICK_PERIOD_MS);

	UnitData.UpdateInfo=0;

/*
    esp_err_t ret = esp_https_ota(&config);
    if (ret == ESP_OK) {
        esp_restart();
    } else {
        ESP_LOGE(TAG, "Firmware upgrade failed");
    }
    while (1) {
        vTaskDelay(1000 / portTICK_PERIOD_MS);
    }*/
}

//xTaskCreate(&simple_ota_example_task, "ota_example_task", 8192, NULL, 5, NULL);
