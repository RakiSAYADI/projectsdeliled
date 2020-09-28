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
#include "email_test_client.h"

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

#define FROM_ADDR    "maestro@delitech.eu"

#define FROM_MAIL "Raki Sayadi <" FROM_ADDR ">"

#define USER_PASS "DELITECHTUNISIE2019??"

#define SMTP_URL "smtp://delitech-eu.mail.protection.outlook.com:25"

char payload_text[18][128];

void payloadTestBuild()
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
	sprintf(payload_text[1],"To: <%s> \r\n",UnitCfg.Email);
	sprintf(payload_text[2],"From: %s \r\n",FROM_MAIL);
	sprintf(payload_text[3],"Message-ID: <%08lX-%04X-%04X-%04X-%s@rfcpedant.example.org>\r\n",tm,mac[5]*256+mac[4],mac[3]*256+mac[2],mac[1]*256+mac[0],rndstr);
	sprintf(payload_text[4],"Subject: Application Lumi’Air – Email test [%s] \r\n",UnitCfg.UnitName);
	sprintf(payload_text[5],"\r\n");// empty line to divide headers from body, see RFC5322
	sprintf(payload_text[6],"Bonjour,\r\n");
	sprintf(payload_text[7],"Cet email vous a été envoyé pour donner suite à votre demande sur l’application Lumi’Air. \r\n");
	sprintf(payload_text[8],"Si la qualité de votre air venait à se détériorer, vous recevrez un nouveau message. \r\n");
	sprintf(payload_text[9],"Merci d’utiliser l’application Lumi’Air. \r\n");
	sprintf(payload_text[10],"\r\n");
	sprintf(payload_text[11],"Ce message vous a été envoyé automatiquement, merci de ne pas y répondre. \r\n");
	sprintf(payload_text[12],"\r\n");
	sprintf(payload_text[13],"Cordialement, \r\n");
	sprintf(payload_text[14],"Votre boitier Lumi’Air de Maestro™. \r\n");
	sprintf(payload_text[15],"\r\n");
	payload_text[15][0]='\0';

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

void email_test_task()
{

	ESP_LOGI("CURL", "Email task started");
  payloadTestBuild();

  CURL *curl;
  CURLcode res = CURLE_OK;
  struct curl_slist *recipients = NULL;
  struct upload_status upload_ctx;

  upload_ctx.lines_read = 0;

  /*int x,y;

  for (x = 0; x < 15; x++)
  {
	  //Use of inner loop - Printing the arrays character by character
	  for (y = 0; y < 128; y++)
	  {
		  printf("%c", payload_text[x][y]);
	  }
  }*/

  curl = curl_easy_init();
  if(curl)
  {
    curl_easy_setopt(curl, CURLOPT_URL, SMTP_URL);
    curl_easy_setopt(curl, CURLOPT_VERBOSE, true);
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
    curl_easy_setopt(curl, CURLOPT_USERNAME, FROM_ADDR);
    curl_easy_setopt(curl, CURLOPT_PASSWORD, USER_PASS);
    curl_easy_setopt(curl, CURLOPT_MAIL_FROM, FROM_ADDR);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10000);

    /* Set the authorisation identity (identity to act as) */
    //curl_easy_setopt(curl, CURLOPT_SASL_AUTHZID, "ursel");

    /* Force PLAIN authentication */
    curl_easy_setopt(curl, CURLOPT_LOGIN_OPTIONS, "AUTH=PLAIN");

    recipients = curl_slist_append(recipients, UnitCfg.Email);

    curl_easy_setopt(curl, CURLOPT_MAIL_RCPT, recipients);

    curl_easy_setopt(curl, CURLOPT_READFUNCTION, payload_source);
    curl_easy_setopt(curl, CURLOPT_READDATA, &upload_ctx);
    curl_easy_setopt(curl, CURLOPT_UPLOAD, 1L);

    res = curl_easy_perform(curl);

    /* Check for errors */
    if(res != CURLE_OK)
    {
      printf("curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
    }
    else
    {
    	ESP_LOGI("CURL", "Email task finished successfully !");
    }

    curl_slist_free_all(recipients);

    curl_easy_cleanup(curl);

  }else
	  printf("curl_easy_init() failed\n");

  vTaskDelete(NULL);

  return;
}
