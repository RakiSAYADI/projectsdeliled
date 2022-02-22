#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_log.h"
#include "driver/uart.h"
#include "driver/gpio.h"
#include "soc/uart_struct.h"
#include "string.h"
#include <stdio.h>
#include <esp_err.h>
#include <esp_event.h>
#include "sdkconfig.h"
#include <stdlib.h>
#include <time.h>
#include "math.h"

#include "autolight.h"
#include "lightcontrol.h"
#include "unitcfg.h"
#include "adc.h"
#include "i2c.h"
#include "app_gpio.h"

#define TAG "AUTOREG"

void Pir_MonitorTask();
void ColorTemp_Controller();
void autoLightWakeUpTask(uint8_t zone);

AutoLightStateDef AutoLightState = AUTOL_STATE_OFF;

struct tm now = {0};
time_t CurrentTime = 0;

uint32_t cparttime = 0, phaseTimeStart = 0, phaseTimeEnd = 0, rgb = 0,
		 durationLumTransition = 0;
uint8_t Curday = 0;
HSLStruct HSLtmp;

void AutoLightStateMachine()
{
	struct timeval tv;

	time_t nows = 0;
	uint16_t veille_zone_int;

	time(&CurrentTime);
	localtime_r(&CurrentTime, &now);

	while ((now.tm_year < (2016 - 1900)))
	{
		time(&CurrentTime);
		localtime_r(&CurrentTime, &now);
		vTaskDelay(1000 / portTICK_PERIOD_MS);
	}

	// xTaskCreatePinnedToCore(&Pir_MonitorTask, "Pir_MonitorTask", 1024 * 2, NULL, 10, NULL, 1);
	xTaskCreatePinnedToCore(&ColorTemp_Controller, "ColorTemp_Controller", 2048, NULL, 10, NULL, 1);

	ESP_LOGI(TAG, "Time is correct , begin checking");

	while (1)
	{
		gettimeofday(&tv, NULL);

		localtime_r(&tv.tv_sec, &now);

		time(&nows);
		Curday = now.tm_wday;
		cparttime = nows % (3600 * 24) + (UnitCfg.UnitTimeZone * 3600);

		if ((cparttime == UnitCfg.alarmDay[Curday].autoTrigTime) && (UnitCfg.alarmDay[Curday].state))
		{

			printf("AutoTrigger Timer Switch light on\n");
			printf("Info : Now %d @ %d start at : %ld \n", Curday, cparttime,
				   UnitCfg.alarmDay[Curday].autoTrigTime);
			veille_zone_int = strtol(UnitCfg.alarmDay[Curday].zones,
									 NULL, 16);

			autoLightWakeUpTask(veille_zone_int);
		}
		delay(100);
	}

	vTaskDelete(NULL);
}

// Color temp Control routine

int8_t CtempOut = 0;

void ColorTemp_Controller()
{

	float h1 = 0, h2 = 0, h3 = 0, h4 = 0, h5 = 0;
	float t1 = 0, t2 = 0, t3 = 0, t4 = 0, t5 = 0;

	float a1 = 0, a2 = 0, a3 = 0, a4 = 0;
	float b1 = 0, b2 = 0, b3 = 0, b4 = 0;

	time_t now = 0;

	uint16_t cc_zone_int;

	while (1)
	{
		time(&now);
		now = now % (3600 * 24) + (UnitCfg.UnitTimeZone * 3600);

		h1 = UnitCfg.UserLcProfile.Ccp[0].CcTime;
		h2 = UnitCfg.UserLcProfile.Ccp[1].CcTime;
		h3 = UnitCfg.UserLcProfile.Ccp[2].CcTime;
		h4 = UnitCfg.UserLcProfile.Ccp[3].CcTime;
		h5 = UnitCfg.UserLcProfile.Ccp[4].CcTime;

		t1 = UnitCfg.UserLcProfile.Ccp[0].CcLevel;
		t2 = UnitCfg.UserLcProfile.Ccp[1].CcLevel;
		t3 = UnitCfg.UserLcProfile.Ccp[2].CcLevel;
		t4 = UnitCfg.UserLcProfile.Ccp[3].CcLevel;
		t5 = UnitCfg.UserLcProfile.Ccp[4].CcLevel;

		if (UnitCfg.UserLcProfile.CcEnb)
		{

			if (h2 != h1)
			{
				a1 = (t2 - t1) / (h2 - h1);
				b1 = t1 - (a1 * h1);
			}
			else
			{
				a1 = 0;
				b1 = t1 = UnitCfg.UserLcProfile.Ccp[0].CcLevel;
			}
			if (h3 != h2)
			{
				a2 = (t3 - t2) / (h3 - h2);
				b2 = t2 - (a2 * h2);
			}
			else
			{
				a2 = 0;
				b2 = t2 = UnitCfg.UserLcProfile.Ccp[1].CcLevel;
			}
			if (h4 != h3)
			{
				a3 = (t4 - t3) / (h4 - h3);
				b3 = t3 - (a3 * h3);
			}
			else
			{
				a3 = 0;
				b3 = t3 = UnitCfg.UserLcProfile.Ccp[2].CcLevel;
			}
			if (h5 != h4)
			{
				a4 = (t5 - t4) / (h5 - h4);
				b4 = t4 - (a4 * h4);
			}
			else
			{
				a4 = 0;
				b4 = t4 = UnitCfg.UserLcProfile.Ccp[3].CcLevel;
			}
			if ((now >= h1) && (now <= h2))
			{
				CtempOut = a1 * now + b1;
			}
			else if ((now >= h2) && (now <= h3))
			{
				CtempOut = a2 * now + b2;
			}
			else if ((now >= h3) && (now <= h4))
			{
				CtempOut = a3 * now + b3;
			}
			else if ((now >= h4) && (now <= h5))
			{
				CtempOut = a4 * now + b4;
			}
			else
			{
				CtempOut = UnitCfg.UserLcProfile.Ccp[4].CcLevel; // the CC will work forever
			}
			if (CtempOut > 100)
			{
				CtempOut = 100;
			}
			if (CtempOut < 0)
			{
				CtempOut = 0;
			}

			ESP_LOGI(TAG, "ACTC Level %d @ %ld", CtempOut, now);

			cc_zone_int = strtol(UnitCfg.UserLcProfile.ZoneCc, NULL, 16);

			MilightHandler(LCMD_SET_TEMP, (uint8_t)CtempOut, cc_zone_int & 0x0F);
		}
		vTaskDelay(1000 / portTICK_RATE_MS);
	}
	ESP_LOGI(TAG, "ACTC TASK EXIT");
	vTaskDelete(NULL);
}

void autoLightWakeUpTask(uint8_t zone)
{

	uint8_t cmd = 0, subcmdhue = 0, subcmdstab = 0;
	// radio apply LIGHT ON
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
	switch (UnitCfg.alarmDay[Curday].duration)
	{
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
	penteTransLum = (UnitCfg.alarmDay[Curday].finishLumVal - UnitCfg.alarmDay[Curday].startLumVal) / (float)durationLumTransition;
	cmd = 7;
	while (progressTime < durationLumTransition)
	{
		transOutLum = (penteTransLum * progressTime) + UnitCfg.alarmDay[Curday].startLumVal;
		MilightHandler(cmd, transOutLum, zone);
		progressTime += 100;
		delay(100);
	}
}

// PIR Low level Handler

bool PirTimeoutTask = false;
time_t PirTimeout = 0;
bool PirOutCmd = false;

void PirTimeoutRoutine()
{
	PirTimeoutTask = true;
	PirOutCmd = true;

	while (PirTimeout > 0)
	{
		PirTimeout--;
		// sprintf ("time of detection : %ld\n",PirTimeout);
		vTaskDelay(1000 / portTICK_RATE_MS);
	}

	PirOutCmd = false;
	PirTimeoutTask = false;
	vTaskDelete(NULL);
}

void Pir_MonitorTask()
{
	// pir
	while (1)
	{
		if (PirFlag == 1 && UnitCfg.UserLcProfile.PIRBrEnb)
		{
			PirFlag = 0;
			PirTimeout = UnitCfg.UserLcProfile.PirTimeout;
			if (PirTimeout == 0)
			{
				PirTimeout = 5;
			}
			// ESP_LOGI(TAG, "PIR Triggered + %ld",PirTimeout);
			if (!PirTimeoutTask)
			{
				xTaskCreatePinnedToCore(&PirTimeoutRoutine, "PirTimeoutRoutine", 2048, NULL, 5, NULL, 1);
			}
		}

		vTaskDelay(100 / portTICK_RATE_MS);
	}
}

// CO2
uint8_t zone = 0;
bool co2_alert_enable = false;
bool co2_triger_alert = false;

void Co2_MonitorTask()
{

	while (1)
	{
		zone = strtol(UnitCfg.Co2LevelSelect, NULL, 16);
		// co2
		if (UnitCfg.Co2LevelWarEnb)
		{
			if ((UnitData.aq_Co2Level > UnitCfg.Co2LevelWar) && (co2_alert_enable == 0))
			{
				co2_alert_enable = 1;
				co2_triger_alert = true;
				ESP_LOGI(TAG, "Co2 Warning triggered");
				// zone
				if (UnitCfg.Co2LevelZoneEnb)
				{
					UnitData.state = 0;
					ESP_LOGI(TAG, "Co2 zone Warning triggered");
					MilightHandler(LCMD_SWITCH_ON_OFF, LSUBCMD_SWITCH_ON, zone & 0x0F);
					vTaskDelay(50 / portTICK_RATE_MS);
					MilightHandler(LCMD_SET_SAT, 100, zone & 0x0F);
					vTaskDelay(50 / portTICK_RATE_MS);
					MilightHandler(LCMD_SET_MODE, 6, zone & 0x0F);
				}
			}
			// desativate co2 and init the light
			if ((UnitData.aq_Co2Level < UnitCfg.Co2LevelWar) && (co2_alert_enable == 1))
			{
				ESP_LOGI(TAG, "Co2 Warning off");
				co2_alert_enable = 0;
				co2_triger_alert = false;
				if (UnitCfg.Co2LevelZoneEnb)
				{
					UnitData.state = 0;
					MilightHandler(LCMD_SET_WHITE, 0, zone & 0x0F);
					vTaskDelay(100 / portTICK_RATE_MS);
					MilightHandler(LCMD_SET_WHITE, 0, zone & 0x0F);
					vTaskDelay(50 / portTICK_RATE_MS);
					MilightHandler(LCMD_SET_BRIGTHNESS, 100, zone & 0x0F);
				}
			}
		}
		if (UnitData.aq_Co2Level < 799)
		{
			UnitSetStatus(UNIT_STATUS_NORMAL);
		}
		else if (UnitData.aq_Co2Level < 1499)
		{
			UnitSetStatus(UNIT_STATUS_WARNING_CO2);
		}
		else
		{
			UnitSetStatus(UNIT_STATUS_ALERT_CO2);
		}
		vTaskDelay(1000 / portTICK_RATE_MS);
	}
}
