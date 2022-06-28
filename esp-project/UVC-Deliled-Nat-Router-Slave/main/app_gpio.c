/*
 * app_gpio.c
 *
 *  Created on: 19 août 2020
 *      Author: raki
 */
#include "string.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/gpio.h"
#include "driver/ledc.h"
#include "sdkconfig.h"
#include "cJSON.h"
#include "esp_system.h"
#include "esp_event.h"
#include "esp_event_loop.h"
#include "nvs_flash.h"
#include "freertos/portmacro.h"
#include "freertos/event_groups.h"
#include "esp_log.h"

#include "system_init.h"
#include "unitcfg.h"
#include "uvc_task.h"

int cntrl_pins[4] = {27, 26, 25, 33};

#define PIR_GPIO 16

const char *GPIO_TAG = "app_gpio";

#define RelayStateOFF 0
#define RelayStateON 1

#define UVRelay 0
#define RedLightRelay 1
#define GreenLightRelay 2
#define BuzzerRelay 3

esp_err_t err;

bool set_relay_state(int relay, uint32_t level)
{
	if ((relay >= 0) && (relay < 4))
	{
		err = gpio_set_level(cntrl_pins[relay], level);
	}
	else
		return false;
	if (err == 0)
		return true;
	else
		return false;
}

void redRelayAlert()
{
	ESP_LOGI(GPIO_TAG, "warning task is on !");
	while (1)
	{
		if (getUnitState() == UNIT_STATUS_UVC_STARTING)
		{
			set_relay_state(RedLightRelay, RelayStateON);
			delay(500);
			set_relay_state(RedLightRelay, RelayStateOFF);
		}
		else if (getUnitState() == UNIT_STATUS_UVC_ERROR)
		{
			set_relay_state(RedLightRelay, RelayStateON);
		}
		else
		{
			set_relay_state(RedLightRelay, RelayStateOFF);
		}
		delay(500);
	}
	vTaskDelete(NULL);
}

void buzzerRelayAlert()
{
	ESP_LOGI(GPIO_TAG, "Buzzzer task is on !");
	while (1)
	{
		if (getUnitState() == UNIT_STATUS_UVC_STARTING)
		{
			set_relay_state(BuzzerRelay, RelayStateON);
			delay(500);
			set_relay_state(BuzzerRelay, RelayStateOFF);
			delay(2000);
		}
		else
		{
			set_relay_state(BuzzerRelay, RelayStateOFF);
			delay(500);
		}
	}
	vTaskDelete(NULL);
}

void uvcRelayAlert()
{
	ESP_LOGI(GPIO_TAG, "UVC task is on !");
	while (1)
	{
		if (getUnitState() == UNIT_STATUS_UVC_TREATEMENT)
		{
			set_relay_state(UVRelay, RelayStateON);
		}
		else
		{
			set_relay_state(UVRelay, RelayStateOFF);
		}
		delay(500);
	}
	vTaskDelete(NULL);
}

void greenRelayAlert()
{
	ESP_LOGI(GPIO_TAG, "Green task is on !");
	while (1)
	{
		if (getUnitState() == UNIT_STATUS_IDLE || getUnitState() == UNIT_STATUS_UVC_TREATEMENT)
		{
			set_relay_state(GreenLightRelay, RelayStateON);
		}
		else
		{
			set_relay_state(GreenLightRelay, RelayStateOFF);
		}
		delay(500);
	}
	vTaskDelete(NULL);
}

void RelayStatusTask()
{
	// initialize the gpio
	for (int i = 0; i < 4; i++)
	{
		gpio_pad_select_gpio(cntrl_pins[i]);
		gpio_set_direction(cntrl_pins[i], GPIO_MODE_OUTPUT);
		// setting all relay OFF
		gpio_set_level(cntrl_pins[i], 0);
	}

	xTaskCreate(&redRelayAlert, "redRelayAlert", 2048, NULL, 5, NULL);
	xTaskCreate(&uvcRelayAlert, "uvcRelayAlert", 2048, NULL, 5, NULL);
	xTaskCreate(&greenRelayAlert, "greenRelayAlert", 2048, NULL, 5, NULL);
	xTaskCreate(&buzzerRelayAlert, "buzzerRelayAlert", 2048, NULL, 5, NULL);

	gpio_pad_select_gpio(PIR_GPIO);
	gpio_set_direction(PIR_GPIO, GPIO_MODE_INPUT);

	while (1)
	{
		if ((gpio_get_level(GPIO_NUM_16) == 1) && (getUnitState() == UNIT_STATUS_UVC_TREATEMENT))
		{
			detectionEventTrigered = true;
			ESP_LOGI(GPIO_TAG, "STOP UVC TREATEMENT, WE HAVE DETECTION !");
		}
		delay(50);
	}
}

void relayStatInit()
{
	// relay tasks
	xTaskCreate(&RelayStatusTask, "RelayStatusTask", configMINIMAL_STACK_SIZE * 3, NULL, 1, NULL);
}
