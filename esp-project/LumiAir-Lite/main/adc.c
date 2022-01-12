#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/gpio.h"
#include "driver/adc.h"
#include "esp_adc_cal.h"
#include "sdkconfig.h"
#include "lwip/err.h"
#include "math.h"
#include <esp_log.h>
#include "lwip/apps/sntp.h"
#include "soc/adc_channel.h"

#include "adc.h"
#include "unitcfg.h"
#include "webservice.h"

#define DEFAULT_VREF    1100        //Use adc2_vref_to_gpio() to obtain a better estimate
//#define NO_OF_SAMPLES   64          //Multisampling

static esp_adc_cal_characteristics_t *adc_chars;
static const adc_channel_t channel = ADC1_GPIO32_CHANNEL;     //
static const adc_channel_t channel_vref = ADC1_GPIO35_CHANNEL;     //
static const adc_channel_t channel_tana = ADC1_GPIO33_CHANNEL;     //

static const adc_atten_t atten = ADC_ATTEN_DB_11;
static const adc_unit_t unit = ADC_UNIT_1;

int32_t Pirdelta = 0;
uint8_t PirFlag = 0;
uint8_t Occur = 0;

uint32_t integral = 0;
uint32_t timer = 1;
bool integralFlag = false;
int32_t avr = 0;

double GetTemp(float AdcValue) {
	double AdcT;

	AdcT = ((8.194 - sqrt((8.194 * 8.184) + 4 * 0.00262 * (1324 - AdcValue)))
			/ (2 * (-0.00262))) + 30;
	return (AdcT);
}
char strftime_buf[64];
struct tm now_adc = { 0 };
struct timeval tv_adc;

void adc_task() {
	//Configure ADC

	adc1_config_width(ADC_WIDTH_BIT_12);
	adc1_config_channel_atten(channel, atten);
	adc1_config_channel_atten(channel_vref, atten);
	adc1_config_channel_atten(channel_tana, atten);

	//Characterize ADC
	adc_chars = calloc(1, sizeof(esp_adc_cal_characteristics_t));
	esp_adc_cal_characterize(unit, atten, ADC_WIDTH_BIT_12, DEFAULT_VREF,
			adc_chars);
	//uint32_t AnaTempVoltage;

	//Continuously sample ADC1
	while (1) {
		uint32_t adc_reading = 0;
		uint32_t adc_reading_vref = 0;
		uint32_t adc_reading_vtana = 0;
		uint32_t PirdeltaSum = 0;
		double PirdeltaRMS = 0;
		//Multisampling
		for (int i = 0; i < 30; i++) {
			adc_reading = adc1_get_raw((adc1_channel_t) channel);
			adc_reading_vref = adc1_get_raw((adc1_channel_t) channel_vref);
			adc_reading_vtana += adc1_get_raw((adc1_channel_t) channel_tana);

			Pirdelta = adc_reading - adc_reading_vref;
			PirdeltaSum += Pirdelta * Pirdelta;
		}

		adc_reading_vtana /= 30;

		PirdeltaRMS = sqrt(PirdeltaSum / 30);

		if (PirdeltaRMS > UnitCfg.PirSensitivity)
			Occur++;
		if (Occur > 2) {
			PirFlag = 1;
			Occur = 0;
			time(&UnitData.LastDetTime);
		}

		//float rvref=esp_adc_cal_raw_to_voltage(adc_reading_vref,adc_chars);

		//TANA

		//AnaTempVoltage = esp_adc_cal_raw_to_voltage(adc_reading_vtana,adc_chars)*(1650.0/rvref);
		//UnitData.Temp = GetTemp(AnaTempVoltage);

		vTaskDelay(10 / portTICK_PERIOD_MS);
	}
}

void AdcInit() {
	xTaskCreatePinnedToCore(&adc_task, "adctask", 2048, NULL, 5, NULL, 1);
}
