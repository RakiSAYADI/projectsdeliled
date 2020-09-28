#include <string.h>
#include <stdlib.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_log.h"
#include "esp_system.h"

#include <curl/curl.h>

/* Constants that aren't configurable in menuconfig */
#define WEB_URL  "https://postman-echo.com:443/get"
//#define WEB_URL "https://api.github.com/repos/whoshuu/cpr/contributors?anon=true&key=value"
#define certificat_path "/home/raki/Bureau/iobit/deliled_310319/deliled/main/ca-certificates.crt"

static const char *TAG = "CURL_REQUEST";

void curl_get_task ()
{
	CURL *hnd;

	CURLcode ret = CURLE_OK;

	//curl_global_init(CURL_GLOBAL_DEFAULT);

	hnd= curl_easy_init();

	ESP_LOGI(TAG, "STARTING API REQUEST !");

	if (hnd)
	{

		curl_easy_setopt(hnd, CURLOPT_CUSTOMREQUEST, "GET");
		curl_easy_setopt(hnd, CURLOPT_URL, WEB_URL);
		curl_easy_setopt(hnd, CURLOPT_CAPATH, certificat_path);

		curl_easy_setopt(hnd, CURLOPT_SSL_VERIFYPEER, 1L);
		curl_easy_setopt(hnd, CURLOPT_SSL_VERIFYHOST, 2L);

		curl_easy_setopt(hnd, CURLOPT_NOPROGRESS, 1L);
		curl_easy_setopt(hnd, CURLOPT_USERPWD, "user:pass");
		curl_easy_setopt(hnd, CURLOPT_USERAGENT, "curl/7.64.1");
        curl_easy_setopt(hnd, CURLOPT_MAXREDIRS, 50L);
        curl_easy_setopt(hnd, CURLOPT_TCP_KEEPALIVE, 1L);

        //struct curl_slist *headers = NULL;
        //headers = curl_slist_append(headers, "Cache-Control: no-cache");
		//headers = curl_slist_append(headers, "accept-encoding: gzip, deflate");

		//ESP_LOGI(TAG, "SETTING HEADERS !");

		//curl_easy_setopt(hnd, CURLOPT_HTTPHEADER, headers);

        char* url;
        long response_code;
        double elapsed;

        curl_easy_getinfo(hnd, CURLINFO_RESPONSE_CODE, &response_code);
        curl_easy_getinfo(hnd, CURLINFO_TOTAL_TIME, &elapsed);
        curl_easy_getinfo(hnd, CURLINFO_EFFECTIVE_URL, &url);

		ESP_LOGI(TAG, "STARTING PERFORM !");

		ret = curl_easy_perform(hnd);


		if(ret != CURLE_OK)
		{
			ESP_LOGE(TAG,"curl_easy_perform() failed: %s, num = %d \n",curl_easy_strerror(ret),ret);
		}
		else
		{
			ESP_LOGI(TAG, "API GET SUCCESSFUL !\n");
			ESP_LOGI(TAG, "URL: %s \n",url);
			ESP_LOGI(TAG, "respond: %ld \n",response_code);
			ESP_LOGI(TAG, "elapsed: %lf \n",elapsed);
		}
		curl_easy_cleanup(hnd);
	}
    vTaskDelete(NULL);
}
