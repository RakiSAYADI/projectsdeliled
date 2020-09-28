#include <string.h>
#include <stdlib.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_log.h"
#include "esp_system.h"

#include <curl/curl.h>

/* Constants that aren't configurable in menuconfig */
#define WEB_URL  "http://3d-protect.fr/Update_firmware_data/cert.pem"

static const char *TAG = "CURL_REQUEST";

int i;

/* the function to invoke as the data recieved */
size_t static write_callback_func(void *buffer,
                        size_t size,
                        size_t nmemb,
                        void *userp)
{
    char **response_ptr =  (char**)userp;

    /* assuming the response is a string */
    *response_ptr = strndup(buffer, (size_t)(size *nmemb));

    return ((size_t)(size *nmemb));

}

void curl_get_task ()
{

	CURL *curl;
	CURLcode res;
	char *response = NULL;

	curl_global_init(CURL_GLOBAL_DEFAULT);

	curl = curl_easy_init();

	ESP_LOGI(TAG, "cURL START !");

	if(curl)
	{
		curl_easy_setopt(curl, CURLOPT_URL, WEB_URL);

		curl_easy_setopt(curl, CURLOPT_VERBOSE, 0L);

		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);

		curl_easy_setopt(curl, CURLOPT_CERTINFO, 1L);

		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback_func);

		curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);

		res = curl_easy_perform(curl);

		ESP_LOGI(TAG, "cURL is : %d !",res);

		if (!res)
		{
			printf("%s\n", response);
		}

		curl_easy_cleanup(curl);
	}

	ESP_LOGI(TAG, "cURL END !");

	vTaskDelete(NULL);

}
