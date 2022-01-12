/*
 * autolight.c
 *
 *  Created on: Feb 12, 2019
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
#include <stdlib.h>
#include <driver/dac.h>
#include <time.h>
#include <limits.h>
#include <sys/time.h>
#include "math.h"
#include "cJSON.h"

#include "sdkconfig.h"
#include "autolight.h"
#include "lightcontrol.h"
#include "unitcfg.h"

#define TAG "AUTOREG"

void autoLightWakeUpTask(uint8_t zone);

uint32_t cparttime = 0, phaseTimeStart = 0, phaseTimeEnd = 0, rgb = 0,
		durationLumTransition = 0;
uint8_t Curday = 0;
HSLStruct HSLtmp;

void autoLightWakeUp() {
	ESP_LOGI(TAG, "Start Auto Light Task !");
	// Init Light Stat

	struct timeval tv;
	struct tm now = { 0 };

	time_t nows = 0;
	uint16_t veille_zone_int;

	time(&nows);
	localtime_r(&nows, &now);

	while ((now.tm_year < (2016 - 1900))) {
		time(&nows);
		localtime_r(&nows, &now);
		delay(1000);
	}

	ESP_LOGI(TAG, "Time is correct , begin checking");

	while (1) {
		gettimeofday(&tv, NULL);

		localtime_r(&tv.tv_sec, &now);

		time(&nows);
		Curday = now.tm_wday;
		cparttime = nows % (3600 * 24) + (UnitCfg.timeZone * 3600);

		if ((cparttime == UnitCfg.alarmDay[Curday].autoTrigTime)
				&& (UnitCfg.alarmDay[Curday].state)) {

			printf("AutoTrigger Timer Switch light on\n");
			printf("Info : Now %d @ %d start at : %ld \n", Curday, cparttime,
					UnitCfg.alarmDay[Curday].autoTrigTime);
			veille_zone_int = strtol(UnitCfg.alarmDay[Curday].zones,
			NULL, 16);

			autoLightWakeUpTask(veille_zone_int);

		}
		delay(100);
	}
}

void autoLightWakeUpTask(uint8_t zone) {

	uint8_t cmd = 0, subcmdhue = 0, subcmdstab = 0;
	//radio apply LIGHT ON
	MilightHandler(LCMD_SWITCH_ON_OFF, LSUBCMD_SWITCH_ON, zone);
	delay(10);

	rgb = strtol(UnitCfg.alarmDay[Curday].hue, NULL, 16);
	RgbToHSL(rgb, &HSLtmp);

	// apply hue
	cmd = 3;
	subcmdhue = HSLtmp.Hue;

	MilightHandler(cmd, subcmdhue, zone);
	ESP_LOGI(TAG, "Light control cmd %d subcmd %d zone %d", cmd, subcmdhue,
			zone);
	delay(10);

	// apply saturation
	cmd = 9;
	subcmdstab = HSLtmp.Sat;
	MilightHandler(cmd, subcmdstab, zone);
	ESP_LOGI(TAG, "Light control cmd %d subcmd %d zone %d", cmd, subcmdstab,
			zone);
	delay(10);
	switch (UnitCfg.alarmDay[Curday].duration) {
	case 0:
		durationLumTransition = 5000;
		break;
	case 1:
		durationLumTransition = 10000;
		break;
	case 2:
		durationLumTransition = 20000;
		break;
	case 3:
		durationLumTransition = 30000;
		break;
	case 4:
		durationLumTransition = 60000;
		break;
	case 5:
		durationLumTransition = 120000;
		break;
	case 6:
		durationLumTransition = 300000;
		break;
	case 7:
		durationLumTransition = 600000;
		break;
	case 8:
		durationLumTransition = 900000;
		break;
	case 9:
		durationLumTransition = 1200000;
		break;
	case 10:
		durationLumTransition = 1500000;
		break;
	case 11:
		durationLumTransition = 1800000;
		break;
	case 12:
		durationLumTransition = 2100000;
		break;
	case 13:
		durationLumTransition = 2400000;
		break;
	case 14:
		durationLumTransition = 2700000;
		break;
	case 15:
		durationLumTransition = 3000000;
		break;
	case 16:
		durationLumTransition = 3300000;
		break;
	case 17:
		durationLumTransition = 3600000;
		break;
	case 18:
		durationLumTransition = 3900000;
		break;
	case 19:
		durationLumTransition = 4200000;
		break;
	case 20:
		durationLumTransition = 4500000;
		break;
	case 21:
		durationLumTransition = 4800000;
		break;
	case 22:
		durationLumTransition = 5100000;
		break;
	case 23:
		durationLumTransition = 5400000;
		break;
	case 24:
		durationLumTransition = 5700000;
		break;
	case 25:
		durationLumTransition = 6000000;
		break;
	case 26:
		durationLumTransition = 6300000;
		break;
	case 27:
		durationLumTransition = 6600000;
		break;
	case 28:
		durationLumTransition = 6900000;
		break;
	case 29:
		durationLumTransition = 7200000;
		break;
	default:
		durationLumTransition = 1000;
		break;
	}
	uint32_t progressTime = 0;
	float penteTransLum = 0;
	uint8_t transOutLum = 0;
	penteTransLum = (UnitCfg.alarmDay[Curday].finishLumVal
			- UnitCfg.alarmDay[Curday].startLumVal)
			/ (float) durationLumTransition;
	cmd = 7;
	while (progressTime < durationLumTransition) {
		transOutLum = (penteTransLum * progressTime)
				+ UnitCfg.alarmDay[Curday].startLumVal;
		MilightHandler(cmd, transOutLum, zone);
		progressTime += 100;
		delay(100);
	}
}

void autoLight() {
	xTaskCreate(&autoLightWakeUp, "autoLightWakeUp",
	configMINIMAL_STACK_SIZE * 3, NULL, 1, NULL);
}
