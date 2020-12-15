/* LEDC (LED Controller) fade example

 This example code is in the Public Domain (or CC0 licensed, at your option.)

 Unless required by applicable law or agreed to in writing, this
 software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 CONDITIONS OF ANY KIND, either express or implied.
 */
#include <stdio.h>
#include <math.h>
#include <string.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/ledc.h"
#include "esp_err.h"
#include "driver/gpio.h"
#include "freertos/queue.h"
#include "xtensa/core-macros.h"
#include "esp_log.h"

#include "sdkconfig.h"

#include "lightcontrol.h"

#define GPIO_INPUT_PAIR			0		//Pair button

#define GPIO_INPUT_RED     		4		//O1
#define GPIO_INPUT_GREEN    	27		//O4
#define GPIO_INPUT_BLUE	    	14		//O5
#define GPIO_INPUT_WHITE    	18		//O3
#define GPIO_INPUT_WARM_WHITE   5		//O2

#define GPIO_ZONE_0    			32		//Z0
#define GPIO_ZONE_1    			33		//Z1
#define GPIO_ZONE_2    			25		//Z2
#define GPIO_ZONE_3    			26		//Z3

#define GPIO_INPUT_PIN_SEL  ((1ULL<<GPIO_INPUT_PAIR) |(1ULL<<GPIO_INPUT_RED) | (1ULL<<GPIO_INPUT_GREEN)| (1ULL<<GPIO_INPUT_BLUE)| (1ULL<<GPIO_INPUT_WHITE)| (1ULL<<GPIO_INPUT_WARM_WHITE))
#define GPIO_ZONE_PIN_SEL  ((1ULL<<GPIO_ZONE_3) |(1ULL<<GPIO_ZONE_2) | (1ULL<<GPIO_ZONE_1)| (1ULL<<GPIO_ZONE_0))
#define ESP_INTR_FLAG_DEFAULT 0

#define STB_REDGE	0
#define STB_FEDGE	1
#define STB_SREDGE	2
#define STB_READ	3

typedef struct {
	uint8_t ChNbr;
	uint8_t GpioStat;
	uint64_t MarkCount;
	uint64_t PprdCount;
	uint64_t PlvlCount;
	float frq;
	float dc;
	uint16_t binEq;
} GpioIntRegister;

GpioIntRegister Gpio_Red = { GPIO_INPUT_RED, 0, 0, 0, 0, 0.0, 0.0, 0 };
GpioIntRegister Gpio_Green = { GPIO_INPUT_GREEN, 0, 0, 0, 0, 0.0, 0.0, 0 };
GpioIntRegister Gpio_Blue = { GPIO_INPUT_BLUE, 0, 0, 0, 0, 0.0, 0.0, 0 };
GpioIntRegister Gpio_White = { GPIO_INPUT_WHITE, 0, 0, 0, 0, 0.0, 0.0, 0 };
GpioIntRegister Gpio_WarmWhite = { GPIO_INPUT_WARM_WHITE, 0, 0, 0, 0, 0.0, 0.0,
		0 };

void GpioIntStateMachine(GpioIntRegister *gpio) {

	uint64_t tmp = 0;
	tmp = XTHAL_GET_CCOUNT();

	switch (gpio->GpioStat) {
	case STB_REDGE:
		if (gpio_get_level(gpio->ChNbr) == 1) {
			gpio->MarkCount = tmp;
			gpio->PprdCount = 0;
			gpio->PlvlCount = 0;
			gpio->GpioStat = STB_FEDGE;
		}
		break;

	case STB_FEDGE:
		if (gpio_get_level(gpio->ChNbr) == 0) {
			if (tmp > gpio->MarkCount) {
				gpio->PlvlCount = tmp - gpio->MarkCount;
				gpio->GpioStat = STB_SREDGE;
			} else {
				Gpio_Red.GpioStat = STB_REDGE;
			}
		} else {
			Gpio_Red.GpioStat = STB_REDGE;
		}
		break;

	case STB_SREDGE:
		if (gpio_get_level(gpio->ChNbr) == 1) {
			if (tmp > gpio->PlvlCount) {
				gpio->PprdCount = tmp - gpio->MarkCount;
				gpio->GpioStat = STB_READ;
			} else {
				Gpio_Red.GpioStat = STB_REDGE;
			}
		} else {
			gpio->GpioStat = STB_REDGE;
		}
		break;

	case STB_READ:
		break;
	}
}

static void IRAM_ATTR gpio_isr_handler(void* arg)
{
	uint32_t gpio_num = (uint32_t) arg;

	switch (gpio_num)
	{
		case GPIO_INPUT_RED : GpioIntStateMachine(&Gpio_Red);break;
		case GPIO_INPUT_GREEN : GpioIntStateMachine(&Gpio_Green);break;
		case GPIO_INPUT_BLUE : GpioIntStateMachine(&Gpio_Blue);break;
		case GPIO_INPUT_WHITE : GpioIntStateMachine(&Gpio_White);break;
		case GPIO_INPUT_WARM_WHITE : GpioIntStateMachine(&Gpio_WarmWhite);break;

		default:
		break;
	}

}

uint64_t SampleNum = 0;
float TimeFactor = 1 / 240e6;

void ExtractSigProp(GpioIntRegister *gpio) {

	float frq = 0.0;
	uint64_t NlvlCount = 0;
	float dcyc = 0.0;
	char chn[8];

	SampleNum++;

	if (gpio->GpioStat == STB_READ) {
		frq = 1 / (gpio->PprdCount * TimeFactor);
		NlvlCount = gpio->PprdCount - gpio->PlvlCount;
		dcyc = round(((float) NlvlCount * 100.0) / (float) gpio->PprdCount);
		gpio->GpioStat = STB_REDGE;
	} else {
		if (gpio_get_level(gpio->ChNbr) == 1) {
			dcyc = 0.0;
			gpio->PprdCount = 0;
			frq = 0.0;
		} else {
			dcyc = 100.0;
			gpio->PprdCount = 0;
			frq = 0.0;
		}
	}

	gpio->dc = dcyc;
	gpio->frq = frq;
	gpio->binEq = 255 * (dcyc / 100.0);

	switch (gpio->ChNbr) {
	case GPIO_INPUT_RED:
		strcpy(chn, "RED");
		break;
	case GPIO_INPUT_GREEN:
		strcpy(chn, "GREEN");
		break;
	case GPIO_INPUT_BLUE:
		strcpy(chn, "BLUE");
		break;
	case GPIO_INPUT_WHITE:
		strcpy(chn, "WHITE");
		break;
	case GPIO_INPUT_WARM_WHITE:
		strcpy(chn, "WARM_WHITE");
		break;

	default:
		strcpy(chn, "NONE");
		break;
	}

	//printf("sn %lld (%s) cnt: UP %lld PRD %lld frq:%0.2f dc %0.2f\n", SampleNum,chn,NlvlCount,gpio->PprdCount,frq,dcyc);

}

typedef struct {
	uint8_t Hue;
	uint8_t Sat;
	uint8_t Bri;
} HSLStruct;

void RgbToHSL(uint32_t rgb, HSLStruct *tmp) {

	float R = 0, G = 0, B = 0;
	;
	uint8_t r = 0, g = 0, b = 0;

	r = rgb >> 16;
	g = rgb >> 8;
	b = rgb;

	R = r / 255.0;
	G = g / 255.0;
	B = b / 255.0;

	float min = 1000, max = 0;
	char cmax = 'R';

	if (max < R) {
		max = R;
		cmax = 'R';
	}
	if (max < G) {
		max = G;
		cmax = 'G';
	}
	if (max < B) {
		max = B;
		cmax = 'B';
	}

	if (min > R)
		min = R;
	if (min > G)
		min = G;
	if (min > B)
		min = B;

	float Hue = 0;

	switch (cmax) {
	case 'R':
		Hue = (G - B) / (max - min);
		break;
	case 'G':
		Hue = 2.0 + (B - R) / (max - min);
		break;
	case 'B':
		Hue = 4.0 + (R - G) / (max - min);
		break;
	}

	Hue *= 60;
	if (Hue < 0)
		Hue += 360;

	Hue /= 360;

	tmp->Hue = (uint8_t) round(255.0 * Hue);

	float lum = ((min + max) / 2) * 100;
	tmp->Bri = (uint8_t) round(lum);

	float sat = 0;
	if (lum > 50)
		sat = (max - min) / (2.0 - max - min);
	else
		sat = (max - min) / (max + min);
	sat *= 100;
	tmp->Sat = (uint8_t) round(sat);

}

void MilightApplyConfig(uint8_t r, uint8_t g, uint8_t b, uint8_t w, uint8_t ww,
		uint8_t zone) {
	uint32_t rgb = (r * 0x10000) + (g * 0x100) + b;
	uint8_t cmd = 0, subcmd = 0;
	HSLStruct HSLtmp;

	if ((w == 0) && (ww == 0)) {
		RgbToHSL(rgb, &HSLtmp);

		subcmd = HSLtmp.Hue;
		cmd = LCMD_SET_COLOR;
		MilightHandler(cmd, subcmd, zone);
		ESP_LOGI("PWM", "Light control cmd %d subcmd %d zone %d", cmd, subcmd,
				zone);
		vTaskDelay(70 / portTICK_RATE_MS);

		subcmd = HSLtmp.Sat;
		cmd = LCMD_SET_SAT;
		MilightHandler(cmd, subcmd, zone);
		ESP_LOGI("PWM", "Light control cmd %d subcmd %d zone %d", cmd, subcmd,
				zone);
		vTaskDelay(70 / portTICK_RATE_MS);

		subcmd = HSLtmp.Bri;
		cmd = LCMD_SET_BRIGTHNESS;
		MilightHandler(cmd, subcmd, zone);
		ESP_LOGI("PWM", "Light control cmd %d subcmd %d zone %d", cmd, subcmd,
				zone);
	} else {
		float wadjp = 0, wwadjp = 0;

		wadjp = ((float) w * 100.0) / (ww + w);
		wwadjp = ((float) ww * 100.0) / (ww + w);

		subcmd = (uint8_t) round(wwadjp);
		cmd = LCMD_SET_TEMP;
		MilightHandler(cmd, subcmd, zone);
		ESP_LOGI("PWM", "Light control cmd %d subcmd %d zone %d", cmd, subcmd,
				zone);
		vTaskDelay(70 / portTICK_RATE_MS);

		wadjp = w / 255.0;
		wwadjp = ww / 255.0;

		if (wadjp > wwadjp)
			subcmd = wadjp * 100.0;
		else
			subcmd = wwadjp * 100.0;

		cmd = LCMD_SET_BRIGTHNESS;
		MilightHandler(cmd, subcmd, zone);
		ESP_LOGI("PWM", "Light control cmd %d subcmd %d zone %d", cmd, subcmd,
				zone);
	}
}

uint16_t Last_Red = 0, Last_Green = 0, Last_Blue = 0, Last_White = 0,
		Last_WarmWhite = 0;

bool startcounter = false;

uint8_t selZone = 0, counter = 0;

void gpio_task_delay(void* arg) {

	while (1) {
		if (startcounter) {
			MilightApplyConfig(Gpio_Red.binEq, Gpio_Green.binEq,
					Gpio_Blue.binEq, Gpio_White.binEq, Gpio_WarmWhite.binEq,
					~selZone & 0x0F);
			Last_Red = Gpio_Red.binEq;
			Last_Green = Gpio_Green.binEq;
			Last_Blue = Gpio_Blue.binEq;
			Last_White = Gpio_White.binEq;
			Last_WarmWhite = Gpio_WarmWhite.binEq;
			counter++;
			if (counter >= 50) {
				counter = 0;
				startcounter = false;
			}
		}
		vTaskDelay(50 / portTICK_RATE_MS);
	}
}

void gpio_task(void* arg) {

	while (1) {

		ExtractSigProp(&Gpio_Red);
		ExtractSigProp(&Gpio_Green);
		ExtractSigProp(&Gpio_Blue);
		ExtractSigProp(&Gpio_White);
		ExtractSigProp(&Gpio_WarmWhite);

		selZone = ((gpio_get_level(GPIO_ZONE_3) << 3)
				| (gpio_get_level(GPIO_ZONE_2) << 2)
				| (gpio_get_level(GPIO_ZONE_1) << 1)
				| gpio_get_level(GPIO_ZONE_0));

		if ((Last_Red != Gpio_Red.binEq) || (Last_Green != Gpio_Green.binEq)
				|| (Last_Blue != Gpio_Blue.binEq)
				|| (Last_White != Gpio_White.binEq)
				|| (Last_WarmWhite != Gpio_WarmWhite.binEq)) {
			startcounter = true;
			counter = 0;
		} else {
			startcounter = false;
		}

		printf("sn %08lld R %03u G %03u B %03u W %03u WW %03u \n", SampleNum,
				Gpio_Red.binEq, Gpio_Green.binEq, Gpio_Blue.binEq,
				Gpio_White.binEq, Gpio_WarmWhite.binEq);

		vTaskDelay(100 / portTICK_RATE_MS);
	}
}

void app_main() {

	gpio_config_t io_conf;

	//interrupt of rising edge
	io_conf.intr_type = GPIO_PIN_INTR_POSEDGE;
	//bit mask of the pins, use GPIO4/5 here
	io_conf.pin_bit_mask = GPIO_INPUT_PIN_SEL;
	//set as input mode
	io_conf.mode = GPIO_MODE_INPUT;
	//enable pull-up mode
	io_conf.pull_up_en = 0;
	gpio_config(&io_conf);

	io_conf.pin_bit_mask = GPIO_ZONE_PIN_SEL;
	gpio_config(&io_conf);

	//change gpio intrrupt type for one pin
	gpio_set_intr_type(GPIO_INPUT_RED, GPIO_INTR_ANYEDGE);
	gpio_set_intr_type(GPIO_INPUT_GREEN, GPIO_INTR_ANYEDGE);
	gpio_set_intr_type(GPIO_INPUT_BLUE, GPIO_INTR_ANYEDGE);
	gpio_set_intr_type(GPIO_INPUT_WHITE, GPIO_INTR_ANYEDGE);
	gpio_set_intr_type(GPIO_INPUT_WARM_WHITE, GPIO_INTR_ANYEDGE);

	//start gpio task
	xTaskCreate(gpio_task, "gpio_task", 2048, NULL, 10, NULL);

	//start gpio task
	xTaskCreate(gpio_task_delay, "gpio_task_delay", 2048, NULL, 10, NULL);

	//install gpio isr service
	gpio_install_isr_service(ESP_INTR_FLAG_DEFAULT);
	//hook isr handler for specific gpio pin
	gpio_isr_handler_add(GPIO_INPUT_RED, gpio_isr_handler,
			(void*) GPIO_INPUT_RED);
	//hook isr handler for specific gpio pin
	gpio_isr_handler_add(GPIO_INPUT_GREEN, gpio_isr_handler,
			(void*) GPIO_INPUT_GREEN);
	//hook isr handler for specific gpio pin
	gpio_isr_handler_add(GPIO_INPUT_BLUE, gpio_isr_handler,
			(void*) GPIO_INPUT_BLUE);
	//hook isr handler for specific gpio pin
	gpio_isr_handler_add(GPIO_INPUT_WHITE, gpio_isr_handler,
			(void*) GPIO_INPUT_WHITE);
	//hook isr handler for specific gpio pin
	gpio_isr_handler_add(GPIO_INPUT_WARM_WHITE, gpio_isr_handler,
			(void*) GPIO_INPUT_WARM_WHITE);

	lightControl_Init();

	while (1) {
		if (gpio_get_level(GPIO_INPUT_PAIR) == 0) {
			uint8_t selZone = ((gpio_get_level(GPIO_ZONE_3) << 3)
					| (gpio_get_level(GPIO_ZONE_2) << 2)
					| (gpio_get_level(GPIO_ZONE_1) << 1)
					| gpio_get_level(GPIO_ZONE_0));
			MilightHandler(LCMD_PAIRING, LSUBCMD_PAIR, ~selZone & 0x0F);
			ESP_LOGI("PWM", "Light control cmd %d subcmd %d zone %d",
					LCMD_PAIRING, LSUBCMD_PAIR, ~selZone & 0x0F);
		}

		vTaskDelay(10 / portTICK_RATE_MS);
	}

}
