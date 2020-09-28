/*
 * sntp_client.c
 *
 *  Created on: Dec 26, 2018
 *      Author: mdt
 */

#include <string.h>
#include <time.h>
#include <sys/time.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event_loop.h"
#include "esp_log.h"
#include "esp_attr.h"
#include "esp_sleep.h"
#include "nvs_flash.h"
#include "math.h"

#include "lwip/err.h"
#include "lwip/apps/sntp.h"

#include "sdkconfig.h"
#include "unitcfg.h"
#include "webservice.h"

static const char *TAG = "SNTP_CLIENT";


bool sntpTimeSetFlag=false;
time_t sntp_now = 0;
struct tm sntp_timeinfo = { 0 };

int dayofweek(int d,int m, int y)
{
	static int t[]={0,3,2,5,0,3,5,1,4,6,2,4};
	y -= m<3;
	return (y+y/4 -y/100 +y/400 + t[m-1] +d) %7;
}

int32_t somme_co2=0;
int32_t n0=0;
int32_t n1=0;
int32_t n2=0;
int32_t compter=0;
int8_t day =0;
char jour [64];

void indice_calcul()
{

	while(1)
	{

		time_t t = time(NULL);
		struct tm tm = *localtime(&t);
		day = dayofweek(tm.tm_mday,tm.tm_mon+1,tm.tm_year+1900);

		if (day==0){sprintf(jour,"Dimanche");}
		if (day==1){sprintf(jour,"Lundi");}
		if (day==2){sprintf(jour,"Mardi");}
		if (day==3){sprintf(jour,"Mercredi");}
		if (day==4){sprintf(jour,"Jeudi");}
		if (day==5){sprintf(jour,"Vendredi");}
		if (day==6){sprintf(jour,"Samedi");}

		ESP_LOGD(TAG, "Aujourd'hui est = %s\n",jour);

		if ((day==0)|(day==6))
		{
			ESP_LOGD(TAG, "l'ICONE ne fonctionne pas les samedi et dimanche ! \n");
		}
		else
		{
	
			compter++;

			somme_co2 +=UnitData.aq_Co2Level;

			ESP_LOGD(TAG, "somme=%d,compter=%d \n",somme_co2,compter);

			if (compter==600)
			{

				double valeur_co2;
				valeur_co2=(double)somme_co2/600.0;

				double f1;
				double f2;
				float ICONE;

				if (valeur_co2<=1000) {n0++;}
				else if (valeur_co2<1700) {n1++;}
				else {n2++;}

				f1=((double)n1/((double)n0+(double)n1+(double)n2));
				f2=((double)n2/((double)n0+(double)n1+(double)n2));

				ICONE=(2.5/log10(2.0))*log10(1+f1+3*f2);

				if (ICONE<0.5) {UnitData.Indice_Confinement=0;}
				else if ((ICONE==0.5)||(ICONE<1.5)) {UnitData.Indice_Confinement=1;}
				else if ((ICONE==1.5)||(ICONE<2.5)) {UnitData.Indice_Confinement=2;}
				else if ((ICONE==2.5)||(ICONE<3.5)) {UnitData.Indice_Confinement=3;}
				else if ((ICONE==3.5)||(ICONE<4.5)) {UnitData.Indice_Confinement=4;}
				else {UnitData.Indice_Confinement=5;}

				ESP_LOGD(TAG, "valeur moyenne de co2 =%f,n0=%d,n1=%d,n2=%d,f1=%f,f2=%f,ICONE=%f,indice=%d \n",valeur_co2,n0,n1,n2,f1,f2,ICONE,UnitData.Indice_Confinement);

				compter=0;

				somme_co2=0;

			}
		}

		vTaskDelay(1000 / portTICK_PERIOD_MS);
	}
}

void sntp_task()
{

	ESP_LOGI(TAG, "stnp task Started");

    while(WifiConnectedFlag==false)
    {
    	vTaskDelay(1000 / portTICK_PERIOD_MS);
    }

    time(&sntp_now);
    localtime_r(&sntp_now, &sntp_timeinfo);
    // Is time set? If not, tm_year will be (1970 - 1900).
    if (sntp_timeinfo.tm_year < (2016 - 1900))
    {
        ESP_LOGI(TAG, "Time is not set yet. Connecting to WiFi and getting time over NTP.");

        ESP_LOGI(TAG, "Initializing SNTP");
        sntp_setoperatingmode(SNTP_OPMODE_POLL);
        sntp_setservername(0, "pool.ntp.org");
        sntp_init();

        // wait for time to be set

        int retry = 0;
        const int retry_count = 10;
        while(sntp_timeinfo.tm_year < (2016 - 1900) && ++retry < retry_count) {
            ESP_LOGI(TAG, "Waiting for system time to be set... (%d/%d)", retry, retry_count);
            vTaskDelay(2000 / portTICK_PERIOD_MS);
            time(&sntp_now);
            localtime_r(&sntp_now, &sntp_timeinfo);
        }

        // update 'now' variable with current time
        time(&sntp_now);
    }
    char strftime_buf[64];

    // Set timezone to Eastern Standard Time and print local time

    char tz[10];

    if (UnitCfg.UnitTimeZone==0)
    {
    	sprintf(tz,"GMT0");
    }
    else if (UnitCfg.UnitTimeZone<0)
    {
    	sprintf(tz,"<GMT%d>%d",abs(UnitCfg.UnitTimeZone),abs(UnitCfg.UnitTimeZone));
	}
    else
	{
    	sprintf(tz,"<GMT+%d>-%d",abs(UnitCfg.UnitTimeZone),abs(UnitCfg.UnitTimeZone));
	}

      setenv("TZ",tz, 1);
      tzset();

    localtime_r(&sntp_now, &sntp_timeinfo);
    strftime(strftime_buf, sizeof(strftime_buf), "%c", &sntp_timeinfo);
    ESP_LOGI(TAG, "The current date/time in Timezone GMT %d [%s] is: %s",UnitCfg.UnitTimeZone,tz,strftime_buf);
	if (UnitCfg.Summer_time)
	{
		ESP_LOGI(TAG, "Summer time is Enabled");
		struct timeval tv;
		gettimeofday(&tv, NULL);
		tv.tv_sec += 3600;
		settimeofday(&tv, NULL);
		UnitCfg.summer_count=true;
	}
	else
	{
		UnitCfg.summer_count=false;
	}

    xTaskCreatePinnedToCore(&indice_calcul, "indice_calcul", 4000, NULL, 1, NULL,1);

    sntpTimeSetFlag = true;

    vTaskDelete(NULL);
}
