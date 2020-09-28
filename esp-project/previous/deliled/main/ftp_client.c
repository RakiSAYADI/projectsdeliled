/*
 * ftc_client.c
 *
 *  Created on: Dec 26, 2018
 *      Author: mdt
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
#include "stdlib.h"
#include "stdbool.h"

#include <curl/curl.h>

#include "webservice.h"
#include "unitcfg.h"
#include "sntp_client.h"
#include "sdkconfig.h"


#define TAG "FTP_CLIENT"

#define MAX_FTP_FILE_SIZE 1000000

char *ftp_buffer;
uint32_t ftp_buffer_size=0;

bool curlTaskEnb=false;
void curl_task();

#define FTP_BUFFER_SIZE 1100000

char fulladd[128];

void ftp_task()
{

	char txt[256];
	uint8_t mac[6];
	char mactxt[20];

	ESP_LOGI(TAG, "ftp task Started");

	esp_efuse_mac_get_default(mac);
	sprintf(mactxt,"%02X%02X%02X%02X%02X%02X",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);

    while((WifiConnectedFlag==false)||(sntpTimeSetFlag==false)||(UnitCfg.FtpConfig.FtpLogEnb==false))
    {
    	vTaskDelay(1000 / portTICK_PERIOD_MS);
    }


    heap_caps_malloc_extmem_enable(100);

    ftp_buffer=malloc(FTP_BUFFER_SIZE);

    memset(ftp_buffer,0,FTP_BUFFER_SIZE);

	if (ftp_buffer==NULL)
	{
		ESP_LOGE(TAG, "Buffer malloc error ... Halt");
		vTaskDelete(NULL);
	}
	else
		ESP_LOGI(TAG, "Buffer malloc %d bytes OK",FTP_BUFFER_SIZE);


	sprintf(ftp_buffer,"MAC,Update time,Temperature(C),Humidity,ALS(Lux),CO2(ppm),TVOC(ppb),AQ Status,Last detection time\r\n");


	ftp_buffer_size = strlen(ftp_buffer);

    while(1)
    {
    	char udt[64];
    	char ldt[64];

        localtime_r(&UnitData.UpdateTime, &sntp_timeinfo);
        strftime(udt, sizeof(udt), "%c", &sntp_timeinfo);

        localtime_r(&UnitData.LastDetTime, &sntp_timeinfo);
        strftime(ldt, sizeof(ldt), "%c", &sntp_timeinfo);

		sprintf(txt,"%s,%s,%0.1f,%0.1f,%d,%d,%d,%d,%s\r\n",mactxt,udt,UnitData.Temp,UnitData.Humidity,UnitData.Als,UnitData.aq_Co2Level
					,UnitData.aq_Tvoc,UnitData.aq_status,ldt);

		memcpy(ftp_buffer+ftp_buffer_size,txt,strlen(txt));

		ftp_buffer_size+=strlen(txt);

		ESP_LOGI(TAG,"Added to buffer %d bytes, total %d bytes",strlen(txt),ftp_buffer_size);

		if (ftp_buffer_size>=MAX_FTP_FILE_SIZE)
		{
			ESP_LOGI(TAG,"Sending File %s.csv to server",udt);


			sprintf(fulladd,"%s/%s.csv",UnitCfg.FtpConfig.Server,udt);

			curlTaskEnb=true;
			xTaskCreatePinnedToCore(&curl_task, "curl_task", 8000, NULL, 1, NULL,1);

			while( curlTaskEnb==true)
			{
				vTaskDelay(10 / portTICK_PERIOD_MS);
			}

			ESP_LOGI(TAG,"Clearing buffer");

			memset(ftp_buffer,0,FTP_BUFFER_SIZE);

			ftp_buffer_size = 0;
		}

    	vTaskDelay(10000 / portTICK_PERIOD_MS);
    }
    vTaskDelete(NULL);
}

struct WriteThis {
  const char *readptr;
  size_t sizeleft;
};

static size_t read_callback(void *ptr, size_t size, size_t nmemb, void *userp)
{
  struct WriteThis *upload = (struct WriteThis *)userp;
  size_t max = size*nmemb;

  if(max < 1)
    return 0;

  if(upload->sizeleft) {
    size_t copylen = max;
    if(copylen > upload->sizeleft)
      copylen = upload->sizeleft;
    memcpy(ptr, upload->readptr, copylen);
    upload->readptr += copylen;
    upload->sizeleft -= copylen;
    return copylen;
  }

  return 0;
}


void curl_task()
{
  CURL *curl;
  CURLcode res;

  struct WriteThis upload;

  upload.readptr = ftp_buffer;
  upload.sizeleft = ftp_buffer_size;

  ftp_buffer[ftp_buffer_size]=0;

  /* In windows, this will init the winsock stuff */
  res = curl_global_init(CURL_GLOBAL_DEFAULT);
  /* Check for errors */
  if(res != CURLE_OK) {
	  ESP_LOGE(TAG, "curl_global_init() failed: %s\n",curl_easy_strerror(res));

    curlTaskEnb = false;
    vTaskDelete(NULL);
  }

  /* get a curl handle */
  curl = curl_easy_init();

  if(curl)
  {


	char fulluserid[64];

	sprintf(fulluserid,"%s:%s",UnitCfg.FtpConfig.UserName,UnitCfg.FtpConfig.Password);

    /* First set the URL, the target file */
    curl_easy_setopt(curl, CURLOPT_URL,fulladd);

    /* User and password for the FTP login */
    curl_easy_setopt(curl, CURLOPT_USERPWD, fulluserid);

    /* Now specify we want to UPLOAD data */
    curl_easy_setopt(curl, CURLOPT_UPLOAD, 1L);

    /* we want to use our own read function */
    curl_easy_setopt(curl, CURLOPT_READFUNCTION, read_callback);

    /* pointer to pass to our read function */
    curl_easy_setopt(curl, CURLOPT_READDATA, &upload);

    /* get verbose debug output please */
    //curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);

    /* Set the expected upload size. */
    curl_easy_setopt(curl, CURLOPT_INFILESIZE_LARGE,(curl_off_t)upload.sizeleft);

    /* Perform the request, res will get the return code */
    res = curl_easy_perform(curl);
    /* Check for errors */
    if(res != CURLE_OK)
    	ESP_LOGE(TAG, "curl_easy_perform() failed: %s\n",curl_easy_strerror(res));

    ESP_LOGI(TAG,"curl_easy_perform() passed");

    /* always cleanup */
    curl_easy_cleanup(curl);
  }
  curl_global_cleanup();

  curlTaskEnb = false;

  vTaskDelete(NULL);
}
