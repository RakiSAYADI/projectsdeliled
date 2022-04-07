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
#include <stdlib.h>
#include <time.h>
#include "math.h"

#include "autolight.h"
#include "lightcontrol.h"
#include "unitcfg.h"
#include "adc.h"
#include "i2c.h"
#include "app_gpio.h"

#include "sdkconfig.h"

#define TAG "AUTOREG"

void Pir_MonitorTask();
void ColorTemp_Controller();
void autoLightWakeUpTask();

AutoLightStateDef AutoLightState = AUTOL_STATE_OFF;

struct tm now = {0};
time_t CurrentTime = 0;

uint32_t cparttime = 0, phaseTimeStart = 0, phaseTimeEnd = 0, rgb = 0;
uint8_t Curday = 0;
HSLStruct HSLtmp;

void AutoLightStateMachine()
{
	struct timeval tv;

	time_t nows = 0;

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
		cparttime = nows % (3600 * 24) + (UnitCfg.timeZone * 3600);

		if ((cparttime == UnitCfg.alarmDay[Curday].autoTrigTime) && (UnitCfg.alarmDay[Curday].state))
		{
			printf("AutoTrigger Timer Switch light on\n");
			printf("Info : Now %d @ %d start at : %ld \n", Curday, cparttime, UnitCfg.alarmDay[Curday].autoTrigTime);
			autoLightWakeUpTask();
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
		now = now % (3600 * 24) + (UnitCfg.timeZone * 3600);

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

void autoLightWakeUpTask()
{
	uint8_t cmd = 0, subcmdhue = 0, subcmdstab = 0, transOutLum = 0;
	uint32_t progressTime = 0;
	float penteTransLum = 0;
	const uint16_t transPeriode = DELAY_LIGHT_TRANSITION;
	const uint16_t transFrequancy = transPeriode * 2;
	const uint8_t zone = 15;

	// radio apply LIGHT ALL OFF
	MilightHandler(LCMD_SWITCH_ON_OFF, LSUBCMD_SWITCH_OFF, zone);
	delay(DELAY_LIGHT_TRANSITION);

	for (int i = 0; i < zoneNumber; i++)
	{
		if (UnitCfg.ColortrProfile[UnitCfg.alarmDay[Curday].ambID].zoneAmbiance[i].zoneState)
		{
			// radio apply LIGHT ON
			MilightHandler(LCMD_SWITCH_ON_OFF, LSUBCMD_SWITCH_ON, UnitCfg.ColortrProfile[UnitCfg.alarmDay[Curday].ambID].zoneAmbiance[i].zoneId);
			ESP_LOGI(TAG, "Light control cmd %d subcmd %d zone %d", LCMD_SWITCH_ON_OFF, LSUBCMD_SWITCH_ON, UnitCfg.ColortrProfile[UnitCfg.alarmDay[Curday].ambID].zoneAmbiance[i].zoneId);
			delay(DELAY_LIGHT_TRANSITION);

			if (!UnitCfg.ColortrProfile[UnitCfg.alarmDay[Curday].ambID].zoneAmbiance[i].colorState)
			{
				rgb = strtol(UnitCfg.ColortrProfile[UnitCfg.alarmDay[Curday].ambID].zoneAmbiance[i].Hue, NULL, 16);
				RgbToHSL(rgb, &HSLtmp);

				// apply hue
				cmd = LCMD_SET_COLOR;
				subcmdhue = HSLtmp.Hue;

				MilightHandler(cmd, subcmdhue, UnitCfg.ColortrProfile[UnitCfg.alarmDay[Curday].ambID].zoneAmbiance[i].zoneId);
				ESP_LOGI(TAG, "Light control cmd %d subcmd %d zone %d", cmd, subcmdhue, UnitCfg.ColortrProfile[UnitCfg.alarmDay[Curday].ambID].zoneAmbiance[i].zoneId);
				delay(DELAY_LIGHT_TRANSITION);

				// apply saturation
				cmd = LCMD_SET_SAT;
				subcmdstab = HSLtmp.Sat;

				MilightHandler(cmd, subcmdstab, UnitCfg.ColortrProfile[UnitCfg.alarmDay[Curday].ambID].zoneAmbiance[i].zoneId);
				ESP_LOGI(TAG, "Light control cmd %d subcmd %d zone %d", cmd, subcmdstab, UnitCfg.ColortrProfile[UnitCfg.alarmDay[Curday].ambID].zoneAmbiance[i].zoneId);
				delay(DELAY_LIGHT_TRANSITION);
			}
			else
			{
				// apply white
				cmd = LCMD_SET_TEMP;
				MilightHandler(cmd, UnitCfg.ColortrProfile[UnitCfg.alarmDay[Curday].ambID].zoneAmbiance[i].white, UnitCfg.ColortrProfile[UnitCfg.alarmDay[Curday].ambID].zoneAmbiance[i].zoneId);
				ESP_LOGI(TAG, "Light control cmd %d subcmd %d zone %d", cmd, UnitCfg.ColortrProfile[UnitCfg.alarmDay[Curday].ambID].zoneAmbiance[i].white, UnitCfg.ColortrProfile[UnitCfg.alarmDay[Curday].ambID].zoneAmbiance[i].zoneId);
				delay(DELAY_LIGHT_TRANSITION);
			}
		}
	}

	penteTransLum = (UnitCfg.alarmDay[Curday].finishLumVal - UnitCfg.alarmDay[Curday].startLumVal) / (float)(UnitCfg.alarmDay[Curday].duration * 1000);
	cmd = LCMD_SET_BRIGTHNESS;
	while (progressTime < (UnitCfg.alarmDay[Curday].duration * 1000))
	{
		switch (UnitCfg.alarmDay[Curday].alarmOption)
		{
		case 0:
			transOutLum = 100;
			break;
		case 1:
			transOutLum = (penteTransLum * progressTime) + UnitCfg.alarmDay[Curday].startLumVal;
			break;
		case 2:
			transOutLum = ((UnitCfg.alarmDay[Curday].finishLumVal - UnitCfg.alarmDay[Curday].startLumVal) / 2) *
							  sin(((M_TWOPI / (transFrequancy * 5)) * progressTime) - M_PI_2) +
						  ((UnitCfg.alarmDay[Curday].finishLumVal + UnitCfg.alarmDay[Curday].startLumVal) / 2);
			break;
		case 3:
			transOutLum = (((UnitCfg.alarmDay[Curday].finishLumVal - UnitCfg.alarmDay[Curday].startLumVal) / 2) *
							   (sin(((M_TWOPI / (transFrequancy * 5)) * progressTime) - M_PI_2) / abs(sin(((M_TWOPI / (transFrequancy * 5)) * progressTime) - M_PI_2))) +
						   ((UnitCfg.alarmDay[Curday].finishLumVal + UnitCfg.alarmDay[Curday].startLumVal) / 2));
			break;
		}
		MilightHandler(cmd, transOutLum, zone);
		progressTime += transPeriode;
		delay(transPeriode);
	}
	delay(DELAY_LIGHT_TRANSITION);
	if (UnitCfg.alarmDay[Curday].alarmOff)
	{
		MilightHandler(LCMD_SWITCH_ON_OFF, LSUBCMD_SWITCH_OFF, zone);
	}
	else
	{
		MilightHandler(cmd, UnitCfg.alarmDay[Curday].finishLumVal, zone);
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
