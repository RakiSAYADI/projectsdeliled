/*
 * emailclient.c
 *
 *  Created on: Feb 18, 2019
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
#include "emailclient.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_wifi.h"
#include "esp_event_loop.h"
#include "esp_log.h"
#include "esp_system.h"
#include "nvs_flash.h"

#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include "lwip/netdb.h"
#include "lwip/dns.h"

#include "sdkconfig.h"

#define FROM_ADDR    "delitech.alert@gmail.com"
#define TO_ADDR      FROM_ADDR

#define FROM_MAIL "CO2 Alert mail <" FROM_ADDR ">"
#define TO_MAIL   "A Receiver " TO_ADDR

#define USER_PASS "maestro_user"


char payload_text[15][128];

void payloadBuild()
{

	char dt[64];
	struct tm timeinfo = { 0 };
	time_t tm=0;
	uint8_t mac[6];
	uint8_t rnd[6];
	char rndstr[13];
	uint32_t i=0;

	esp_efuse_mac_get_default(mac);
	esp_fill_random(&rnd,6);

	time(&tm);
    localtime_r(&tm, &timeinfo);
    strftime(dt, sizeof(dt), "%c", &timeinfo);

	memset(&rndstr,0,sizeof(rndstr));
	for (i=0;i<6;i++)
	{
		sprintf(rndstr,"%02X",rnd[i]);
	}

    //add date

    sprintf(payload_text[0],"Date : %s +1100\r\n",dt);
    sprintf(payload_text[1],"To: %s \r\n",UnitCfg.Email);
    sprintf(payload_text[2],"From: %s \r\n",FROM_MAIL);
    sprintf(payload_text[3],"Message-ID: <%08lX-%04X-%04X-%04X-%s@rfcpedant.example.org>\r\n",tm,mac[5]*256+mac[4],mac[3]*256+mac[2],mac[1]*256+mac[0],rndstr);
    sprintf(payload_text[4],"Subject: Maestro [%s] CO2 Level alert automatic message - Do Not reply\r\n",UnitCfg.UnitName);
    sprintf(payload_text[5],"\r\n");// empty line to divide headers from body, see RFC5322
    sprintf(payload_text[6],"Maestro [%s] signale qu'un niveau CO2 élevé a été détecté .\r\n",UnitCfg.UnitName);
    sprintf(payload_text[7],"Date : %s \r\n",dt);
    sprintf(payload_text[8],"\r\n");
    sprintf(payload_text[9],"\r\n");
    sprintf(payload_text[10],"Ceci est un message automatiquement généré par Maestro [%s] \r\n",UnitCfg.UnitName);
    sprintf(payload_text[11],"Merci de ne pas répondre à cet email.\r\n");
    sprintf(payload_text[12],"\r\n");
    payload_text[13][0]='\0';

    //printf(">%s\n",payload_text);
}

/*
static const char *payload_text[] = {
  "Date: Mon, 29 Nov 2010 21:54:29 +1100\r\n",
  "To: " TO_MAIL "\r\n",
  "From: " FROM_MAIL "\r\n",
  "Message-ID: <dcd7cb36-11db-484a-9f3b-e652a9858efd@"
  "rfcpedant.example.org>\r\n",
  "Subject: SMTP example message\r\n",
  "\r\n", // empty line to divide headers from body, see RFC5322
  "The body of the message starts here.\r\n",
  "\r\n",
  "It could be a lot of lines, could be MIME encoded, whatever.\r\n",
  "Check RFC5322.\r\n",
  NULL
};*/

struct upload_status {
  int lines_read;
};

static size_t payload_source(void *ptr, size_t size, size_t nmemb, void *userp)
{
  struct upload_status *upload_ctx = (struct upload_status *)userp;
  const char *data;

  if((size == 0) || (nmemb == 0) || ((size*nmemb) < 1)) {
    return 0;
  }

  data = payload_text[upload_ctx->lines_read];

  if(data) {
    size_t len = strlen(data);
    memcpy(ptr, data, len);
    upload_ctx->lines_read++;

    return len;
  }

  return 0;
}

void email_task()
{

	ESP_LOGI("CURL", "Email task started");
  payloadBuild();

  CURL *curl;
  CURLcode res = CURLE_OK;
  struct curl_slist *recipients = NULL;
  struct upload_status upload_ctx;

  upload_ctx.lines_read = 0;

  int x,y;

  for (x = 0; x < 15; x++)
  {
	  //Use of inner loop - Printing the arrays character by character
	  for (y = 0; y < 128; y++)
	  {
		  printf("%c", payload_text[x][y]);
	  }
  }

  curl = curl_easy_init();
  if(curl) {
    curl_easy_setopt(curl, CURLOPT_URL, "smtps://smtp.gmail.com:465");
    curl_easy_setopt(curl, CURLOPT_VERBOSE, true);
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
    curl_easy_setopt(curl, CURLOPT_USERNAME, FROM_ADDR);
    curl_easy_setopt(curl, CURLOPT_PASSWORD, USER_PASS);
    curl_easy_setopt(curl, CURLOPT_MAIL_FROM, FROM_ADDR);

    recipients = curl_slist_append(recipients, UnitCfg.Email);

    curl_easy_setopt(curl, CURLOPT_MAIL_RCPT, recipients);

    curl_easy_setopt(curl, CURLOPT_READFUNCTION, payload_source);
   	curl_easy_setopt(curl, CURLOPT_READDATA, &upload_ctx);
    curl_easy_setopt(curl, CURLOPT_UPLOAD, 1L);

    res = curl_easy_perform(curl);

    /* Check for errors */
    if(res != CURLE_OK)
      printf("curl_easy_perform() failed: %s\n", curl_easy_strerror(res));

    curl_slist_free_all(recipients);

    curl_easy_cleanup(curl);
  }else
	  printf("curl_easy_init() failed\n");

  vTaskDelete(NULL);

  return;
}
