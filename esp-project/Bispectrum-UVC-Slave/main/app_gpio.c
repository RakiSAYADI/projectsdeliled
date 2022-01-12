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

#include "main.h"

int cntrl_pins[4] = { 27, 26, 25, 33 };

#define PIR_GPIO  16

const char* GPIO_TAG = "app_gpio";

#define RelayStateOFF 0
#define RelayStateON 1

#define UVRelay 0
#define RedLightRelay 1
#define GreenLightRelay 2
#define BuzzerRelay 3

bool redLightEnable = false;
bool buzzerEnable = false;

uint16_t phaseTimeStep = 0;
int32_t phaseTime = 0;
int32_t phaseTimeExecuted = 0;

int set_relay_state(int relay, uint32_t level) {
	if ((relay >= 0) && (relay < 4)) {
		gpio_set_level(cntrl_pins[relay], level);
		cntrl_states[relay] = level;
	} else {

		return 0;
	}
	return 1;
}

void redRelayAlert() {
	ESP_LOGI(GPIO_TAG, "Red light on !");
	while (1) {
		if (redLightEnable) {
			set_relay_state(RedLightRelay, RelayStateON);
			delay(500);
			set_relay_state(RedLightRelay, RelayStateOFF);
			delay(500);
		} else {
			delay(200);
		}
	}
	vTaskDelete(NULL);
}

void buzzerRelayAlert() {
	ESP_LOGI(GPIO_TAG, "Buzzzer on !");
	while (1) {
		if (buzzerEnable) {
			set_relay_state(BuzzerRelay, RelayStateON);
			delay(500);
			set_relay_state(BuzzerRelay, RelayStateOFF);
			delay(2000);
		} else {

			delay(200);
		}
	}
	vTaskDelete(NULL);
}
void StopUVTreatement() {
	ESP_LOGI(GPIO_TAG, "Detection ! START ALARM");
	phaseTimeStep = 3500;
	phaseTime = 5;
	phaseTime *= 1000;
	set_relay_state(UVRelay, RelayStateOFF);
	set_relay_state(GreenLightRelay, RelayStateOFF);
	while (phaseTime > 0) {
		redLightEnable = true;
		buzzerEnable = true;
		phaseTime -= phaseTimeStep;
		delay(phaseTimeStep);
	}
	detectionTriggered = false;
	redLightEnable = false;
	buzzerEnable = false;
	stopIsPressed = false;
	delay(500);
	UVCThreadState = false;
	ChekingDetectionOnUVC = false;
	UnitCfg.UVCTimeExecution += phaseTimeExecuted / 1000;
	ESP_LOGI(GPIO_TAG, "UVC Time executed: %d",UnitCfg.UVCTimeExecution);
	SaveNVS(&UnitCfg);
	set_relay_state(RedLightRelay, RelayStateON);

}

void UVCTreatement() {
	while (1) {
		if (UVCThreadState) {
			ESP_LOGI(GPIO_TAG, "SETTING the safety treatement !");
			set_relay_state(GreenLightRelay, RelayStateOFF);
			UnitCfg.NumberOfDisinfection++;
			stopIsPressed = false;
			phaseTime = UnitCfg.ActivationTime;
			phaseTimeStep = 3500;
			phaseTime *= 1000;
			while (phaseTime > 0) {
				ESP_LOGI(GPIO_TAG, "%d !", phaseTime);
				redLightEnable = true;
				buzzerEnable = true;
				phaseTime -= phaseTimeStep;
				delay(phaseTimeStep);
				if (stopIsPressed) {
					break;
				}
			}
			if (stopIsPressed) {
				ESP_LOGI(GPIO_TAG, "STOP is Pressed !");
				stopIsPressed = false;
				redLightEnable = false;
				buzzerEnable = false;
				set_relay_state(UVRelay, RelayStateOFF);
				UVCThreadState = false;
				delay(600);
				set_relay_state(RedLightRelay, RelayStateON);
			} else {
				ChekingDetectionOnUVC = true;
				ESP_LOGI(GPIO_TAG, "CHECKING the PIR Sensor !");
				delay(100);
				xTaskCreate(&CheckingPressence, "CheckingPressence",
				configMINIMAL_STACK_SIZE * 3, NULL, 5,
				NULL);
				if (detectionTriggered) {
					StopUVTreatement();
				} else {
					phaseTime = UnitCfg.DisinfictionTime;
					redLightEnable = false;
					buzzerEnable = false;
					phaseTimeStep = 50;
					phaseTime *= 1000;
					phaseTimeExecuted = 0;
					ESP_LOGI(GPIO_TAG, "SETTING the UVC treatement !");
					while (phaseTime > 0) {
						if (detectionTriggered) {
							StopUVTreatement();
							break;
						} else {
							set_relay_state(GreenLightRelay, RelayStateON);
							set_relay_state(UVRelay, RelayStateON);
						}
						phaseTime -= phaseTimeStep;
						phaseTimeExecuted += phaseTimeStep;
						delay(phaseTimeStep);
						if (stopIsPressed) {
							ESP_LOGI(GPIO_TAG, "STOP is Pressed !");
							stopIsPressed = false;
							set_relay_state(UVRelay, RelayStateOFF);
							set_relay_state(GreenLightRelay, RelayStateOFF);
							delay(600);
							set_relay_state(RedLightRelay, RelayStateON);
							break;
						}
					}
				}
				set_relay_state(UVRelay, RelayStateOFF);
				UVCThreadState = false;
				UnitCfg.UVCTimeExecution += phaseTimeExecuted / 1000;
				ESP_LOGI(GPIO_TAG, "UVC Time executed: %d",UnitCfg.UVCTimeExecution);
				SaveNVS(&UnitCfg);
				ChekingDetectionOnUVC = false;
			}
		}
		delay(20);
	}
}

uint8_t strContains(char* string, char* toFind) {
	uint8_t slen = strlen(string);
	uint8_t tFlen = strlen(toFind);
	uint8_t found = 0;

	if (slen >= tFlen) {
		for (uint8_t s = 0, t = 0; s < slen; s++) {
			do {

				if (string[s] == toFind[t]) {
					if (++found == tFlen)
						return 1;
					s++;
					t++;
				} else {
					s -= found;
					found = 0;
					t = 0;
				}

			} while (found);
		}
		return 0;
	} else
		return -1;
}

void resetAllBools() {
	detectionTriggered = false;
	stopIsPressed = false;
	ChekingDetectionOnUVC = false;
	UVCThreadState = false;
}

void LedStatusTask() {

	resetAllBools();

	// initialize the gpio
	int i;

	for (i = 0; i < 4; i++) {
		gpio_pad_select_gpio(cntrl_pins[i]);
		gpio_set_direction(cntrl_pins[i], GPIO_MODE_OUTPUT);
		// setting all relay OFF
		gpio_set_level(cntrl_pins[i], 0);
		cntrl_states[i] = 0;
	}

	gpio_pad_select_gpio(PIR_GPIO);
	gpio_set_direction(PIR_GPIO, GPIO_MODE_INPUT);

	set_relay_state(GreenLightRelay, RelayStateON);

	xTaskCreate(&redRelayAlert, "redRelayAlert", 2048, NULL, 5,
	NULL);
	xTaskCreate(&buzzerRelayAlert, "buzzerRelayAlert", 2048, NULL, 5,
	NULL);
	xTaskCreate(&UVCTreatement, "UVCTreatement",
	configMINIMAL_STACK_SIZE * 3, NULL, 2,
	NULL);

	while (1) {
		//ESP_LOGI(GPIO_TAG, "the detection state is : %d",gpio_get_level(GPIO_NUM_16));
		if ((gpio_get_level(GPIO_NUM_16) == 1) && (ChekingDetectionOnUVC)) {
			detectionTriggered = true;
			ESP_LOGI(GPIO_TAG, "STOP UVC TREATEMENT, WE HAVE DETECTION !");
		}
		delay(50);
	}
}

void LedStatInit() {
	//Led and relay task
	xTaskCreate(&LedStatusTask, "LedStatusTask",
	configMINIMAL_STACK_SIZE * 3, NULL, 1, NULL);
}

