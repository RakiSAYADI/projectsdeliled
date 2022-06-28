#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include <pthread.h>
#include "esp_log.h"

#include "sdkconfig.h"

#include "app_gpio.h"
#include "nat_router.h"
#include "system_init.h"
#include "unitcfg.h"
#include "tcp_server.h"

const char *UVC_TAG = "UVC";

const int uvcTimeTransition = 50;

uint32_t timeUVC = 0;

bool stopEventTrigerred = false;

void startUVC(uint32_t alertTime, uint32_t uvcTime)
{
	alertTime *= 1000;
	uvcTime *= 1000;
	timeUVC = 0;
	stopEventTrigerred = false;
	ESP_LOGI(UVC_TAG, "Starting UVC treatement with alert : %d", alertTime);
	while (alertTime > 0)
	{
		alertTime -= uvcTimeTransition;
		timeUVC += uvcTimeTransition;
		if (stopEventTrigerred)
		{
			setUnitStatus(UNIT_STATUS_UVC_ERROR);
			break;
		}
		delay(uvcTimeTransition);
	}

	timeUVC = 0;

	if (getUnitState() == UNIT_STATUS_UVC_STARTING)
	{
		ESP_LOGI(UVC_TAG, "Starting UVC treatement with uvc : %d", uvcTime);
		setUnitStatus(UNIT_STATUS_UVC_TREATEMENT);
		while (uvcTime > 0)
		{
			uvcTime -= uvcTimeTransition;
			timeUVC += uvcTimeTransition;
			if (stopEventTrigerred)
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
