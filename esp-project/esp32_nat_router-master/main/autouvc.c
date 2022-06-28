#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_log.h"
#include <time.h>

#include "autouvc.h"
#include "unitcfg.h"
#include "system_init.h"
#include "smtp_client.h"

#include "sdkconfig.h"

#define TAG "AUTOREG"

void AutoUVCDevice();

struct tm auto_timeinfo = {0};
time_t now = 0;

uint8_t Curday = 0;

// auto time Control routine

void autoLightTime()
{
	time(&now);
	localtime_r(&now, &auto_timeinfo);

	while ((auto_timeinfo.tm_year < (2016 - 1900)))
	{
		time(&now);
		localtime_r(&now, &auto_timeinfo);
		delay(1000);
	}

	ESP_LOGI(TAG, "Time is correct , begin checking");

	while (true)
	{
		// check time
		time(&now);
		localtime_r(&now, &auto_timeinfo);
		Curday = auto_timeinfo.tm_wday;
		now = auto_timeinfo.tm_hour * 3600 + auto_timeinfo.tm_min * 60 + auto_timeinfo.tm_sec;

		if ((now == UnitCfg.autoUvc[Curday].autoTrigTime) && (UnitCfg.autoUvc[Curday].state))
		{
			ESP_LOGI(TAG, "AutoTrigger Timer Start UVC light");
			ESP_LOGI(TAG, "Info : Now %d @ %ld start at : %ld ", Curday, now, UnitCfg.autoUvc[Curday].autoTrigTime);
			UnitCfg.DisinfictionTime = UnitCfg.autoUvc[Curday].DisinfictionTime;
			UnitCfg.ActivationTime = UnitCfg.autoUvc[Curday].ActivationTime;
			setUnitStatus(UNIT_STATUS_UVC_STARTING);
		}
		delay(1000);
	}
	vTaskDelete(NULL);
}

void AutoUVCDevice()
{
	xTaskCreate(&autoLightTime, "autoLightTime", 4096, NULL, 5, NULL);
}