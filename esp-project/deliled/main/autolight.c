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
#include "adc.h"
#include "i2c.h"
#include "emailclient.h"
#include "webservice.h"
#include "app_gpio.h"
#include "gatt_server.h"

#define TAG "AUTOREG"

void Brightness_Light_Controller();
void Pir_MonitorTask();
void ColorTemp_Controller();
uint8_t Test_lum(uint8_t val);
uint8_t check_seuil(uint8_t val);

AutoLightStateDef AutoLightState = AUTOL_STATE_OFF;
uint8_t SubStateIndex = 0;

bool LightManualOn = false;

int8_t days = 0;
char days_previous[8];
time_t CurrentTime = 0;

char txt0[64];
char txt1[64];
char txt2[64];
char txt3[64];
char txt4[64];
struct timeval tv;

struct tm now = { 0 };
struct tm trigtimeinfo = { 0 };
struct tm trigtime2info = { 0 };
struct tm stoptime2info = { 0 };
struct tm stoptimeinfo = { 0 };

uint8_t Curday;

int i;
uint8_t zone_number;

uint32_t cparttime;

void AutoLightStateMachine() {
	// Init Light Stat

	//Radio
	//MilightHandler(LCMD_SWITCH_ON_OFF,LSUBCMD_SWITCH_OFF,15);

	//0-10V
	//dac_output_voltage(DAC_CHANNEL_1, 0);
	//DacLightStatOn=false;

	time_t nows = 0;

	uint32_t trigparttime;
	uint32_t stopparttime;
	uint32_t trigparttime2;
	uint32_t stopparttime2;

	uint16_t veille_trig_days;
	uint16_t veille_stop_days;
	uint16_t veille_trig2_days;
	uint16_t veille_stop2_days;
	uint16_t veille_pir_days;

	bool AutoTrigSameDay;
	bool AutoStopSameDay;
	bool AutoTrig2SameDay;
	bool AutoStop2SameDay;
	bool AutoPIRSameDay;

	uint16_t veille_zone_int;
	uint16_t PIR_zone_int;
	uint16_t dac_out;
	uint16_t EXTENC_zone_int;

	time(&CurrentTime);
	localtime_r(&CurrentTime, &now);

	while ((now.tm_year < (2016 - 1900))) {
		time(&CurrentTime);
		localtime_r(&CurrentTime, &now);
		vTaskDelay(1000 / portTICK_PERIOD_MS);
	}

	xTaskCreatePinnedToCore(&Pir_MonitorTask, "Pir_MonitorTask", 1024 * 2, NULL,
			10, NULL, 1);
	xTaskCreatePinnedToCore(&Brightness_Light_Controller,
			"Brightness_Light_Controller", 1024 * 2, NULL, 10, NULL, 1);
	xTaskCreatePinnedToCore(&ColorTemp_Controller, "ColorTemp_Controller", 2048,
	NULL, 10, NULL, 1);
	xTaskCreatePinnedToCore(&Scenes, "Scenes", 1024 * 4, NULL, 10, NULL, 1);

	while (1) {
		gettimeofday(&tv, NULL);

		localtime_r(&tv.tv_sec, &now);
		strftime(txt0, sizeof(txt0), "%R", &now);

		gmtime_r(&UnitCfg.UserLcProfile.AutoTrigTime, &trigtimeinfo);
		gmtime_r(&UnitCfg.UserLcProfile.AutoTrigTime2, &trigtime2info);
		gmtime_r(&UnitCfg.UserLcProfile.AutoStopTime2, &stoptime2info);
		gmtime_r(&UnitCfg.UserLcProfile.AutoStopTime, &stoptimeinfo);

		strftime(txt1, sizeof(txt1), "%R", &trigtimeinfo);
		strftime(txt2, sizeof(txt2), "%R", &stoptimeinfo);
		strftime(txt3, sizeof(txt3), "%R", &trigtime2info);
		strftime(txt4, sizeof(txt4), "%R", &stoptime2info);

		time(&nows);
		cparttime = nows % (3600 * 24) + (UnitCfg.UnitTimeZone * 3600);

		trigparttime = trigtimeinfo.tm_hour * 3600 + trigtimeinfo.tm_min * 60
				+ trigtimeinfo.tm_sec;
		stopparttime = stoptimeinfo.tm_hour * 3600 + stoptimeinfo.tm_min * 60
				+ stoptimeinfo.tm_sec;
		trigparttime2 = trigtime2info.tm_hour * 3600 + trigtime2info.tm_min * 60
				+ trigtime2info.tm_sec;
		stopparttime2 = stoptime2info.tm_hour * 3600 + stoptime2info.tm_min * 60
				+ stoptime2info.tm_sec;

		time(&CurrentTime);
		localtime_r(&CurrentTime, &now);

		Curday = now.tm_wday;

		veille_trig_days = strtol(UnitCfg.UserLcProfile.Trig_days, NULL, 16);
		veille_stop_days = strtol(UnitCfg.UserLcProfile.Stop_days, NULL, 16);
		veille_trig2_days = strtol(UnitCfg.UserLcProfile.Trig2_days, NULL, 16);
		veille_stop2_days = strtol(UnitCfg.UserLcProfile.Stop2_days, NULL, 16);
		veille_pir_days = strtol(UnitCfg.UserLcProfile.PIR_days, NULL, 16);

		AutoTrigSameDay = false;
		AutoStopSameDay = false;
		AutoTrig2SameDay = false;
		AutoStop2SameDay = false;
		AutoPIRSameDay = false;

		if ((veille_trig2_days & 0x01) && (Curday == 0))
			AutoTrig2SameDay = true;
		if ((veille_trig2_days & 0x02) && (Curday == 6))
			AutoTrig2SameDay = true;
		if ((veille_trig2_days & 0x04) && (Curday == 5))
			AutoTrig2SameDay = true;
		if ((veille_trig2_days & 0x08) && (Curday == 4))
			AutoTrig2SameDay = true;
		if ((veille_trig2_days & 0x10) && (Curday == 3))
			AutoTrig2SameDay = true;
		if ((veille_trig2_days & 0x20) && (Curday == 2))
			AutoTrig2SameDay = true;
		if ((veille_trig2_days & 0x40) && (Curday == 1))
			AutoTrig2SameDay = true;

		if ((veille_stop2_days & 0x01) && (Curday == 0))
			AutoStop2SameDay = true;
		if ((veille_stop2_days & 0x02) && (Curday == 6))
			AutoStop2SameDay = true;
		if ((veille_stop2_days & 0x04) && (Curday == 5))
			AutoStop2SameDay = true;
		if ((veille_stop2_days & 0x08) && (Curday == 4))
			AutoStop2SameDay = true;
		if ((veille_stop2_days & 0x10) && (Curday == 3))
			AutoStop2SameDay = true;
		if ((veille_stop2_days & 0x20) && (Curday == 2))
			AutoStop2SameDay = true;
		if ((veille_stop2_days & 0x40) && (Curday == 1))
			AutoStop2SameDay = true;

		if ((veille_trig_days & 0x01) && (Curday == 0))
			AutoTrigSameDay = true;
		if ((veille_trig_days & 0x02) && (Curday == 6))
			AutoTrigSameDay = true;
		if ((veille_trig_days & 0x04) && (Curday == 5))
			AutoTrigSameDay = true;
		if ((veille_trig_days & 0x08) && (Curday == 4))
			AutoTrigSameDay = true;
		if ((veille_trig_days & 0x10) && (Curday == 3))
			AutoTrigSameDay = true;
		if ((veille_trig_days & 0x20) && (Curday == 2))
			AutoTrigSameDay = true;
		if ((veille_trig_days & 0x40) && (Curday == 1))
			AutoTrigSameDay = true;

		if ((veille_stop_days & 0x01) && (Curday == 0))
			AutoStopSameDay = true;
		if ((veille_stop_days & 0x02) && (Curday == 6))
			AutoStopSameDay = true;
		if ((veille_stop_days & 0x04) && (Curday == 5))
			AutoStopSameDay = true;
		if ((veille_stop_days & 0x08) && (Curday == 4))
			AutoStopSameDay = true;
		if ((veille_stop_days & 0x10) && (Curday == 3))
			AutoStopSameDay = true;
		if ((veille_stop_days & 0x20) && (Curday == 2))
			AutoStopSameDay = true;
		if ((veille_stop_days & 0x40) && (Curday == 1))
			AutoStopSameDay = true;

		if ((veille_pir_days & 0x01) && (Curday == 0))
			AutoPIRSameDay = true;
		if ((veille_pir_days & 0x02) && (Curday == 6))
			AutoPIRSameDay = true;
		if ((veille_pir_days & 0x04) && (Curday == 5))
			AutoPIRSameDay = true;
		if ((veille_pir_days & 0x08) && (Curday == 4))
			AutoPIRSameDay = true;
		if ((veille_pir_days & 0x10) && (Curday == 3))
			AutoPIRSameDay = true;
		if ((veille_pir_days & 0x20) && (Curday == 2))
			AutoPIRSameDay = true;
		if ((veille_pir_days & 0x40) && (Curday == 1))
			AutoPIRSameDay = true;

		if ((UnitData.state == 1)
				&& (UnitCfg.UserLcProfile.Alum_Exten_enb == true)) {
			if (((cparttime == trigparttime) && (AutoTrigSameDay == true)
					&& (UnitCfg.UserLcProfile.AutoTrigTimeEnb))
					|| ((cparttime == trigparttime2)
							&& (AutoTrig2SameDay == true)
							&& (UnitCfg.UserLcProfile.AutoTrigTime2Enb))) {
				veille_zone_int = strtol(UnitCfg.UserLcProfile.Trig_zone, NULL,
						16);

				//radio
				MilightHandler(LCMD_SWITCH_ON_OFF, LSUBCMD_SWITCH_ON,
						veille_zone_int & 0x0F);
				vTaskDelay(10 / portTICK_RATE_MS);

				//0-10
				if (veille_zone_int & 0x0010) {
					dac_out = (100 * 255) / 100;
					dac_output_voltage(DAC_CHANNEL_1, dac_out);
				}

				printf("AutoTrigger Timer Switch light on\n");
				printf("Info : Now %d @ %s start at : %s to %s\n", Curday, txt0,
						txt1, txt2);
				printf("Info : Now %d @ %d start at : %d to %d\n", Curday,
						cparttime, trigparttime, stopparttime);

			}

			if ((UnitCfg.UserLcProfile.PIRBrEnb)) {
				if (PirOutCmd == true && PirDetectionOverride == false
						&& AutoPIRSameDay == true) {

					PIR_zone_int = strtol(UnitCfg.UserLcProfile.PIR_zone, NULL,
							16);

					//radio
					MilightHandler(LCMD_SWITCH_ON_OFF, LSUBCMD_SWITCH_ON,
							PIR_zone_int & 0x0F);
					vTaskDelay(10 / portTICK_RATE_MS);

					PirDetectionOverride = true;

					//0-10
					if (PIR_zone_int & 0x0010) {
						dac_out = (100 * 255) / 100;
						dac_output_voltage(DAC_CHANNEL_1, dac_out);
					}

					printf("PIR Switch light on\n");

				}
			}

			// stop by PIR
			if ((PirOutCmd == false) && (PirDetectionOverride == true)
					&& (UnitCfg.UserLcProfile.PIRBrEnb == true)
					&& (AutoPIRSameDay == true)) {
				PIR_zone_int = strtol(UnitCfg.UserLcProfile.PIR_zone, NULL, 16);
				printf("PIR Timeout Switch to OFF\n");
				//Radio
				MilightHandler(LCMD_SWITCH_ON_OFF, LSUBCMD_SWITCH_OFF,
						PIR_zone_int);
				vTaskDelay(10 / portTICK_RATE_MS);
				//0-10V
				if (PIR_zone_int & 0x0010) {
					dac_out = (0 * 255) / 100;
					dac_output_voltage(DAC_CHANNEL_1, dac_out);
				}
				PirDetectionOverride = false;
			}

			// stop by autostop timer
			if (((cparttime == stopparttime) && (AutoStopSameDay == true)
					&& (UnitCfg.UserLcProfile.AutoStopTimeEnb))
					|| ((cparttime == stopparttime2)
							&& (AutoStop2SameDay == true)
							&& (UnitCfg.UserLcProfile.AutoStopTime2Enb))) {
				EXTENC_zone_int = strtol(UnitCfg.UserLcProfile.Stop_zone, NULL,
						16);
				printf("Stop Timeout Switch to OFF\n");
				//Radio
				MilightHandler(LCMD_SWITCH_ON_OFF, LSUBCMD_SWITCH_OFF,
						EXTENC_zone_int);
				vTaskDelay(10 / portTICK_RATE_MS);
				//0-10V
				if (EXTENC_zone_int & 0x0010) {
					dac_out = (0 * 255) / 100;
					dac_output_voltage(DAC_CHANNEL_1, dac_out);
				}
			}
		}
		vTaskDelay(100 / portTICK_RATE_MS);
	}
}

// Brigthness Control routine

const uint8_t PID_Step = 1;
int8_t PID_Out = 100;
bool LumTestEnb = false;
uint8_t zone_lum = 0;

uint8_t Test_lum(uint8_t val) {
	if (val >= 100)
		return val = 100;
	if (val <= 0)
		return val = 0;
	return val;
}

uint8_t check_seuil(uint8_t val) {
	if ((UnitCfg.UserLcProfile.seuil_eclairage) && (val < 20)) {
		return val = 20;
	} else {
		return val;
	}
}

cJSON *sequence;
cJSON *AMB, *AMB_next;
cJSON *AMB_id, *AMB_id_next, *AMB_duree, *AMB_transtion;

uint8_t id = 0, id_next = 0, duration = 0, transition = 0, transtion_progress =
		0, transition_step = 0;

uint32_t timeout = 0;

void duration_time() {
	if (duration == 0) {
		timeout = 60;
	}
	if (duration == 1) {
		timeout = 120;
	}
	if (duration == 2) {
		timeout = 180;
	}
	if (duration == 3) {
		timeout = 300;
	}
	if (duration == 4) {
		timeout = 600;
	}
	if (duration == 5) {
		timeout = 900;
	}
	if (duration == 6) {
		timeout = 1200;
	}
	if (duration == 7) {
		timeout = 1500;
	}
	if (duration == 8) {
		timeout = 1800;
	}
	if (duration == 9) {
		timeout = 2100;
	}
	if (duration == 10) {
		timeout = 2400;
	}
	if (duration == 11) {
		timeout = 2700;
	}
	if (duration == 12) {
		timeout = 3000;
	}
	if (duration == 13) {
		timeout = 3300;
	}
	if (duration == 14) {
		timeout = 3600;
	}
}

void transition_time() {
	if (transition == 0) {
		timeout = 1000;
	}
	if (transition == 1) {
		timeout = 2000;
	}
	if (transition == 2) {
		timeout = 3000;
	}
	if (transition == 3) {
		timeout = 5000;
	}
	if (transition == 4) {
		timeout = 10000;
	}
	if (transition == 5) {
		timeout = 15000;
	}
	if (transition == 6) {
		timeout = 20000;
	}
	if (transition == 7) {
		timeout = 25000;
	}
	if (transition == 8) {
		timeout = 30000;
	}
	if (transition == 9) {
		timeout = 35000;
	}
	if (transition == 10) {
		timeout = 40000;
	}
	if (transition == 11) {
		timeout = 45000;
	}
	if (transition == 12) {
		timeout = 50000;
	}
	if (transition == 13) {
		timeout = 55000;
	}
	if (transition == 14) {
		timeout = 60000;
	}
}

bool ScenesAlive;

uint8_t subcmd;
uint32_t rgb_id;
uint32_t rgb_id_next;
HSLStruct HSLtmp;

float pente_trans_R = 0, pente_trans_G = 0, pente_trans_B = 0;
float const_trans_R = 0, const_trans_G = 0, const_trans_B = 0;
float rouge_id = 0, vert_id = 0, blue_id = 0;
float rouge_id_next = 0, vert_id_next = 0, blue_id_next = 0;

float lum_id = 0, lum_id_next = 0, sat_id = 0, sat_id_next = 0, blan_id = 0,
		blan_id_next = 0;
float lum_id_pent = 0, sat_id_pent = 0, blan_id_pent = 0;
float lum_id_const = 0, sat_id_const = 0, blan_id_const = 0;

uint8_t FscenesOut_R = 0, FscenesOut_G = 0, FscenesOut_B = 0,
		FscenesOut_lum = 0, FscenesOut_sat = 0, FscenesOut_Blan = 0;

uint16_t current_transition_time, out_time_now;

uint32_t timeout_trans = 0;

void transition_process() {
	transition_step = 100;
	pente_trans_R = 0;
	pente_trans_G = 0;
	pente_trans_B = 0;
	const_trans_R = 0;
	const_trans_G = 0;
	const_trans_B = 0;
	out_time_now = 0;
	timeout_trans = timeout;

	rouge_id = UnitCfg.ColortrProfile[id].Rouge;
	vert_id = UnitCfg.ColortrProfile[id].Vert;
	blue_id = UnitCfg.ColortrProfile[id].Bleu;
	lum_id = UnitCfg.ColortrProfile[id].intensity;
	sat_id = UnitCfg.ColortrProfile[id].stabilisation;
	blan_id = UnitCfg.ColortrProfile[id].Blanche;

	rouge_id_next = UnitCfg.ColortrProfile[id_next].Rouge;
	vert_id_next = UnitCfg.ColortrProfile[id_next].Vert;
	blue_id_next = UnitCfg.ColortrProfile[id_next].Bleu;
	lum_id_next = UnitCfg.ColortrProfile[id_next].intensity;
	sat_id_next = UnitCfg.ColortrProfile[id_next].stabilisation;
	blan_id_next = UnitCfg.ColortrProfile[id_next].Blanche;

	pente_trans_R = (rouge_id_next - rouge_id) / ((float) timeout);
	pente_trans_G = (vert_id_next - vert_id) / ((float) timeout);
	pente_trans_B = (blue_id_next - blue_id) / ((float) timeout);
	lum_id_pent = (lum_id_next - lum_id) / ((float) timeout);
	sat_id_pent = (sat_id_next - sat_id) / ((float) timeout);
	blan_id_pent = (blan_id_next - blan_id) / ((float) timeout);

	const_trans_R = (rouge_id);
	const_trans_G = (vert_id);
	const_trans_B = (blue_id);
	lum_id_const = (lum_id);
	sat_id_const = (sat_id);
	blan_id_const = (blan_id);

	rgb_id = UnitCfg.ColortrProfile[id].Rouge * 0x10000
			+ UnitCfg.ColortrProfile[id].Vert * 0x100
			+ UnitCfg.ColortrProfile[id].Bleu;
	rgb_id_next = UnitCfg.ColortrProfile[id_next].Rouge * 0x10000
			+ UnitCfg.ColortrProfile[id_next].Vert * 0x100
			+ UnitCfg.ColortrProfile[id_next].Bleu;

	if ((rgb_id != 0 && rgb_id_next == 0)
			|| (rgb_id == 0 && rgb_id_next != 0)) {
		MilightHandler(LCMD_SWITCH_ON_OFF, LSUBCMD_SWITCH_OFF,
				strtol(UnitCfg.ColortrProfile[id_next].zone, NULL, 16));
		vTaskDelay(50 / portTICK_RATE_MS);
		MilightHandler(LCMD_SWITCH_ON_OFF, LSUBCMD_SWITCH_ON,
				strtol(UnitCfg.ColortrProfile[id_next].zone, NULL, 16));
		vTaskDelay(50 / portTICK_RATE_MS);
		ESP_LOGI(TAG, "detecting transtion with white and color ");
	}

	while (timeout_trans > 0) {
		if (!(UnitCfg.Scenes.Scene_switch)
				|| ((cparttime < UnitCfg.Scenes.SceneTrigTime)
						|| (cparttime > UnitCfg.Scenes.SceneStopTime))) {
			goto finish_trans;
		}

		out_time_now += transition_step;

		if (rgb_id != 0 && rgb_id_next != 0) {
			FscenesOut_R = (pente_trans_R * out_time_now) + const_trans_R;
			FscenesOut_G = (pente_trans_G * out_time_now) + const_trans_G;
			FscenesOut_B = (pente_trans_B * out_time_now) + const_trans_B;

			rgb_id_next = FscenesOut_R * 0x10000 + FscenesOut_G * 0x100
					+ FscenesOut_B;

			RgbToHSL(rgb_id_next, &HSLtmp);
			MilightHandler(LCMD_SET_COLOR, HSLtmp.Hue,
					strtol(UnitCfg.ColortrProfile[id_next].zone, NULL, 16));
			vTaskDelay(100 / portTICK_RATE_MS);

			FscenesOut_lum = (lum_id_pent * out_time_now) + lum_id_const;
			FscenesOut_sat = (sat_id_pent * out_time_now) + sat_id_const;

			if (FscenesOut_lum > 100) {
				FscenesOut_lum = 100;
			}

			if (FscenesOut_sat > 100) {
				FscenesOut_sat = 100;
			}

			MilightHandler(LCMD_SET_BRIGTHNESS, (uint8_t) FscenesOut_lum,
					strtol(UnitCfg.ColortrProfile[id_next].zone, NULL, 16));
			vTaskDelay(100 / portTICK_RATE_MS);
			MilightHandler(LCMD_SET_SAT, (uint8_t) FscenesOut_sat,
					strtol(UnitCfg.ColortrProfile[id_next].zone, NULL, 16));
			ESP_LOGI(TAG, "color is : %d ", HSLtmp.Hue);

		}
		if ((rgb_id != 0 && rgb_id_next == 0)) {
			MilightHandler(LCMD_SET_WHITE,
					UnitCfg.ColortrProfile[id_next].Blanche,
					strtol(UnitCfg.ColortrProfile[id_next].zone, NULL, 16));
			vTaskDelay(100 / portTICK_RATE_MS);
			ESP_LOGI(TAG, "color to white is : %d ",
					UnitCfg.ColortrProfile[id_next].Blanche);
		}
		if ((rgb_id == 0 && rgb_id_next != 0)) {
			rgb_id_next = UnitCfg.ColortrProfile[id_next].Rouge * 0x10000
					+ UnitCfg.ColortrProfile[id_next].Vert * 0x100
					+ UnitCfg.ColortrProfile[id_next].Bleu;

			RgbToHSL(rgb_id_next, &HSLtmp);
			MilightHandler(LCMD_SET_COLOR, HSLtmp.Hue,
					strtol(UnitCfg.ColortrProfile[id_next].zone, NULL, 16));
			vTaskDelay(100 / portTICK_RATE_MS);

			FscenesOut_lum = (lum_id_pent * out_time_now) + lum_id_const;
			FscenesOut_sat = (sat_id_pent * out_time_now) + sat_id_const;

			if (FscenesOut_lum > 100) {
				FscenesOut_lum = 100;
			}

			if (FscenesOut_sat > 100) {
				FscenesOut_sat = 100;
			}

			MilightHandler(LCMD_SET_BRIGTHNESS, (uint8_t) FscenesOut_lum,
					strtol(UnitCfg.ColortrProfile[id_next].zone, NULL, 16));
			vTaskDelay(100 / portTICK_RATE_MS);
			MilightHandler(LCMD_SET_SAT, (uint8_t) FscenesOut_sat,
					strtol(UnitCfg.ColortrProfile[id_next].zone, NULL, 16));
			ESP_LOGI(TAG, "white to color is : %d ", HSLtmp.Hue);
		}
		if (rgb_id == 0 && rgb_id_next == 0) {
			FscenesOut_Blan = (blan_id_pent * out_time_now) + blan_id_const;
			MilightHandler(LCMD_SET_WHITE, (uint8_t) FscenesOut_Blan,
					strtol(UnitCfg.ColortrProfile[id_next].zone, NULL, 16));
			vTaskDelay(100 / portTICK_RATE_MS);
			ESP_LOGI(TAG, "Blanc is : %d ", FscenesOut_Blan);

		}

		timeout_trans -= transition_step;

		vTaskDelay(transition_step / portTICK_RATE_MS);

		/*ESP_LOGI(TAG, "out time now is %d ",
		 out_time_now);

		 ESP_LOGI(TAG, "R id is %d and G is %d and B is %d and lum is %d and sat is %d",
		 UnitCfg.ColortrProfile[id].Rouge,UnitCfg.ColortrProfile[id].Vert,UnitCfg.ColortrProfile[id].Bleu,UnitCfg.ColortrProfile[id].intensity,UnitCfg.ColortrProfile[id].stabilisation);

		 ESP_LOGI(TAG, "out R is %d and out G is %d and out B is %d  and out lum is %d and out sat is %d",
		 FscenesOut_R,FscenesOut_G,FscenesOut_B,FscenesOut_lum,FscenesOut_sat);

		 ESP_LOGI(TAG, "R id next is %d and G id next is %d and B id next is %d and lum id next is %d and sat id next is %d",
		 UnitCfg.ColortrProfile[id_next].Rouge,UnitCfg.ColortrProfile[id_next].Vert,UnitCfg.ColortrProfile[id_next].Bleu,UnitCfg.ColortrProfile[id_next].intensity,UnitCfg.ColortrProfile[id_next].stabilisation);*/
	}
	finish_trans:
	ESP_LOGI(TAG, "[APP] Free memory: %d bytes", esp_get_free_heap_size());
}

void Scenes() {
	UnitData.scene_state = 0;
	ScenesAlive = true;
	while (1) {
		if ((UnitData.state == 0) && (UnitCfg.Scenes.Scene_switch)
				&& (cparttime > UnitCfg.Scenes.SceneTrigTime)
				&& (cparttime < UnitCfg.Scenes.SceneStopTime)) {
			sequence = cJSON_Parse(UnitCfg.Scenes.scene_seq);

			for (int i = 0; i < cJSON_GetArraySize(sequence); i++) {
				if (!(UnitCfg.Scenes.Scene_switch)
						|| ((cparttime < UnitCfg.Scenes.SceneTrigTime)
								|| (cparttime > UnitCfg.Scenes.SceneStopTime))) {
					break;
				}

				UnitData.scene_state = i;

				AMB = cJSON_GetArrayItem(sequence, i);

				//id

				AMB_id = cJSON_GetArrayItem(AMB, 0);
				id = AMB_id->valueint;

				AMB_duree = cJSON_GetArrayItem(AMB, 1);
				duration = AMB_duree->valueint;

				AMB_transtion = cJSON_GetArrayItem(AMB, 2);
				transition = AMB_transtion->valueint;

				printf("%d,%d,%d\n", id, duration, transition);

				//id next

				if (i == (cJSON_GetArraySize(sequence) - 1)) {
					if (UnitCfg.Scenes.Infiniti_scene) {
						AMB_next = cJSON_GetArrayItem(sequence, 0);
						AMB_id_next = cJSON_GetArrayItem(AMB_next, 0);
						id_next = AMB_id_next->valueint;
					} else {
						goto finish;
					}
				} else {
					AMB_next = cJSON_GetArrayItem(sequence, i + 1);
					AMB_id_next = cJSON_GetArrayItem(AMB_next, 0);
					id_next = AMB_id_next->valueint;
				}

				//duration

				rgb_id = UnitCfg.ColortrProfile[id].Rouge * 0x10000
						+ UnitCfg.ColortrProfile[id].Vert * 0x100
						+ UnitCfg.ColortrProfile[id].Bleu;
				RgbToHSL(rgb_id, &HSLtmp);
				subcmd = HSLtmp.Hue;

				if (i == 0) {

					if (rgb_id != 0) {
						MilightHandler(LCMD_SET_COLOR, subcmd,
								strtol(UnitCfg.ColortrProfile[id].zone, NULL,
										16));
						vTaskDelay(100 / portTICK_RATE_MS);

					} else {
						MilightHandler(LCMD_SET_WHITE,
								UnitCfg.ColortrProfile[id].Blanche,
								strtol(UnitCfg.ColortrProfile[id].zone, NULL,
										16));
						vTaskDelay(100 / portTICK_RATE_MS);
					}
					MilightHandler(LCMD_SET_BRIGTHNESS,
							UnitCfg.ColortrProfile[id].intensity,
							strtol(UnitCfg.ColortrProfile[id].zone, NULL, 16));
					vTaskDelay(100 / portTICK_RATE_MS);
					MilightHandler(LCMD_SET_SAT,
							UnitCfg.ColortrProfile[id].stabilisation,
							strtol(UnitCfg.ColortrProfile[id].zone, NULL, 16));

				}

				ESP_LOGI(TAG,
						"number %d ambiance %d with duration %d seconds %ld zones color hue %d",
						i, id, timeout,
						strtol(UnitCfg.ColortrProfile[id].zone,NULL,16),
						subcmd);
				duration_time();

				/*rgb_id=UnitCfg.ColortrProfile[id].Rouge*0x10000+UnitCfg.ColortrProfile[id].Vert*0x100+UnitCfg.ColortrProfile[id].Bleu;
				 RgbToHSL(rgb_id,&HSLtmp);
				 subcmd=HSLtmp.Hue;
				 MilightHandler(LCMD_SET_COLOR,subcmd,strtol(UnitCfg.ColortrProfile[id].zone,NULL,16));
				 vTaskDelay(100 / portTICK_RATE_MS);
				 MilightHandler(LCMD_SET_BRIGTHNESS,UnitCfg.ColortrProfile[id].intensity,strtol(UnitCfg.ColortrProfile[id].zone,NULL,16));
				 vTaskDelay(100 / portTICK_RATE_MS);
				 MilightHandler(LCMD_SET_SAT,UnitCfg.ColortrProfile[id].stabilisation,strtol(UnitCfg.ColortrProfile[id].zone,NULL,16));
				 duration_time();
				 ESP_LOGI(TAG, "number %d ambiance %d with duration %d seconds %ld zones color hue %d",i,id, timeout,strtol(UnitCfg.ColortrProfile[id].zone,NULL,16),subcmd);
				 vTaskDelay(timeout*1000 / portTICK_RATE_MS);*/

				timeout_trans = timeout * 1000;
				transition_step = 100;

				while (timeout_trans > 0) {
					if (!(UnitCfg.Scenes.Scene_switch)
							|| ((cparttime < UnitCfg.Scenes.SceneTrigTime)
									|| (cparttime > UnitCfg.Scenes.SceneStopTime))) {
						break;
					}
					timeout_trans -= transition_step;
					vTaskDelay(transition_step / portTICK_RATE_MS);
				}

				if (!(UnitCfg.Scenes.Scene_switch)
						|| ((cparttime < UnitCfg.Scenes.SceneTrigTime)
								|| (cparttime > UnitCfg.Scenes.SceneStopTime))) {
					break;
				}

				//transition

				transition_time();
				transition_process();

			}
			cJSON_Delete(sequence);
			ESP_LOGI(TAG, "[APP] Free memory: %d bytes",
					esp_get_free_heap_size());

		}
		vTaskDelay(1000 / portTICK_RATE_MS);
	}
	finish: cJSON_Delete(sequence);
	ScenesAlive = false;
	ESP_LOGI(TAG, "[APP] Free memory: %d bytes", esp_get_free_heap_size());
	vTaskDelete(NULL);
}

void Brightness_Light_Controller() {
	//bool alctestinit=false;
	float h1 = 0, h2 = 0, h3 = 0, h4 = 0;
	float lum1r = 0, lum2r = 0, lum3r = 0, lum4r = 0, lumvr = 0;
	float lum1m = 0, lum2m = 0, lum3m = 0, lum4m = 0, lumvm = 0;
	float lum1s = 0, lum2s = 0, lum3s = 0, lum4s = 0, lumvs = 0;
	float lum1t = 0, lum2t = 0, lum3t = 0, lum4t = 0, lumvt = 0;

	int8_t FtempOut = 0;

	float a1 = 0, b1 = 0, a2 = 0, b2 = 0, a3 = 0, b3 = 0;

	time_t now = 0;

	uint16_t dac_out_b;
	uint16_t fx_zone_int;

	while (1) {
		if ((UnitCfg.UserLcProfile.AutoBrEnb == true)
				&& (UnitData.state == 1)) {
			if ((UnitCfg.UserLcProfile.Auto_or_fixe == true)) {
				// alc
				zone_lum = strtol(UnitCfg.UserLcProfile.Zone_lum, NULL, 16);

				ESP_LOGI(TAG, "AUTO is enabled !");

				UnitCfg.UserLcProfile.FixedBrLevel_zone_010v = Test_lum(
						UnitCfg.UserLcProfile.FixedBrLevel_zone_010v);
				UnitCfg.UserLcProfile.FixedBrLevel_zone4 = Test_lum(
						UnitCfg.UserLcProfile.FixedBrLevel_zone4);
				UnitCfg.UserLcProfile.FixedBrLevel_zone3 = Test_lum(
						UnitCfg.UserLcProfile.FixedBrLevel_zone3);
				UnitCfg.UserLcProfile.FixedBrLevel_zone2 = Test_lum(
						UnitCfg.UserLcProfile.FixedBrLevel_zone2);
				UnitCfg.UserLcProfile.FixedBrLevel_zone1 = Test_lum(
						UnitCfg.UserLcProfile.FixedBrLevel_zone1);

				if ((zone_lum / 16) == 1) {
					if ((OPT3001_HoldReg.result
							> UnitCfg.UserLcProfile.AutoBrRef)
							&& UnitCfg.UserLcProfile.FixedBrLevel_zone_010v
									> 0) {
						uint16_t dac_out =
								(UnitCfg.UserLcProfile.FixedBrLevel_zone_010v
										* 255) / 100;
						dac_output_voltage(DAC_CHANNEL_1, dac_out);
						UnitCfg.UserLcProfile.FixedBrLevel_zone_010v -=
								PID_Step;
					}
					if ((OPT3001_HoldReg.result
							< UnitCfg.UserLcProfile.AutoBrRef)
							&& UnitCfg.UserLcProfile.FixedBrLevel_zone_010v
									< 100) {
						uint16_t dac_out =
								(UnitCfg.UserLcProfile.FixedBrLevel_zone_010v
										* 255) / 100;
						dac_output_voltage(DAC_CHANNEL_1, dac_out);
						UnitCfg.UserLcProfile.FixedBrLevel_zone_010v +=
								PID_Step;
					}

				}
				if (((zone_lum % 16) / 8) == 1) {
					//MilightHandler(LCMD_SET_WHITE,UnitCfg.UserLcProfile.FixedBrLevel_zone4,4);
					if ((OPT3001_HoldReg.result
							> UnitCfg.UserLcProfile.AutoBrRef)
							&& UnitCfg.UserLcProfile.FixedBrLevel_zone4 > 0) {
						MilightHandler(LCMD_SET_BRIGTHNESS,
								UnitCfg.UserLcProfile.FixedBrLevel_zone4, 8);
						UnitCfg.UserLcProfile.FixedBrLevel_zone4 -= PID_Step;
					}
					if ((OPT3001_HoldReg.result
							< UnitCfg.UserLcProfile.AutoBrRef)
							&& UnitCfg.UserLcProfile.FixedBrLevel_zone4 < 100) {
						MilightHandler(LCMD_SET_BRIGTHNESS,
								UnitCfg.UserLcProfile.FixedBrLevel_zone4, 8);
						UnitCfg.UserLcProfile.FixedBrLevel_zone4 += PID_Step;
					}

				}
				if (((zone_lum % 8) / 4) == 1) {
					//MilightHandler(LCMD_SET_WHITE,UnitCfg.UserLcProfile.FixedBrLevel_zone3,3);
					if ((OPT3001_HoldReg.result
							> UnitCfg.UserLcProfile.AutoBrRef)
							&& UnitCfg.UserLcProfile.FixedBrLevel_zone3 > 0) {
						MilightHandler(LCMD_SET_BRIGTHNESS,
								UnitCfg.UserLcProfile.FixedBrLevel_zone3, 4);
						UnitCfg.UserLcProfile.FixedBrLevel_zone3 -= PID_Step;
					}
					if ((OPT3001_HoldReg.result
							< UnitCfg.UserLcProfile.AutoBrRef)
							&& UnitCfg.UserLcProfile.FixedBrLevel_zone3 < 100) {
						MilightHandler(LCMD_SET_BRIGTHNESS,
								UnitCfg.UserLcProfile.FixedBrLevel_zone3, 4);
						UnitCfg.UserLcProfile.FixedBrLevel_zone3 += PID_Step;
					}

				}
				if (((zone_lum % 4) / 2) == 1) {
					//MilightHandler(LCMD_SET_WHITE,UnitCfg.UserLcProfile.FixedBrLevel_zone2,2);
					if ((OPT3001_HoldReg.result
							> UnitCfg.UserLcProfile.AutoBrRef)
							&& UnitCfg.UserLcProfile.FixedBrLevel_zone2 > 0) {
						MilightHandler(LCMD_SET_BRIGTHNESS,
								UnitCfg.UserLcProfile.FixedBrLevel_zone2, 2);
						UnitCfg.UserLcProfile.FixedBrLevel_zone2 -= PID_Step;
					}
					if ((OPT3001_HoldReg.result
							< UnitCfg.UserLcProfile.AutoBrRef)
							&& UnitCfg.UserLcProfile.FixedBrLevel_zone2 < 100) {
						MilightHandler(LCMD_SET_BRIGTHNESS,
								UnitCfg.UserLcProfile.FixedBrLevel_zone2, 2);
						UnitCfg.UserLcProfile.FixedBrLevel_zone2 += PID_Step;
					}

				}
				if ((zone_lum % 2) == 1) {
					//MilightHandler(LCMD_SET_WHITE,UnitCfg.UserLcProfile.FixedBrLevel_zone1,1);
					if ((OPT3001_HoldReg.result
							> UnitCfg.UserLcProfile.AutoBrRef)
							&& UnitCfg.UserLcProfile.FixedBrLevel_zone1 > 0) {
						MilightHandler(LCMD_SET_BRIGTHNESS,
								UnitCfg.UserLcProfile.FixedBrLevel_zone1, 1);
						UnitCfg.UserLcProfile.FixedBrLevel_zone1 -= PID_Step;
					}
					if ((OPT3001_HoldReg.result
							< UnitCfg.UserLcProfile.AutoBrRef)
							&& UnitCfg.UserLcProfile.FixedBrLevel_zone1 < 100) {
						MilightHandler(LCMD_SET_BRIGTHNESS,
								UnitCfg.UserLcProfile.FixedBrLevel_zone1, 1);
						UnitCfg.UserLcProfile.FixedBrLevel_zone1 += PID_Step;
					}

				}

				UnitCfg.UserLcProfile.FixedBrLevel_zone_010v = check_seuil(
						UnitCfg.UserLcProfile.FixedBrLevel_zone_010v);
				UnitCfg.UserLcProfile.FixedBrLevel_zone4 = check_seuil(
						UnitCfg.UserLcProfile.FixedBrLevel_zone4);
				UnitCfg.UserLcProfile.FixedBrLevel_zone3 = check_seuil(
						UnitCfg.UserLcProfile.FixedBrLevel_zone3);
				UnitCfg.UserLcProfile.FixedBrLevel_zone2 = check_seuil(
						UnitCfg.UserLcProfile.FixedBrLevel_zone2);
				UnitCfg.UserLcProfile.FixedBrLevel_zone1 = check_seuil(
						UnitCfg.UserLcProfile.FixedBrLevel_zone1);

				ESP_LOGI(TAG, "BLC TASK %0.0f,%d,%d,%d,%d,%d,%d",
						OPT3001_HoldReg.result, UnitCfg.UserLcProfile.AutoBrRef,
						UnitCfg.UserLcProfile.FixedBrLevel_zone1,
						UnitCfg.UserLcProfile.FixedBrLevel_zone2,
						UnitCfg.UserLcProfile.FixedBrLevel_zone3,
						UnitCfg.UserLcProfile.FixedBrLevel_zone4,
						UnitCfg.UserLcProfile.FixedBrLevel_zone_010v);

				UnitData.auto_zone_1 = UnitCfg.UserLcProfile.FixedBrLevel_zone1;
				UnitData.auto_zone_2 = UnitCfg.UserLcProfile.FixedBrLevel_zone2;
				UnitData.auto_zone_3 = UnitCfg.UserLcProfile.FixedBrLevel_zone3;
				UnitData.auto_zone_4 = UnitCfg.UserLcProfile.FixedBrLevel_zone4;
				UnitData.auto_zone_010V =
						UnitCfg.UserLcProfile.FixedBrLevel_zone_010v;

				UnitCfg.Lum_10V = UnitCfg.UserLcProfile.FixedBrLevel_zone_010v;
				UnitCfg.Zones_info[3].Luminosite =
						UnitCfg.UserLcProfile.FixedBrLevel_zone4;
				UnitCfg.Zones_info[2].Luminosite =
						UnitCfg.UserLcProfile.FixedBrLevel_zone3;
				UnitCfg.Zones_info[1].Luminosite =
						UnitCfg.UserLcProfile.FixedBrLevel_zone2;
				UnitCfg.Zones_info[0].Luminosite =
						UnitCfg.UserLcProfile.FixedBrLevel_zone1;

			} else {

				time(&now);
				now = now % (3600 * 24) + (UnitCfg.UnitTimeZone * 3600);

				h1 = UnitCfg.UserLcProfile.FixeStartTime;
				h2 = UnitCfg.UserLcProfile.FixeStopTime;
				h3 = UnitCfg.UserLcProfile.FixeStartTime_2;
				h4 = UnitCfg.UserLcProfile.FixeStopTime_2;

				lum1r = UnitCfg.UserLcProfile.FixedStartLum_zone1;
				lum2r = UnitCfg.UserLcProfile.FixedStartLum_zone2;
				lum3r = UnitCfg.UserLcProfile.FixedStartLum_zone3;
				lum4r = UnitCfg.UserLcProfile.FixedStartLum_zone4;
				lumvr = UnitCfg.UserLcProfile.FixedStartLum_zone_010v;

				lum1s = UnitCfg.UserLcProfile.FixedStopLum_zone1;
				lum2s = UnitCfg.UserLcProfile.FixedStopLum_zone2;
				lum3s = UnitCfg.UserLcProfile.FixedStopLum_zone3;
				lum4s = UnitCfg.UserLcProfile.FixedStopLum_zone4;
				lumvs = UnitCfg.UserLcProfile.FixedStopLum_zone_010v;

				lum1m = UnitCfg.UserLcProfile.FixedStartLum_zone1_2;
				lum2m = UnitCfg.UserLcProfile.FixedStartLum_zone2_2;
				lum3m = UnitCfg.UserLcProfile.FixedStartLum_zone3_2;
				lum4m = UnitCfg.UserLcProfile.FixedStartLum_zone4_2;
				lumvm = UnitCfg.UserLcProfile.FixedStartLum_zone_010v_2;

				lum1t = UnitCfg.UserLcProfile.FixedStopLum_zone1_2;
				lum2t = UnitCfg.UserLcProfile.FixedStopLum_zone2_2;
				lum3t = UnitCfg.UserLcProfile.FixedStopLum_zone3_2;
				lum4t = UnitCfg.UserLcProfile.FixedStopLum_zone4_2;
				lumvt = UnitCfg.UserLcProfile.FixedStopLum_zone_010v_2;

				fx_zone_int = strtol(UnitCfg.UserLcProfile.Zone_fixe_lum, NULL,
						16);

				if ((fx_zone_int / 16) == 1) {
					if (h2 != h1) {
						a1 = (lumvs - lumvr) / (h2 - h1);
						b1 = lumvr - (a1 * h1);
					} else {
						a1 = 0;
						b1 = lumvr;
					}

					if (h3 != h2) {
						a2 = (lumvm - lumvs) / (h3 - h2);
						b2 = lumvs - (a2 * h2);
					} else {
						a2 = 0;
						b2 = lumvs;
					}
					if (h4 != h3) {
						a3 = (lumvt - lumvm) / (h4 - h3);
						b3 = lumvm - (a3 * h3);
					} else {
						a3 = 0;
						b3 = lumvm;
					}

					if ((now >= h1) && (now <= h2)) {
						FtempOut = a1 * now + b1;
						if (FtempOut > 100) {
							FtempOut = 100;
						}
						if (FtempOut < 0) {
							FtempOut = 0;
						}
						dac_out_b = ((uint8_t) FtempOut * 255) / 100;
						dac_output_voltage(DAC_CHANNEL_1, dac_out_b);
						ESP_LOGI(TAG, "BLC fixed Level zone 10V %d @ %ld",
								FtempOut, now);
					} else if ((now >= h2) && (now <= h3)) {
						FtempOut = a2 * now + b2;
						if (FtempOut > 100) {
							FtempOut = 100;
						}
						if (FtempOut < 0) {
							FtempOut = 0;
						}
						dac_out_b = ((uint8_t) FtempOut * 255) / 100;
						dac_output_voltage(DAC_CHANNEL_1, dac_out_b);
						ESP_LOGI(TAG, "BLC fixed Level zone 10V %d @ %ld",
								FtempOut, now);
					} else if ((now >= h3) && (now <= h4)) {
						FtempOut = a3 * now + b3;
						if (FtempOut > 100) {
							FtempOut = 100;
						}
						if (FtempOut < 0) {
							FtempOut = 0;
						}
						dac_out_b = ((uint8_t) FtempOut * 255) / 100;
						dac_output_voltage(DAC_CHANNEL_1, dac_out_b);
						ESP_LOGI(TAG, "BLC fixed Level zone 10V %d @ %ld",
								FtempOut, now);
					} else {
						FtempOut = lumvr;
					}
					//vTaskDelay(20 / portTICK_RATE_MS);
					UnitCfg.Lum_10V = (uint8_t) FtempOut;
				}
				if (((fx_zone_int % 16) / 8) == 1) {
					if (h2 != h1) {
						a1 = (lum4s - lum4r) / (h2 - h1);
						b1 = lum4r - (a1 * h1);
					} else {
						a1 = 0;
						b1 = lum4r;
					}

					if (h3 != h2) {
						a2 = (lum4m - lum4s) / (h3 - h2);
						b2 = lum4s - (a2 * h2);
					} else {
						a2 = 0;
						b2 = lum4s;
					}
					if (h4 != h3) {
						a3 = (lum4t - lum4m) / (h4 - h3);
						b3 = lum4m - (a3 * h3);
					} else {
						a3 = 0;
						b3 = lum4m;
					}

					if ((now >= h1) && (now <= h2)) {
						FtempOut = a1 * now + b1;
						if (FtempOut > 100) {
							FtempOut = 100;
						}
						if (FtempOut < 0) {
							FtempOut = 0;
						}
						MilightHandler(LCMD_SET_BRIGTHNESS, (uint8_t) FtempOut,
								8);
						ESP_LOGI(TAG, "BLC fixed Level zone 4 %d @ %ld",
								FtempOut, now);
					} else if ((now >= h2) && (now <= h3)) {
						FtempOut = a2 * now + b2;
						if (FtempOut > 100) {
							FtempOut = 100;
						}
						if (FtempOut < 0) {
							FtempOut = 0;
						}
						MilightHandler(LCMD_SET_BRIGTHNESS, (uint8_t) FtempOut,
								8);
						ESP_LOGI(TAG, "BLC fixed Level zone 4 %d @ %ld",
								FtempOut, now);
					} else if ((now >= h3) && (now <= h4)) {
						FtempOut = a3 * now + b3;
						if (FtempOut > 100) {
							FtempOut = 100;
						}
						if (FtempOut < 0) {
							FtempOut = 0;
						}
						MilightHandler(LCMD_SET_BRIGTHNESS, (uint8_t) FtempOut,
								8);
						ESP_LOGI(TAG, "BLC fixed Level zone 4 %d @ %ld",
								FtempOut, now);
					} else {
						FtempOut = lum4r;
					}
					//vTaskDelay(20 / portTICK_RATE_MS);
					UnitCfg.Zones_info[3].Luminosite = (uint8_t) FtempOut;
				}
				if (((fx_zone_int % 8) / 4) == 1) {
					if (h2 != h1) {
						a1 = (lum3s - lum3r) / (h2 - h1);
						b1 = lum3r - (a1 * h1);
					} else {
						a1 = 0;
						b1 = lum3r;
					}

					if (h3 != h2) {
						a2 = (lum3m - lum3s) / (h3 - h2);
						b2 = lum3s - (a2 * h2);
					} else {
						a2 = 0;
						b2 = lum3s;
					}
					if (h4 != h3) {
						a3 = (lum3t - lum3m) / (h4 - h3);
						b3 = lum3m - (a3 * h3);
					} else {
						a3 = 0;
						b3 = lum3m;
					}

					if ((now >= h1) && (now <= h2)) {
						FtempOut = a1 * now + b1;
						if (FtempOut > 100) {
							FtempOut = 100;
						}
						if (FtempOut < 0) {
							FtempOut = 0;
						}
						MilightHandler(LCMD_SET_BRIGTHNESS, (uint8_t) FtempOut,
								4);
						ESP_LOGI(TAG, "BLC fixed Level zone 3 %d @ %ld",
								FtempOut, now);
					} else if ((now >= h2) && (now <= h3)) {
						FtempOut = a2 * now + b2;
						if (FtempOut > 100) {
							FtempOut = 100;
						}
						if (FtempOut < 0) {
							FtempOut = 0;
						}
						MilightHandler(LCMD_SET_BRIGTHNESS, (uint8_t) FtempOut,
								4);
						ESP_LOGI(TAG, "BLC fixed Level zone 3 %d @ %ld",
								FtempOut, now);
					} else if ((now >= h3) && (now <= h4)) {
						FtempOut = a3 * now + b3;
						if (FtempOut > 100) {
							FtempOut = 100;
						}
						if (FtempOut < 0) {
							FtempOut = 0;
						}
						MilightHandler(LCMD_SET_BRIGTHNESS, (uint8_t) FtempOut,
								4);
						ESP_LOGI(TAG, "BLC fixed Level zone 3 %d @ %ld",
								FtempOut, now);
					} else {
						FtempOut = lum3r;
					}
					//vTaskDelay(20 / portTICK_RATE_MS);
					UnitCfg.Zones_info[2].Luminosite = (uint8_t) FtempOut;
				}
				if (((fx_zone_int % 4) / 2) == 1) {
					if (h2 != h1) {
						a1 = (lum2s - lum2r) / (h2 - h1);
						b1 = lum2r - (a1 * h1);
					} else {
						a1 = 0;
						b1 = lum2r;
					}

					if (h3 != h2) {
						a2 = (lum2m - lum2s) / (h3 - h2);
						b2 = lum2s - (a2 * h2);
					} else {
						a2 = 0;
						b2 = lum2s;
					}
					if (h4 != h3) {
						a3 = (lum2t - lum2m) / (h4 - h3);
						b3 = lum2m - (a3 * h3);
					} else {
						a3 = 0;
						b3 = lum2m;
					}

					if ((now >= h1) && (now <= h2)) {
						FtempOut = a1 * now + b1;
						if (FtempOut > 100) {
							FtempOut = 100;
						}
						if (FtempOut < 0) {
							FtempOut = 0;
						}
						MilightHandler(LCMD_SET_BRIGTHNESS, (uint8_t) FtempOut,
								2);
						ESP_LOGI(TAG, "BLC fixed Level zone 2 %d @ %ld",
								FtempOut, now);
					} else if ((now >= h2) && (now <= h3)) {
						FtempOut = a2 * now + b2;
						if (FtempOut > 100) {
							FtempOut = 100;
						}
						if (FtempOut < 0) {
							FtempOut = 0;
						}
						MilightHandler(LCMD_SET_BRIGTHNESS, (uint8_t) FtempOut,
								2);
						ESP_LOGI(TAG, "BLC fixed Level zone 2 %d @ %ld",
								FtempOut, now);
					} else if ((now >= h3) && (now <= h4)) {
						FtempOut = a3 * now + b3;
						if (FtempOut > 100) {
							FtempOut = 100;
						}
						if (FtempOut < 0) {
							FtempOut = 0;
						}
						MilightHandler(LCMD_SET_BRIGTHNESS, (uint8_t) FtempOut,
								2);
						ESP_LOGI(TAG, "BLC fixed Level zone 2 %d @ %ld",
								FtempOut, now);
					} else {
						FtempOut = lum2r;
					}
					UnitCfg.Zones_info[1].Luminosite = (uint8_t) FtempOut;
					//vTaskDelay(20 / portTICK_RATE_MS);
				}
				if ((fx_zone_int % 2) == 1) {
					if (h2 != h1) {
						a1 = (lum1s - lum1r) / (h2 - h1);
						b1 = lum1r - (a1 * h1);
					} else {
						a1 = 0;
						b1 = lum1r;
					}

					if (h3 != h2) {
						a2 = (lum1m - lum1s) / (h3 - h2);
						b2 = lum1s - (a2 * h2);
					} else {
						a2 = 0;
						b2 = lum1s;
					}
					if (h4 != h3) {
						a3 = (lum1t - lum1m) / (h4 - h3);
						b3 = lum1m - (a3 * h3);
					} else {
						a3 = 0;
						b3 = lum1m;
					}

					if ((now >= h1) && (now <= h2)) {
						FtempOut = a1 * now + b1;
						if (FtempOut > 100) {
							FtempOut = 100;
						}
						if (FtempOut < 0) {
							FtempOut = 0;
						}
						MilightHandler(LCMD_SET_BRIGTHNESS, (uint8_t) FtempOut,
								1);
						ESP_LOGI(TAG, "BLC fixed Level zone 1 %d @ %ld",
								FtempOut, now);
					} else if ((now >= h2) && (now <= h3)) {
						FtempOut = a2 * now + b2;
						if (FtempOut > 100) {
							FtempOut = 100;
						}
						if (FtempOut < 0) {
							FtempOut = 0;
						}
						MilightHandler(LCMD_SET_BRIGTHNESS, (uint8_t) FtempOut,
								1);
						ESP_LOGI(TAG, "BLC fixed Level zone 1 %d @ %ld",
								FtempOut, now);
					} else if ((now >= h3) && (now <= h4)) {
						FtempOut = a3 * now + b3;
						if (FtempOut > 100) {
							FtempOut = 100;
						}
						if (FtempOut < 0) {
							FtempOut = 0;
						}
						MilightHandler(LCMD_SET_BRIGTHNESS, (uint8_t) FtempOut,
								1);

						ESP_LOGI(TAG, "BLC fixed Level zone 1 %d @ %ld",
								FtempOut, now);
					} else {
						FtempOut = lum1r;
					}
					UnitCfg.Zones_info[0].Luminosite = (uint8_t) FtempOut;
					//vTaskDelay(20 / portTICK_RATE_MS);
				}
				/*ESP_LOGI(TAG, "BLC fixed Level %d @ %ld",FtempOut,now);
				 printf("BLC fixed Level %d @ %ld h1 %d h2 %d lum1r %d lum1s %d a1 %f b1 %f a2 %f b2 %f \n"
				 ,FtempOut,now,(uint32_t)h1,(uint32_t)h2,(uint32_t)lum1r,(uint32_t)lum1s,a1,b1,a2,b2);*/
			}
		}
		vTaskDelay(1200 / portTICK_RATE_MS);
	}

	ESP_LOGI(TAG, "BLC TASK EXIT");
	vTaskDelete(NULL);
}

// Color temp Control routine

int8_t CtempOut = 0;
int8_t CtempOut_test = 0;

CCTestStruct_Typedef CCTestStruct;

void ColorTemp_Controller() {

	float h1 = 0, h2 = 0, h3 = 0, h4 = 0;
	float t1 = 0, t2 = 0, t3 = 0, t4 = 0;

	float a1 = 0, b1 = 0;
	float a2 = 0, b2 = 0;
	float a3 = 0, b3 = 0;

	time_t now = 0;

	CCTestStruct.CcEnb = false;

	uint16_t cc_zone_int;
	int phases;

	while (1) {

		if ((UnitCfg.UserLcProfile.CcEnb == true)
				&& (CCTestStruct.CcEnb == false) && (UnitData.state == 1)) {

			time(&now);
			now = now % (3600 * 24) + (UnitCfg.UnitTimeZone * 3600);

			h1 = UnitCfg.UserLcProfile.Ccp[0].CcTime;
			h2 = UnitCfg.UserLcProfile.Ccp[1].CcTime;
			h3 = UnitCfg.UserLcProfile.Ccp[2].CcTime;
			h4 = UnitCfg.UserLcProfile.Ccp[3].CcTime;

			t1 = UnitCfg.UserLcProfile.Ccp[0].CcLevel;
			t2 = UnitCfg.UserLcProfile.Ccp[1].CcLevel;
			t3 = UnitCfg.UserLcProfile.Ccp[2].CcLevel;
			t4 = UnitCfg.UserLcProfile.Ccp[3].CcLevel;

			phases = (int) strtol(UnitCfg.UserLcProfile.EnbCc, NULL, 16);

			//printf("les phases activées = %d",phases);

			switch (phases) {
			case 0:
				CtempOut = 50;
				break;
			case 1:
				CtempOut = UnitCfg.UserLcProfile.Ccp[3].CcLevel;
				break;
			case 2:
				CtempOut = UnitCfg.UserLcProfile.Ccp[2].CcLevel;
				break;
			case 3:
				if (h4 != h3) {
					a3 = (t4 - t3) / (h4 - h3);
					b3 = t3 - (a3 * h3);
				} else {
					a3 = 0;
					b3 = t3 = UnitCfg.UserLcProfile.Ccp[2].CcLevel;
				}
				if ((now >= h3) && (now <= h4)) {
					CtempOut = a3 * now + b3;
					if (CtempOut > 100) {
						CtempOut = 100;
					}
					if (CtempOut < 0) {
						CtempOut = 0;
					}
				} else {
					/*if (UnitCfg.UserLcProfile.CcBetweenTimes)
					 {
					 a3=(t3-t4)/(h3-h4);
					 b3=t4-(a3*h4);
					 CtempOut=a3*now+b3;
					 if (CtempOut>100){ CtempOut = 100;}
					 if (CtempOut<0){ CtempOut = 0;}
					 }else
					 {
					 CtempOut=UnitCfg.UserLcProfile.Ccp[3].CcLevel;;
					 }*/
				}
				break;
			case 4:
				CtempOut = UnitCfg.UserLcProfile.Ccp[1].CcLevel;
				break;
			case 5:
				if (h4 != h2) {
					a3 = (t4 - t2) / (h4 - h2);
					b3 = t2 - (a3 * h2);
				} else {
					a3 = 0;
					b3 = t3 = UnitCfg.UserLcProfile.Ccp[3].CcLevel;
				}
				if ((now >= h2) && (now <= h4)) {
					CtempOut = a3 * now + b3;
					if (CtempOut > 100) {
						CtempOut = 100;
					}
					if (CtempOut < 0) {
						CtempOut = 0;
					}
				} else {
					if (UnitCfg.UserLcProfile.CcBetweenTimes) {

					} else {
						CtempOut = UnitCfg.UserLcProfile.Ccp[3].CcLevel;
					}
				}
				break;
			case 6:
				if (h3 != h2) {
					a3 = (t3 - t2) / (h3 - h2);
					b3 = t2 - (a3 * h2);
				} else {
					a3 = 0;
					b3 = t3 = UnitCfg.UserLcProfile.Ccp[2].CcLevel;
				}
				if ((now >= h2) && (now <= h3)) {
					CtempOut = a3 * now + b3;
					if (CtempOut > 100) {
						CtempOut = 100;
					}
					if (CtempOut < 0) {
						CtempOut = 0;
					}
				} else {
					if (UnitCfg.UserLcProfile.CcBetweenTimes) {

					} else {
						CtempOut = UnitCfg.UserLcProfile.Ccp[2].CcLevel;
					}
				}
				break;
			case 7:
				if (h3 != h2) {
					a2 = (t3 - t2) / (h3 - h2);
					b2 = t2 - (a2 * h2);
				} else {
					a2 = 0;
					b2 = t2 = UnitCfg.UserLcProfile.Ccp[1].CcLevel;
				}
				if (h4 != h3) {
					a3 = (t4 - t3) / (h4 - h3);
					b3 = t3 - (a3 * h3);
				} else {
					a3 = 0;
					b3 = t3 = UnitCfg.UserLcProfile.Ccp[2].CcLevel;
				}
				if ((now >= h2) && (now <= h3)) {
					CtempOut = a2 * now + b2;
					if (CtempOut > 100) {
						CtempOut = 100;
					}
					if (CtempOut < 0) {
						CtempOut = 0;
					}
				} else if ((now >= h3) && (now <= h4)) {
					CtempOut = a3 * now + b3;
					if (CtempOut > 100) {
						CtempOut = 100;
					}
					if (CtempOut < 0) {
						CtempOut = 0;
					}
				}
				break;
			case 8:
				CtempOut = UnitCfg.UserLcProfile.Ccp[0].CcLevel;
				break;
			case 9:
				if (h4 != h1) {
					a3 = (t4 - t1) / (h4 - h1);
					b3 = t1 - (a3 * h1);
				} else {
					a3 = 0;
					b3 = t3 = UnitCfg.UserLcProfile.Ccp[0].CcLevel;
				}
				if ((now >= h1) && (now <= h4)) {
					CtempOut = a3 * now + b3;
					if (CtempOut > 100) {
						CtempOut = 100;
					}
					if (CtempOut < 0) {
						CtempOut = 0;
					}
				}
				break;
			case 10:
				if (h3 != h1) {
					a3 = (t3 - t1) / (h3 - h1);
					b3 = t1 - (a3 * h1);
				} else {
					a3 = 0;
					b3 = t3 = UnitCfg.UserLcProfile.Ccp[0].CcLevel;
				}
				if ((now >= h1) && (now <= h3)) {
					CtempOut = a3 * now + b3;
					if (CtempOut > 100) {
						CtempOut = 100;
					}
					if (CtempOut < 0) {
						CtempOut = 0;
					}
				}
				break;
			case 11:
				if (h3 != h1) {
					a2 = (t3 - t1) / (h3 - h1);
					b2 = t1 - (a2 * h1);
				} else {
					a2 = 0;
					b2 = t1 = UnitCfg.UserLcProfile.Ccp[1].CcLevel;
				}

				if (h4 != h3) {
					a3 = (t4 - t3) / (h4 - h3);
					b3 = t3 - (a3 * h3);
				} else {
					//the forever condition
					a3 = 0;
					b3 = t3 = UnitCfg.UserLcProfile.Ccp[3].CcLevel;
				}
				if ((now >= h1) && (now <= h3)) {
					CtempOut = a2 * now + b2;
					if (CtempOut > 100) {
						CtempOut = 100;
					}
					if (CtempOut < 0) {
						CtempOut = 0;
					}
				} else if ((now >= h3) && (now <= h4)) {
					CtempOut = a3 * now + b3;
					if (CtempOut > 100) {
						CtempOut = 100;
					}
					if (CtempOut < 0) {
						CtempOut = 0;
					}
				}
				break;
			case 12:
				if (h2 != h1) {
					a3 = (t2 - t1) / (h2 - h1);
					b3 = t1 - (a3 * h1);
				} else {
					//the forever condition
					a3 = 0;
					b3 = t3 = UnitCfg.UserLcProfile.Ccp[0].CcLevel;
				}
				if ((now >= h1) && (now <= h2)) {
					CtempOut = a3 * now + b3;
					if (CtempOut > 100) {
						CtempOut = 100;
					}
					if (CtempOut < 0) {
						CtempOut = 0;
					}
				}
				break;
			case 13:
				if (h2 != h1) {
					a1 = (t2 - t1) / (h2 - h1);
					b1 = t1 - (a1 * h1);
				} else {
					//the forever condition
					a1 = 0;
					b1 = t1 = UnitCfg.UserLcProfile.Ccp[0].CcLevel;
				}

				if (h4 != h3) {
					a3 = (t4 - t3) / (h4 - h3);
					b3 = t3 - (a3 * h3);
				} else {
					//the forever condition
					a3 = 0;
					b3 = t3 = UnitCfg.UserLcProfile.Ccp[2].CcLevel;
				}
				if ((now >= h1) && (now <= h2)) {
					CtempOut = a1 * now + b1;
					if (CtempOut > 100) {
						CtempOut = 100;
					}
					if (CtempOut < 0) {
						CtempOut = 0;
					}
				} else if ((now >= h3) && (now <= h4)) {
					CtempOut = a3 * now + b3;
					if (CtempOut > 100) {
						CtempOut = 100;
					}
					if (CtempOut < 0) {
						CtempOut = 0;
					}
				}
				break;
			case 14:
				if (h2 != h1) {
					a1 = (t2 - t1) / (h2 - h1);
					b1 = t1 - (a1 * h1);
				} else {
					//the forever condition
					a1 = 0;
					b1 = t1 = UnitCfg.UserLcProfile.Ccp[0].CcLevel;
				}

				if (h3 != h2) {
					a2 = (t3 - t2) / (h3 - h2);
					b2 = t2 - (a2 * h2);
				} else {
					//the forever condition
					a2 = 0;
					b2 = t2 = UnitCfg.UserLcProfile.Ccp[1].CcLevel;
				}
				if ((now >= h1) && (now <= h2)) {
					CtempOut = a1 * now + b1;
					if (CtempOut > 100) {
						CtempOut = 100;
					}
					if (CtempOut < 0) {
						CtempOut = 0;
					}
				} else if ((now >= h2) && (now <= h3)) {
					CtempOut = a2 * now + b2;
					if (CtempOut > 100) {
						CtempOut = 100;
					}
					if (CtempOut < 0) {
						CtempOut = 0;
					}
				}
				break;
			case 15:
				if (h2 != h1) {
					a1 = (t2 - t1) / (h2 - h1);
					b1 = t1 - (a1 * h1);
				} else {
					//the forever condition
					a1 = 0;
					b1 = t1 = UnitCfg.UserLcProfile.Ccp[0].CcLevel;
				}

				if (h3 != h2) {
					a2 = (t3 - t2) / (h3 - h2);
					b2 = t2 - (a2 * h2);
				} else {
					//the forever condition
					a2 = 0;
					b2 = t2 = UnitCfg.UserLcProfile.Ccp[1].CcLevel;
				}
				if (h4 != h3) {
					a3 = (t4 - t3) / (h4 - h3);
					b3 = t3 - (a3 * h3);
				} else {
					//the forever condition
					a3 = 0;
					b3 = t3 = UnitCfg.UserLcProfile.Ccp[2].CcLevel;
				}
				if ((now >= h1) && (now <= h2)) {
					CtempOut = a1 * now + b1;
					if (CtempOut > 100) {
						CtempOut = 100;
					}
					if (CtempOut < 0) {
						CtempOut = 0;
					}
				} else if ((now >= h2) && (now <= h3)) {
					CtempOut = a2 * now + b2;
					if (CtempOut > 100) {
						CtempOut = 100;
					}
					if (CtempOut < 0) {
						CtempOut = 0;
					}
				} else if ((now >= h3) && (now <= h4)) {
					CtempOut = a3 * now + b3;
					if (CtempOut > 100) {
						CtempOut = 100;
					}
					if (CtempOut < 0) {
						CtempOut = 0;
					}
				} else {
					CtempOut = UnitCfg.UserLcProfile.Ccp[2].CcLevel;
				}
				break;
			default:
				break;
			}

			ESP_LOGI(TAG, "ACTC Level %d @ %ld", CtempOut, now);

			cc_zone_int = strtol(UnitCfg.UserLcProfile.ZoneCc, NULL, 16);

			MilightHandler(LCMD_SET_TEMP, (uint8_t) CtempOut,
					cc_zone_int & 0x0F);
			for (i = 0; i < 4; i++) {
				zone_number = cc_zone_int & (1 << i);

				switch (zone_number) {
				case 1:
					zone_number = 0;
					break;
				case 2:
					zone_number = 1;
					break;
				case 4:
					zone_number = 2;
					break;
				case 8:
					zone_number = 3;
					break;
				default:
					continue;
				}
				UnitCfg.Zones_info[zone_number].Temperature =
						(uint8_t) CtempOut;
			}
		}

		if (CCTestStruct.CcEnb == true) {
			h1 = CCTestStruct.Ccp[0].CcTime;
			h2 = CCTestStruct.Ccp[1].CcTime;
			h3 = CCTestStruct.Ccp[2].CcTime;

			now = h1 + (((h3 - h1) * CCTestStruct.SimTime) / 100.0);

			t1 = CCTestStruct.Ccp[0].CcLevel;
			t2 = CCTestStruct.Ccp[1].CcLevel;
			t3 = CCTestStruct.Ccp[2].CcLevel;

			if (h2 != h1) {
				a1 = (t2 - t1) / (h2 - h1);
				b1 = t1 - (a1 * h1);
			} else {
				a1 = 0;
				b1 = t1 = CCTestStruct.Ccp[0].CcLevel;
			}

			if (h3 != h2) {
				a2 = (t3 - t2) / (h3 - h2);
				b2 = t2 - (a2 * h2);
			} else {
				a2 = 0;
				b2 = CCTestStruct.Ccp[1].CcLevel;
			}

			// actc
			if (CCTestStruct.CcEnb == true) {
				if ((now > h1) && (now < h2)) {
					CtempOut_test = a1 * now + b1;
					if (CtempOut_test > 100)
						CtempOut_test = 100;
					if (CtempOut_test < 0)
						CtempOut_test = 0;
				} else if ((now > h2) && (now < h3)) {
					CtempOut_test = a2 * now + b2;
					if (CtempOut_test > 100)
						CtempOut_test = 100;
					if (CtempOut_test < 0)
						CtempOut_test = 0;
				} else {
					CtempOut_test = CCTestStruct.Ccp[2].CcLevel;
				}
			} else {
				ESP_LOGI(TAG, "INIT out cycle \n");
				CtempOut_test = 0;
			}

			ESP_LOGI(TAG, "ACTC Test Level %d @ %ld", CtempOut_test, now);

			cc_zone_int = strtol(CCTestStruct.ZoneCc, NULL, 16);

			MilightHandler(LCMD_SET_TEMP, (uint8_t) CtempOut_test,
					cc_zone_int & 0x0F);
			for (i = 0; i < 4; i++) {
				zone_number = cc_zone_int & (1 << i);

				switch (zone_number) {
				case 1:
					zone_number = 0;
					break;
				case 2:
					zone_number = 1;
					break;
				case 4:
					zone_number = 2;
					break;
				case 8:
					zone_number = 3;
					break;
				default:
					continue;
				}
				UnitCfg.Zones_info[zone_number].Temperature =
						(uint8_t) CtempOut_test;
			}
		}

		vTaskDelay(1000 / portTICK_RATE_MS);
	}

	ESP_LOGI(TAG, "ACTC TASK EXIT");
	vTaskDelete(NULL);
}

// PIR Low level Handler

bool NoticeTimeoutTask = false;
time_t NoticeTimeout = 0;

bool PirTimeoutTask = false;
time_t PirTimeout = 0;
bool PirOutCmd = false;
bool PirDetectionOverride = false;

void PirTimeoutRoutine() {
	PirTimeoutTask = true;
	PirOutCmd = true;

	while (PirTimeout > 0) {
		PirTimeout--;
		//sprintf ("time of detection : %ld\n",PirTimeout);
		vTaskDelay(1000 / portTICK_RATE_MS);
	}

	PirOutCmd = false;
	PirTimeoutTask = false;
	vTaskDelete(NULL);
}

void Pir_MonitorTask() {
	//pir
	while (1) {
		if (PirFlag == 1 && UnitCfg.UserLcProfile.PIRBrEnb
				&& UnitCfg.UserLcProfile.Alum_Exten_enb) {
			PirFlag = 0;
			PirTimeout = UnitCfg.UserLcProfile.PirTimeout;
			if (PirTimeout == 0) {
				PirTimeout = 5;
			}
			//ESP_LOGI(TAG, "PIR Triggered + %ld",PirTimeout);
			if (PirTimeoutTask == false) {
				xTaskCreatePinnedToCore(&PirTimeoutRoutine, "PirTimeoutRoutine",
						2048, NULL, 5, NULL, 1);
			}
		}

		vTaskDelay(100 / portTICK_RATE_MS);
	}
}

// CO2
uint8_t zone = 0;
bool co2_alert_enable = false;
bool co2_triger_alert = false;

void Co2_MonitorTask() {

	while (1) {
		zone = strtol(UnitCfg.Co2LevelSelect, NULL, 16);
		//co2
		if (UnitCfg.Co2LevelWarEnb == true) {
			if ((iaq_data.pred > UnitCfg.Co2LevelWar)
					&& (co2_alert_enable == 0)) {
				co2_alert_enable = 1;
				co2_triger_alert = true;
				ESP_LOGI(TAG, "Co2 Warning triggered");
				//zone
				if (UnitCfg.Co2LevelZoneEnb == true) {
					UnitData.state = 0;
					ESP_LOGI(TAG, "Co2 zone Warning triggered");
					MilightHandler(LCMD_SWITCH_ON_OFF, LSUBCMD_SWITCH_ON,
							zone & 0x0F);
					vTaskDelay(50 / portTICK_RATE_MS);
					MilightHandler(LCMD_SET_SAT, 100, zone & 0x0F);
					vTaskDelay(50 / portTICK_RATE_MS);
					MilightHandler(LCMD_SET_MODE, 6, zone & 0x0F);
				}
				//email
				if ((WifiConnectedFlag == true)
						&& (UnitCfg.Co2LevelEmailEnb == true)) {
					ESP_LOGI(TAG, "Co2 email Warning triggered");
					if (test_security) {
						TestorAlert = false;
						test_security = false;
						xTaskCreatePinnedToCore(&Task_emailclient,
								"Task_emailclient", 9000, NULL, 2, NULL, 1);
					}
				}
			}
			//desativate co2 and init the light
			if ((iaq_data.pred < UnitCfg.Co2LevelWar)
					&& (co2_alert_enable == 1)) {
				ESP_LOGI(TAG, "Co2 Warning off");
				co2_alert_enable = 0;
				co2_triger_alert = false;
				if (UnitCfg.Co2LevelZoneEnb == true) {
					UnitData.state = 0;
					MilightHandler(LCMD_SET_WHITE, 0, zone & 0x0F);
					vTaskDelay(100 / portTICK_RATE_MS);
					MilightHandler(LCMD_SET_WHITE, 0, zone & 0x0F);
					vTaskDelay(50 / portTICK_RATE_MS);
					MilightHandler(LCMD_SET_BRIGTHNESS, 100, zone & 0x0F);
				}
			}
		}
		if (iaq_data.pred < 1699) {
			UnitSetStatus(UNIT_STATUS_NORMAL);
		} else if (iaq_data.pred < 1999) {
			UnitSetStatus(UNIT_STATUS_WARNING_CO2);
		} else {
			UnitSetStatus(UNIT_STATUS_ALERT_CO2);
		}
		vTaskDelay(1000 / portTICK_RATE_MS);
	}
}

