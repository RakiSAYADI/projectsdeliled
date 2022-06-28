#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include <pthread.h>
#include "esp_log.h"

#include "sdkconfig.h"

#include "app_gpio.h"
#include "system_init.h"
#include "unitcfg.h"
#include "udp_client.h"

const char *UVC_TAG = "UVC";

const int uvcTimeTransition = 50;

bool stopEventTrigered = false;
bool detectionEventTrigered = false;

void startUVC(uint32_t alertTime, uint32_t uvcTime)
{
	alertTime *= 1000;
	uvcTime *= 1000;
	ESP_LOGI(UVC_TAG, "Starting UVC treatement with alert : %d", alertTime);
	stopEventTrigered = false;
	detectionEventTrigered = false;
	while (alertTime > 0)
	{
		alertTime -= uvcTimeTransition;
		if (stopEventTrigered)
		{
			setUnitStatus(UNIT_STATUS_UVC_ERROR);
			break;
		}
		delay(uvcTimeTransition);
	}

	if (getUnitState() == UNIT_STATUS_UVC_STARTING)
	{
		ESP_LOGI(UVC_TAG, "Starting UVC treatement with uvc : %d", uvcTime);
		setUnitStatus(UNIT_STATUS_UVC_TREATEMENT);
		while (uvcTime > 0)
		{
			uvcTime -= uvcTimeTransition;
			if (detectionEventTrigered)
			{
				setUnitStatus(UNIT_STATUS_UVC_STARTING);
				delay(10000);
				setUnitStatus(UNIT_STATUS_UVC_ERROR);
				break;
			}
			if (stopEventTrigered)
			{
				setUnitStatus(UNIT_STATUS_UVC_ERROR);
				break;
			}
			delay(uvcTimeTransition);
		}
	}
}

void *uvc_status_thread(void *p)
{
	while (true)
	{
		if (getUnitState() == UNIT_STATUS_UVC_STARTING)
		{
			startUVC(UnitCfg.DisinfictionTime, UnitCfg.ActivationTime);

			if (getUnitState() == UNIT_STATUS_UVC_ERROR)
			{
				ESP_LOGE(UVC_TAG, "UVC treatement is failed");
			}
			else
			{
				setUnitStatus(UNIT_STATUS_IDLE);
				ESP_LOGI(UVC_TAG, "UVC treatement is successfull ");
			}
			saveDataTask(true);
		}
		delay(uvcTimeTransition);
	}
}

void uvcStatInit()
{
	pthread_t t1;
	pthread_create(&t1, NULL, uvc_status_thread, NULL);
}
