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

AutoLightStateDef AutoLightState = AUTOL_STATE_OFF;

struct tm now = {0};
time_t CurrentTime = 0;

void AutoLightStateMachine()
{
	// Init Light Stat

	//Radio
	//MilightHandler(LCMD_SWITCH_ON_OFF,LSUBCMD_SWITCH_OFF,15);

	//0-10V
	//dac_output_voltage(DAC_CHANNEL_1, 0);
	//DacLightStatOn=false;

	time(&CurrentTime);
	localtime_r(&CurrentTime, &now);

	while ((now.tm_year < (2016 - 1900)))
	{
		time(&CurrentTime);
		localtime_r(&CurrentTime, &now);
		vTaskDelay(1000 / portTICK_PERIOD_MS);
	}

	//xTaskCreatePinnedToCore(&Pir_MonitorTask, "Pir_MonitorTask", 1024 * 2, NULL, 10, NULL, 1);
	xTaskCreatePinnedToCore(&ColorTemp_Controller, "ColorTemp_Controller", 2048, NULL, 10, NULL, 1);

	/*
	char txt0[64];
	uint8_t Curday;
	uint32_t cparttime;
	struct timeval tv;
	time_t nows = 0;
	
	while (1)
	{
		gettimeofday(&tv, NULL);

		localtime_r(&tv.tv_sec, &now);
		strftime(txt0, sizeof(txt0), "%R", &now);

		time(&nows);
		cparttime = nows % (3600 * 24) + (UnitCfg.UnitTimeZone * 3600);

		time(&CurrentTime);
		localtime_r(&CurrentTime, &now);

		Curday = now.tm_wday;

		vTaskDelay(100 / portTICK_RATE_MS);
	}
	*/
	vTaskDelete(NULL);
}

// Color temp Control routine

int8_t CtempOut = 0;

void ColorTemp_Controller()
{

	float h1 = 0, h2 = 0, h3 = 0;
	float t1 = 0, t2 = 0, t3 = 0;

	float a1 = 0, b1 = 0;
	float a2 = 0, b2 = 0;

	time_t now = 0;

	uint16_t cc_zone_int;

	while (1)
	{
		time(&now);
		now = now % (3600 * 24) + (UnitCfg.UnitTimeZone * 3600);

		h1 = UnitCfg.UserLcProfile.Ccp[0].CcTime;
		h2 = UnitCfg.UserLcProfile.Ccp[1].CcTime;
		h3 = UnitCfg.UserLcProfile.Ccp[2].CcTime;

		t1 = UnitCfg.UserLcProfile.Ccp[0].CcLevel;
		t2 = UnitCfg.UserLcProfile.Ccp[1].CcLevel;
		t3 = UnitCfg.UserLcProfile.Ccp[2].CcLevel;

		if ((UnitCfg.UserLcProfile.CcEnb) && ((now >= h1) && (now <= h3)))
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
			if ((now >= h1) && (now <= h2))
			{
				CtempOut = a1 * now + b1;
				if (CtempOut > 100)
				{
					CtempOut = 100;
				}
				if (CtempOut < 0)
				{
					CtempOut = 0;
				}
			}
			else if ((now >= h2) && (now <= h3))
			{
				CtempOut = a2 * now + b2;
				if (CtempOut > 100)
				{
					CtempOut = 100;
				}
				if (CtempOut < 0)
				{
					CtempOut = 0;
				}
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
		//sprintf ("time of detection : %ld\n",PirTimeout);
		vTaskDelay(1000 / portTICK_RATE_MS);
	}

	PirOutCmd = false;
	PirTimeoutTask = false;
	vTaskDelete(NULL);
}

void Pir_MonitorTask()
{
	//pir
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
			//ESP_LOGI(TAG, "PIR Triggered + %ld",PirTimeout);
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
		//co2
		if (UnitCfg.Co2LevelWarEnb )
		{
			if ((iaq_data.pred > UnitCfg.Co2LevelWar) && (co2_alert_enable == 0))
			{
				co2_alert_enable = 1;
				co2_triger_alert = true;
				ESP_LOGI(TAG, "Co2 Warning triggered");
				//zone
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
			//desativate co2 and init the light
			if ((iaq_data.pred < UnitCfg.Co2LevelWar) && (co2_alert_enable == 1))
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
		if (iaq_data.pred < 799)
		{
			UnitSetStatus(UNIT_STATUS_NORMAL);
		}
		else if (iaq_data.pred < 1499)
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
