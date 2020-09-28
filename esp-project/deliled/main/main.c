/*
 * main.c
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
#include "esp_system.h"
#include "stdlib.h"
#include "stdbool.h"

#include "sdkconfig.h"
#include "i2c.h"
#include "adc.h"
#include "main.h"
#include "app_gpio.h"
#include "lightcontrol.h"
#include "unitcfg.h"
#include "webservice.h"
#include "ftpclient.h"
#include "emailclient.h"
#include "gatt_server.h"
#include "autolight.h"
#include "mqttclient.h"

uint8_t dacout = 0;

static const char *TAG = "MAIN";

void app_main() {
	nvs_flash_init();

	ESP_LOGI(TAG, "[APP] Startup..");
	ESP_LOGI(TAG, "[APP] Free memory: %d bytes", esp_get_free_heap_size());
	ESP_LOGI(TAG, "[APP] IDF version: %s", esp_get_idf_version());

	LedStatInit();

	UnitData.LastDetTime += 1546300800;

	if (InitLoadCfg() != 0) {
		UnitSetStatus(UNIT_STATUS_ERROR);
		return;
	}

	if (!(strContains(UnitCfg.FLASH_MEMORY, "OK") == 1)) {
		ESP_LOGI(TAG, "Saving the default configuration ..");
		Default_saving();
	}

	UnitSetStatus(UNIT_STATUS_LOADING);

	UnitData.state = UnitCfg.MODE;

	I2c_Init();
	AdcInit();
	lightControl_Init();
	GattsInit();

	//UnitCfg.UnitTimeZone = 1;

	//strcpy(UnitCfg.WifiCfg.WIFI_PASS,"b6s4j9r63g");
	//strcpy(UnitCfg.WifiCfg.WIFI_SSID,"TT_A3F0");

	//strcpy(UnitCfg.MqttConfig.Server,"broker.mqttdashboard.com");
	//UnitCfg.MqttConfig.Port=8000;
	//strcpy(UnitCfg.MqttConfig.UserName,"kynfgcft");
	//strcpy(UnitCfg.MqttConfig.Password,"UjvIsk0KZxQD");
	//strcpy(UnitCfg.MqttConfig.Topic,"testtopic/deliled");
	//UnitCfg.MqttConfig.MqttLogEnb = true;

	WebService_Init();

}
