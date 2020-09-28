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
#include "ftp_client.h"
#include "gatt_server.h"
#include "autolight.h"

uint8_t dacout=0;

void app_main()
{
	nvs_flash_init();

	LedStatInit();

	UnitData.LastDetTime += 1546300800;

	if (InitLoadCfg()!=0)
	{
		UnitSetStatus(UNIT_STATUS_ERROR);
		return;
	}

	UnitSetStatus(UNIT_STATUS_LOADING);

	I2c_Init();
	AdcInit();
	lightControl_Init();
	GattsInit();

	//UnitCfg.UnitTimeZone = 1;

	//strcpy(UnitCfg.WifiCfg.WIFI_PASS,"helloWorld");
	//strcpy(UnitCfg.WifiCfg.WIFI_SSID,"MicroDeviceTunisie");

	//sprintf(UnitCfg.Email,"raki_sayadi@hotmail.fr");

	//strcpy(UnitCfg.MqttConfig.Server,"broker.mqttdashboard.com");
	//UnitCfg.MqttConfig.Port=8000;
	//strcpy(UnitCfg.MqttConfig.UserName,"kynfgcft");
	//strcpy(UnitCfg.MqttConfig.Password,"UjvIsk0KZxQD");
	//strcpy(UnitCfg.MqttConfig.Topic,"testtopic/deliled");
	//UnitCfg.MqttConfig.MqttLogEnb = true;

	WebService_Init();

}
