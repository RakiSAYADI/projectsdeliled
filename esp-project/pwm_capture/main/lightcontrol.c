/*
 * uart1.c
 *
 *  Created on: Apr 1, 2018
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
#include <freertos/FreeRTOS.h>
#include <freertos/task.h>
#include <esp_log.h>
#include <esp_err.h>
#include <esp_system.h>
#include <esp_event_loop.h>
#include "esp_wifi.h"
#include "math.h"
#include <nvs.h>
#include <nvs_flash.h>
#include <driver/gpio.h>
#include <tcpip_adapter.h>
#include "esp_system.h"
#include <stdlib.h>
#include <driver/dac.h>

#include "sdkconfig.h"

#include "lightcontrol.h"

#define TAG "UART"

static const int RX_BUF_SIZE = 128;

#define TXD_PIN (GPIO_NUM_19)
#define RXD_PIN (GPIO_NUM_23)

char CMD_MI_LINK[] = { 0x3D, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00 };
char CMD_MI_UNLINK[] = { 0x3E, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00 };
char MI_ON[] = { 0x31, 0x00, 0x00, 0x08, 0x04, 0x01, 0x00, 0x00, 0x00 };
char MI_OFF[] = { 0x31, 0x00, 0x00, 0x08, 0x04, 0x02, 0x00, 0x00, 0x00 };
char MI_NLON[] = { 0x31, 0x00, 0x00, 0x08, 0x04, 0x05, 0x00, 0x00, 0x00 };
char MI_WHITE[] = { 0x31, 0x00, 0x00, 0x08, 0x05, 0x64, 0x00, 0x00, 0x00 };
char MI_SETCOL[] = { 0x31, 0x00, 0x00, 0x08, 0x01, 0x00, 0x00, 0x00, 0x00 };
char MI_SAT[] = { 0x31, 0x00, 0x00, 0x08, 0x02, 0x00, 0x00, 0x00, 0x00 };
char MI_BR[] = { 0x31, 0x00, 0x00, 0x08, 0x03, 0x00, 0x00, 0x00, 0x00 };
char MI_KEL[] = { 0x31, 0x00, 0x00, 0x08, 0x05, 0x00, 0x00, 0x00, 0x00 };
char MI_MODE[] = { 0x31, 0x00, 0x00, 0x08, 0x06, 0x00, 0x00, 0x00, 0x00 };
char MI_SPEEDUP[] = { 0x31, 0x00, 0x00, 0x08, 0x04, 0x03, 0x00, 0x00, 0x00 };
char MI_SPEEDDW[] = { 0x31, 0x00, 0x00, 0x08, 0x04, 0x04, 0x00, 0x00, 0x00 };

char TxBuffer[] = { 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00 };

void rx_task() {
	static const char *RX_TASK_TAG = "RX_TASK";
	esp_log_level_set(RX_TASK_TAG, ESP_LOG_INFO);
	uint8_t* data = (uint8_t*) malloc(RX_BUF_SIZE + 1);
	while (1) {
		const int rxBytes = uart_read_bytes(UART_NUM_1, data, RX_BUF_SIZE,
				1000 / portTICK_RATE_MS);
		if (rxBytes > 0) {
			data[rxBytes] = 0;
			ESP_LOGI(RX_TASK_TAG, "Read %d bytes: '%s'", rxBytes, data);
			ESP_LOG_BUFFER_HEXDUMP(RX_TASK_TAG, data, rxBytes, ESP_LOG_INFO);
		}
	}
	free(data);
}

uint8_t MI_calc_cs() {
	uint8_t i = 0;
	uint32_t cs = 0;

	for (i = 0; i < 10; i++) {
		cs += TxBuffer[i];
	}

	return (cs);
}

#define REPEAT_COUNTER	3

typedef struct {
	char bufferitem[12];
} TxBufferitem_Typedef;

TxBufferitem_Typedef BufferArray[64];
uint8_t TxBufferitemCount = 0;
uint8_t TxBufferitemPassedCount = 0;

void UartTxTask() {
	while (1) {
		if (TxBufferitemPassedCount < TxBufferitemCount) {
			for (uint8_t i = 0; i < REPEAT_COUNTER; i++) {
				uart_write_bytes(UART_NUM_1,
						BufferArray[TxBufferitemPassedCount].bufferitem, 12);
				vTaskDelay(30 / portTICK_PERIOD_MS);
			}
			TxBufferitemPassedCount++;
		} else {
			TxBufferitemCount = 0;
			TxBufferitemPassedCount = 0;
			vTaskDelay(50 / portTICK_PERIOD_MS);
		}
	}
	vTaskDelete(NULL);
}

void add2buffer() {
	memcpy(BufferArray[TxBufferitemCount].bufferitem, TxBuffer,
			sizeof(TxBuffer));
	if (TxBufferitemCount < 63)
		TxBufferitemCount++;
}

void Mi_Pair(uint8_t id) {
	memcpy(TxBuffer, CMD_MI_LINK, sizeof(CMD_MI_LINK));
	TxBuffer[9] = id;
	TxBuffer[10] = 00;
	TxBuffer[11] = MI_calc_cs();

	add2buffer();
}

void Mi_Unpair(uint8_t id) {
	memcpy(TxBuffer, CMD_MI_UNLINK, sizeof(CMD_MI_UNLINK));
	TxBuffer[9] = id;
	TxBuffer[10] = 00;
	TxBuffer[11] = MI_calc_cs();

	add2buffer();
}

void Mi_On(uint8_t id) {
	memcpy(TxBuffer, MI_ON, sizeof(MI_ON));
	TxBuffer[9] = id;
	TxBuffer[10] = 00;
	TxBuffer[11] = MI_calc_cs();

	add2buffer();
}

void Mi_Off(uint8_t id) {
	memcpy(TxBuffer, MI_OFF, sizeof(MI_OFF));
	TxBuffer[9] = id;
	TxBuffer[10] = 00;
	TxBuffer[11] = MI_calc_cs();

	add2buffer();
}

void Mi_NLON(uint8_t id) {
	memcpy(TxBuffer, MI_NLON, sizeof(MI_NLON));
	TxBuffer[9] = id;
	TxBuffer[10] = 00;
	TxBuffer[11] = MI_calc_cs();

	add2buffer();
}

void Mi_White(uint8_t id) {
	memcpy(TxBuffer, MI_WHITE, sizeof(MI_WHITE));
	TxBuffer[9] = id;
	TxBuffer[10] = 00;
	TxBuffer[11] = MI_calc_cs();

	add2buffer();
}

void Mi_Color(uint8_t id, uint8_t color) {
	memcpy(TxBuffer, MI_SETCOL, sizeof(MI_SETCOL));
	TxBuffer[5] = color;
	TxBuffer[6] = color;
	TxBuffer[7] = color;
	TxBuffer[8] = color;
	TxBuffer[9] = id;
	TxBuffer[10] = 00;
	TxBuffer[11] = MI_calc_cs();

	add2buffer();
}

void Mi_Saturation(uint8_t id, uint8_t sat) {
	memcpy(TxBuffer, MI_SAT, sizeof(MI_SAT));
	TxBuffer[5] = sat;
	TxBuffer[9] = id;
	TxBuffer[10] = 00;
	TxBuffer[11] = MI_calc_cs();

	add2buffer();
}

void Mi_Brighness(uint8_t id, uint8_t br) {
	memcpy(TxBuffer, MI_BR, sizeof(MI_BR));
	TxBuffer[5] = br;
	TxBuffer[9] = id;
	TxBuffer[10] = 00;
	TxBuffer[11] = MI_calc_cs();

	add2buffer();
}

void Mi_kelvin(uint8_t id, uint8_t kl) {
	memcpy(TxBuffer, MI_KEL, sizeof(MI_KEL));
	TxBuffer[5] = kl;
	TxBuffer[9] = id;
	TxBuffer[10] = 00;
	TxBuffer[11] = MI_calc_cs();

	add2buffer();
}

void Mi_mode(uint8_t id, uint8_t md) {
	memcpy(TxBuffer, MI_MODE, sizeof(MI_MODE));
	TxBuffer[5] = md;
	TxBuffer[9] = id;
	TxBuffer[10] = 00;
	TxBuffer[11] = MI_calc_cs();

	add2buffer();
}

void Mi_spdup(uint8_t id) {
	memcpy(TxBuffer, MI_SPEEDUP, sizeof(MI_SPEEDUP));
	TxBuffer[9] = id;
	TxBuffer[10] = 00;
	TxBuffer[11] = MI_calc_cs();

	add2buffer();
}

void Mi_spddw(uint8_t id) {
	memcpy(TxBuffer, MI_SPEEDDW, sizeof(MI_SPEEDDW));
	TxBuffer[9] = id;
	TxBuffer[10] = 00;
	TxBuffer[11] = MI_calc_cs();

	add2buffer();
}

uint8_t LastMode = 0;

void MilightHandler(uint8_t cmd, uint8_t subcmd, uint8_t zonecode) {

	uint8_t i = 0;
	uint8_t zone = 0;

	for (i = 0; i < 4; i++) {

		if (zonecode != 15) {

			zone = zonecode & (1 << i);

			switch (zone) {
			case 1:
				zone = 1;
				break;
			case 2:
				zone = 2;
				break;
			case 4:
				zone = 3;
				break;
			case 8:
				zone = 4;
				break;
			default:
				continue;
			}
		} else {
			zone = 0;
		}

		switch (cmd) {
		case LCMD_SWITCH_ON_OFF:
			if (subcmd == 0) {
				Mi_On(zone);
			}
			if (subcmd == 1) {
				Mi_Off(zone);
			}
			break;
		case LCMD_SWITCH_ON:
			if (subcmd == 0) {
				Mi_On(zone);
			}
			break;
		case LCMD_SET_COLOR:
			Mi_Color(zone, subcmd);
			break;
		case LCMD_MODE_SETTING:
			if (subcmd == 0) {
				Mi_spddw(zone);
			}
			if (subcmd == 1) {
				Mi_spdup(zone);
			}
			if (subcmd == 2) {
				Mi_mode(zone, LastMode);
				if (LastMode < 8)
					LastMode++;
				else
					LastMode = 0;
			}
			break;
		case LCMD_PAIRING:
			if (subcmd == 0) {
				Mi_Unpair(zone);
			}
			if (subcmd == 1) {
				Mi_Pair(zone);
			}
			break;
		case LCMD_SET_WHITE:
			Mi_White(zone);
			break;
		case LCMD_SET_BRIGTHNESS:
			Mi_Brighness(zone, subcmd);
			break;
		case LCMD_SET_TEMP:
			Mi_kelvin(zone, (100 - subcmd));
			break;
		case LCMD_SET_SAT:
			Mi_Saturation(zone, 100 - subcmd);
			break;
		case LCMD_SET_MODE:
			Mi_mode(zone, subcmd);
			break;
		}
		if (zone == 0)
			return;
	}
}

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

void SimLightCommand() {
	while (1) {
		MilightHandler(LCMD_SWITCH_ON_OFF, 0, 7);
		vTaskDelay(500 / portTICK_PERIOD_MS);
		MilightHandler(LCMD_SWITCH_ON_OFF, 1, 7);
		vTaskDelay(500 / portTICK_PERIOD_MS);
	}
}

void lightControl_Init() {

	const uart_config_t uart_config = { .baud_rate = 38400, .data_bits =
			UART_DATA_8_BITS, .parity = UART_PARITY_DISABLE, .stop_bits =
			UART_STOP_BITS_1, .flow_ctrl = UART_HW_FLOWCTRL_DISABLE };
	uart_param_config(UART_NUM_1, &uart_config);
	uart_set_pin(UART_NUM_1, TXD_PIN, RXD_PIN, UART_PIN_NO_CHANGE,
			UART_PIN_NO_CHANGE);

	uart_driver_install(UART_NUM_1, RX_BUF_SIZE * 2, 0, 0, NULL, 0);

	xTaskCreatePinnedToCore(rx_task, "uart_rx_task", 1024 * 2, NULL, 1, NULL,
			1);
	xTaskCreatePinnedToCore(UartTxTask, "UartTxTask", 1024 * 2, NULL, 1, NULL,
			1);

}
