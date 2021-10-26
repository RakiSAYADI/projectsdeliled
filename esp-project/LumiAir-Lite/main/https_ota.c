#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_event.h"
#include "esp_log.h"
#include "esp_ota_ops.h"
#include "esp_http_client.h"
#include "esp_https_ota.h"
#include "nvs.h"
#include "nvs_flash.h"

#include "sdkconfig.h"

#include "https_ota.h"
#include "webservice.h"

#define OTA_URL_SIZE 256

const char *OTA_TAG = "https_ota";

const char *UPDATE_URL_HTTPS = "http://3d-protect.fr/Update_firmware_data/deliled_bin.bin";

bool otaEnable = false;
bool otaNotNeeded = false;
bool otaIsDone = false;

uint8_t otaProgress = 0;
uint32_t partitionSize = 0;

esp_err_t validate_image_header(esp_app_desc_t *new_app_info)
{
    if (new_app_info == NULL)
    {
        return ESP_ERR_INVALID_ARG;
    }

    const esp_partition_t *running = esp_ota_get_running_partition();
    partitionSize = running->size;
    esp_app_desc_t running_app_info;
    if (esp_ota_get_partition_description(running, &running_app_info) == ESP_OK)
    {
        ESP_LOGI(OTA_TAG, "Running firmware version: %s", running_app_info.version);
    }

    if (memcmp(new_app_info->version, running_app_info.version, sizeof(new_app_info->version)) == 0)
    {
        ESP_LOGW(OTA_TAG, "Current running version is the same as a new. We will not continue the update.");
        otaNotNeeded = true;
        return ESP_FAIL;
    }

    return ESP_OK;
}

esp_err_t _http_client_init_cb(esp_http_client_handle_t http_client)
{
    esp_err_t err = ESP_OK;
    /* Uncomment to add custom headers to HTTP request */
    // err = esp_http_client_set_header(http_client, "Custom-Header", "Value");
    return err;
}

void advanced_ota_task(void *pvParameter)
{
    bool otaFailed = false;
    esp_https_ota_handle_t https_ota_handle = NULL;
    while (1)
    {
        if (WifiConnectedFlag && otaEnable)
        {
            ESP_LOGI(OTA_TAG, "Starting Advanced OTA example");

            otaNotNeeded = false;

            esp_err_t ota_finish_err = ESP_OK;
            esp_http_client_config_t config = {
                .url = (char *)UPDATE_URL_HTTPS,
                .cert_pem = (char *)server_cert_pem_start,
                .timeout_ms = 10,
                .keep_alive_enable = true,
            };

            config.skip_cert_common_name_check = true;

            esp_https_ota_config_t ota_config = {
                .http_config = &config,
                .http_client_init_cb = _http_client_init_cb, // Register a callback to be invoked after esp_http_client is initialized
            };

            esp_err_t err = esp_https_ota_begin(&ota_config, &https_ota_handle);
            if (err != ESP_OK)
            {
                ESP_LOGE(OTA_TAG, "ESP HTTPS OTA Begin failed");
                otaFailed = true;
                goto ota_end;
            }

            esp_app_desc_t app_desc;
            err = esp_https_ota_get_img_desc(https_ota_handle, &app_desc);
            if (err != ESP_OK)
            {
                ESP_LOGE(OTA_TAG, "esp_https_ota_read_img_desc failed");
                otaFailed = true;
                goto ota_end;
            }
            err = validate_image_header(&app_desc);
            if (err != ESP_OK)
            {
                ESP_LOGE(OTA_TAG, "image header verification failed");
                otaFailed = true;
                goto ota_end;
            }

            while (1)
            {
                err = esp_https_ota_perform(https_ota_handle);
                if (err != ESP_ERR_HTTPS_OTA_IN_PROGRESS)
                {
                    break;
                }
                // esp_https_ota_perform returns after every read operation which gives user the ability to
                // monitor the status of OTA upgrade by calling esp_https_ota_get_image_len_read, which gives length of image
                // data read so far.
                otaProgress = ((float)esp_https_ota_get_image_len_read(https_ota_handle) / (float)partitionSize) * 100;
                ESP_LOGD(OTA_TAG, "Image bytes read: %d", otaProgress);
            }

            if (esp_https_ota_is_complete_data_received(https_ota_handle) != true)
            {
                // the OTA image was not completely received and user can customise the response to this situation.
                ESP_LOGE(OTA_TAG, "Complete data was not received.");
                otaFailed = true;
                goto ota_end;
            }
            else
            {
                ota_finish_err = esp_https_ota_finish(https_ota_handle);
                if ((err == ESP_OK) && (ota_finish_err == ESP_OK))
                {
                    ESP_LOGI(OTA_TAG, "ESP_HTTPS_OTA upgrade successful. Rebooting ...");
                    otaIsDone = true;
                    vTaskDelay(3000 / portTICK_PERIOD_MS);
                    esp_restart();
                }
                else
                {
                    if (ota_finish_err == ESP_ERR_OTA_VALIDATE_FAILED)
                    {
                        ESP_LOGE(OTA_TAG, "Image validation failed, image is corrupted");
                    }
                    ESP_LOGE(OTA_TAG, "ESP_HTTPS_OTA upgrade failed 0x%x", ota_finish_err);
                    otaFailed = true;
                    goto ota_end;
                }
            }
        }
        vTaskDelay(1000 / portTICK_PERIOD_MS);
    ota_end:
        if (otaFailed)
        {
            otaFailed = false;
            otaEnable = false;
            esp_https_ota_abort(https_ota_handle);
            ESP_LOGE(OTA_TAG, "ESP_HTTPS_OTA upgrade failed");
        }
    }
    vTaskDelete(NULL);
}
